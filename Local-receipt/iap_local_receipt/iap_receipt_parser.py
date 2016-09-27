from pyasn1_modules import rfc2315
from pyasn1.codec.der import decoder
from pyasn1.type import namedtype, namedval, univ, char

import rfc3339

from iap_receipt import IAPReceipt


#
# ASN.1 Receipt field types
#
FT_BUNDLE_ID = 2
FT_APPLICATION_VERSION = 3
FT_OPAQUE_VALUE = 4
FT_SHA1_HASH = 5
FT_IN_APP = 17
FT_ORIGINAL_APPLICATION_VERSION = 19
FT_EXPIRATION_DATE = 21

#
# ASN.1 In-App Receipt field types
#
FT_IN_APP_QUANTITY = 1701
FT_IN_APP_PRODUCT_ID = 1702
FT_IN_APP_TRANSACTION_ID = 1703
FT_IN_APP_PURCHASE_DATE = 1704
FT_IN_APP_ORIGINAL_TRANSACTION_ID = 1705
FT_IN_APP_ORIGINAL_PURCHASE_DATE = 1706
FT_IN_APP_EXPIRES_DATE = 1708
FT_IN_APP_WEB_ORDER_LINE_ITEM_ID = 1711
FT_IN_APP_CANCELLATION_DATE = 1712


#
# General utility definitions
#
class UTF8String(char.UTF8String):
    pass


class IA5String(char.IA5String):
    pass


def octets_to_int(octets):
    i, _ = decoder.decode(octets, asn1Spec=univ.Integer())
    return int(i)


def octets_to_utf8(octets):
    s, _ = decoder.decode(octets, asn1Spec=UTF8String())
    return str(s)


def ia5_to_datetime(octets):
    ia5_str, _ = decoder.decode(octets, asn1Spec=IA5String())
    s = str(ia5_str)

    if len(s) == 0:
        dt = None
    else:
        dt = rfc3339.parse_datetime(s)

    return dt


#
# Field maps
#
IN_APP_FIELD_MAP = {
    FT_IN_APP_QUANTITY:                (lambda x: octets_to_int(x)),
    FT_IN_APP_PRODUCT_ID:              (lambda x: octets_to_utf8(x)),
    FT_IN_APP_TRANSACTION_ID:          (lambda x: octets_to_utf8(x)),
    FT_IN_APP_PURCHASE_DATE:           (lambda x: ia5_to_datetime(x)),
    FT_IN_APP_ORIGINAL_TRANSACTION_ID: (lambda x: octets_to_utf8(x)),
    FT_IN_APP_ORIGINAL_PURCHASE_DATE:  (lambda x: ia5_to_datetime(x)),
    FT_IN_APP_EXPIRES_DATE:            (lambda x: ia5_to_datetime(x)),
    FT_IN_APP_WEB_ORDER_LINE_ITEM_ID:  (lambda x: octets_to_int(x)),
    FT_IN_APP_CANCELLATION_DATE:       (lambda x: ia5_to_datetime(x)),
}

RCPT_FIELD_MAP = {
    FT_BUNDLE_ID:                    (lambda x: octets_to_utf8(x)),
    FT_APPLICATION_VERSION:          (lambda x: octets_to_utf8(x)),
    FT_OPAQUE_VALUE:                 (lambda x: x.asOctets()),
    FT_SHA1_HASH:                    (lambda x: x.asOctets()),
    FT_ORIGINAL_APPLICATION_VERSION: (lambda x: octets_to_utf8(x)),
    FT_EXPIRATION_DATE:              (lambda x: ia5_to_datetime(x)),
}


#
# Map field names to types and ASN.1 types
#
class FieldMap:
    def __init__(self, field_map):
        self.field_map = field_map

    def convert(self, from_type, from_value):
        return self.field_map.get(from_type, lambda x: x)(from_value)

#
# App Receipt ASN.1 field definitions
#


