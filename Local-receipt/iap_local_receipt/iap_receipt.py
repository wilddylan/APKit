import hashlib
import binascii
import uuid


class IAPReceipt(object):
    def __init__(self, receipt):
        """
        Initialize the object with an IAP receipt dict
        as returned by IAPReceiptParser.

        The dict format is shown below.
        Note that `in_app` may contain multiple in-app purchase
        receipts.

        {
         'original_application_version': '1.0',
         'in_app': [
           {
            'expires_date': datetime object or None,
            'product_id': 'MY_PRODUCT_ID',
            'original_transaction_id': '0000000000000000',
            'original_purchase_date': datetime object or None,
            'cancellation_date': datetime object or None,
            'purchase_date': datetime object or None,
            'web_order_line_item_id': 0,
            'transaction_id': '0000000000000000',
            'quantity': 1
           }
          ],
         'opaque_value': 'binary data',
         'bundle_id': 'com.example.MyAwesomeApp',
         'sha1_hash': 'binary data',
         'application_version': '0'
        }

        """
        self.receipt = receipt

    def validate(self, product_id, bundle_id=None, application_version=None,
                 guid=None):
        """
        Validate receipt against `product_id`, and optionally
        `bundle_id`, `application_version`, and `guid`. Any or all of the
        optional values maybe be omitted, to skip that part of the validation.
        The SHA-1 hash will not be verified if any of these are omitted.

        Validation is done according to the Apple documentation at
        https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateLocally.html#//apple_ref/doc/uid/TP40010573-CH1-SW2

        Throw Exception if any validation step fails.
        """

        receipt = self.receipt

        # Verify that the bundle identifier in the receipt matches a
        # hard-coded constant containing the CFBundleIdentifier value you
        # expect in the Info.plist file.
        if (bundle_id and bundle_id != receipt['bundle_id']):
            raise Exception('receipt bundle_id "{}" does not match "{}"'
                            .format(receipt['bundle_id'], bundle_id))

        # Verify that the version identifier string in the receipt matches a
        # hard-coded constant containing the CFBundleShortVersionString value
        # you expect in the Info.plist file.
        if (application_version and
                application_version != receipt['application_version']):
            raise Exception('receipt application_version "{}"'
                            ' does not match "{}"'
                            .format(receipt['application_version'],
                                    application_version))

        # Compute the hash of the GUID.
        # If the result does not match the hash in the receipt, validation
        # fails.
        if (bundle_id and application_version and guid):
            sha1_hash = self.compute_guid_hash(guid)
            if sha1_hash != receipt['sha1_hash']:
                raise Exception('receipt sha1_hash "{}" does not match "{}"'
                                .format(binascii.hexlify(receipt['sha1_hash']),
                                        binascii.hexlify(sha1_hash)))

        # Check that there is at least one in_app receipt matching product_id
        found = any(('product_id' in d) and
                    d['product_id'] == product_id for d in receipt['in_app'])

        if not found:
            raise Exception('product_id "{}" not found in receipt'
                            .format(product_id))

        return found

    def compute_guid_hash(self, guid):
        """
        Compute the SHA-1 hash of the GUID to compare with the one in the
        receipt.

        `guid` is expected to be in the format:

        'urn:uuid:12345678-1234-5678-567812345678'

        To compute the hash, first concatenate the GUID value with the opaque
        value (the attribute of type 4) and the bundle identifier. Use the raw
        bytes from the receipt without performing any UTF-8 string
        interpretation or normalization. Then compute the SHA-1 hash of this
        concatenated series of bytes.
        """
        sha = hashlib.sha1()
        sha.update(uuid.UUID(guid).bytes)
        sha.update(self.receipt['opaque_value'])
        sha.update(self.receipt['raw_bundle_id'])

        return sha.digest()
