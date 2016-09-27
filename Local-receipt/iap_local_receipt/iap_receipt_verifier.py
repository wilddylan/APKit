from iap_pkcs7_verifier import PKCS7Verifier
from iap_receipt_parser import IAPReceiptParser
from iap_receipt import IAPReceipt


class IAPReceiptVerifier(object):
    """
    Convenience class that houses a receipt parser and verifier
    for situations where many receipts need to be parsed, and
    the overhead of repeatedly parsing the CA cert is unwanted.
    """
    def __init__(self, ca_cert=None, ca_cert_string=None):
        self._receipt_parser = IAPReceiptParser()
        self._verifier = PKCS7Verifier(root_ca_cert_file=ca_cert,
                                       root_ca_cert_string=ca_cert_string)

        if not (ca_cert or ca_cert_string):
            raise Exception("Need one of ca_cert or ca_cert_string")

    def verify_and_parse(self, pkcs7_der):
        """
        Verify the signature in the PKCS7 object against
        the stored CA certificate, then parse the extracted
        signed data (the actual receipt ASN.1 data).
        Return IAPReceipt.
        """
        receipt_der = self.verify_signature(pkcs7_der)
        return self.parse(receipt_der)

    def verify_signature(self, pkcs7_der):
        """
        Extract the PKCS7 container from the DER binary.
        Verify the receipt signature against Apple's Root CA cert,
        and against the certificate chain contained in the PKCS7
        data.
        Return the raw receipt blob in ASN.1 format.
        """
        return self._verifier.verify_data(pkcs7_der)

    def parse(self, receipt_der):
        """
        Parse receipt in ASN.1 format, returning IAPReceipt object.
        """
        return self._receipt_parser.parse_app_receipt(receipt_der)

    def last_receipt(self):
        """Return last receipt parsed, or None"""
        return self._receipt_parser.last_receipt

    def last_receipt_der(self):
        """Return last receipt DER parsed, or None"""
        return self._receipt_parser.last_receipt_der