class AppReceiptFieldType(univ.Integer):
    """Apple App Receipt named field type"""
    namedValues = namedval.NamedValues(
        ('bundle_id',                    FT_BUNDLE_ID),
        ('application_version',          FT_APPLICATION_VERSION),
        ('opaque_value',                 FT_OPAQUE_VALUE),
        ('sha1_hash',                    FT_SHA1_HASH),
        ('in_app',                       FT_IN_APP),
        ('original_application_version', FT_ORIGINAL_APPLICATION_VERSION),
        ('expiration_date',              FT_EXPIRATION_DATE)
    )


class AppReceiptField(univ.Sequence):
    """Apple App Receipt field"""
    componentType = namedtype.NamedTypes(
        namedtype.NamedType('type',    AppReceiptFieldType()),
        namedtype.NamedType('version', rfc2315.Version()),
        namedtype.NamedType('value',   univ.OctetString())
        )


class AppReceipt(univ.SetOf):
    """Apple App Receipt"""
    componentType = AppReceiptField()


#
# In-App Purchase Receipt ASN.1 field definitions
#
#
class IAPReceiptFieldType(univ.Integer):
    """Apple In-App Purchase Receipt named field type"""
    namedValues = namedval.NamedValues(
        ('quantity',                   FT_IN_APP_QUANTITY),
        ('product_id',                 FT_IN_APP_PRODUCT_ID),
        ('transaction_id',             FT_IN_APP_TRANSACTION_ID),
        ('purchase_date',              FT_IN_APP_PURCHASE_DATE),
        ('original_transaction_id',    FT_IN_APP_ORIGINAL_TRANSACTION_ID),
        ('original_purchase_date',     FT_IN_APP_ORIGINAL_PURCHASE_DATE),
        ('expires_date',               FT_IN_APP_EXPIRES_DATE),
        ('web_order_line_item_id',     FT_IN_APP_WEB_ORDER_LINE_ITEM_ID),
        ('cancellation_date',          FT_IN_APP_CANCELLATION_DATE),
    )


class IAPReceiptField(AppReceiptField):
    """Apple In-App Purchase Receipt field"""
    pass


class IAPReceiptFields(univ.SetOf):
    """Apple In-App Purchase Receipt fields"""
    componentType = IAPReceiptField()


class IAPReceiptParser(object):
    def __init__(self):
        self.rcpt_map = FieldMap(RCPT_FIELD_MAP)
        self.in_app_map = FieldMap(IN_APP_FIELD_MAP)
        self.last_receipt_der = None
        self.last_receipt = None

    def parse_app_receipt(self, receipt_der):
        """
        Parse an App Receipt ASN.1 blob, and return an
        IAPReceipt object.
        """

        self.last_receipt_der = receipt_der
        self.last_receipt = None

        # Decode raw data as AppReceipt
        receipt, _ = decoder.decode(receipt_der, asn1Spec=AppReceipt())

        # Parse top-level receipt fields
        app_receipt = {}
        iap_receipts = []

        # Convert raw fields into Python dict values
        for idx in range(len(receipt)):
            field = receipt[idx]
            ft = field['type']
            field_name = AppReceiptFieldType.namedValues.getName(ft)

            # Only convert documented fields
            if field_name:
                fv = field['value']
                if ft == FT_IN_APP:
                    iap_receipts.append(self.parse_iap_receipt(fv))
                elif ft == FT_BUNDLE_ID:  # Needed for hash, do not translate
                    app_receipt['raw_' + field_name] = fv.asOctets()
                    app_receipt[field_name] = self.rcpt_map.convert(ft, fv)
                else:
                    app_receipt[field_name] = self.rcpt_map.convert(ft, fv)

        in_app = AppReceiptFieldType.namedValues.getName(FT_IN_APP)
        app_receipt[in_app] = iap_receipts

        self.last_receipt = IAPReceipt(app_receipt)

        return self.last_receipt

    def parse_iap_receipt(self, in_app):
        in_app_fields, _ = decoder.decode(in_app, asn1Spec=IAPReceiptFields())

        fields = {}
        for idx in range(len(in_app_fields)):
            field = in_app_fields[idx]
            ft = field['type']
            field_name = IAPReceiptFieldType.namedValues.getName(ft)

            # Only convert documented fields
            if field_name:
                fv = field['value']
                fields[field_name] = self.in_app_map.convert(ft, fv)

        return fields
