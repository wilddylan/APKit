from M2Crypto import SMIME, X509, BIO, Err, m2
from M2Crypto.SMIME import PKCS7


class PKCS7VerifyError(Exception):
    pass


class PKCS7Verifier:
    def __init__(self, root_ca_cert_file=None, root_ca_cert_string=None):
        self.smime = SMIME.SMIME()

        if root_ca_cert_file:
            self.load_ca_cert_file(root_ca_cert_file)
        elif root_ca_cert_string:
            self.load_ca_cert_string(root_ca_cert_string)

        # OpenSSL will find the signer's cert in the PKCS7 data,
        # but SMIME.verify still needs a stack of signer certs,
        # even if it is empty, which is what we do here.
        self.smime.set_x509_stack(X509.X509_Stack())

    def load_ca_cert_file(self, ca_cert_file):
        """
        Load a CA cert from a PEM file, replacing any previous cert.
        """
        cert = X509.load_cert(ca_cert_file)
        self._load_cert(cert)

    def load_ca_cert_string(self, ca_cert_string):
        """
        Load a CA cert from a PEM string, replacing any previous cert.
        """
        cert = X509.load_cert_string(ca_cert_string)
        self._load_cert(cert)

    def _load_cert(self, cert):
        st = X509.X509_Store()
        st.add_cert(cert)
        self.smime.set_x509_store(st)

    def verify_file(self, pkcs7_der_file):
        """
        Verify signature on signed PKCS7 DER file.
        Return blob containing the signed data.
        Throw PKCS7VerifyError if verification failed.
        This will fail if the CA cert has not been loaded.
        """
        # Load the data, verify it.
        p7 = load_pkcs7_der(pkcs7_der_file)
        return self._verify(p7)

    # This will fail if the ca cert has not been loaded
    def verify_data(self, pkcs7_der):
        """
        Verify signature on signed PKCS7 DER blob.
        Return blob containing the signed data.
        Throw PKCS7VerifyError if verification failed.
        This will fail if the CA cert has not been loaded.
        """
        p7 = load_pkcs7_bio_der(pkcs7_der)
        return self._verify(p7)

    def _verify(self, p7):
        try:
            blob = self.smime.verify(p7)
        except Exception as error:
            raise PKCS7VerifyError(error.args)
        return blob


def load_pkcs7_der(p7file):
    """
    Load a PKCS7 object from a PKCS7 DER file.
    Return PKCS7 object.
    """
    bio = m2.bio_new_file(p7file, 'r')
    if bio is None:
        raise PKCS7VerifyError(Err.get_error())

    try:
        p7_ptr = m2.pkcs7_read_bio_der(bio)
    finally:
        m2.bio_free(bio)

    if p7_ptr is None:
        raise PKCS7VerifyError(Err.get_error())
    return PKCS7(p7_ptr, 1)


def load_pkcs7_bio_der(p7_der):
    """
    Load a PKCS7 object from a PKCS7 DER blob.
    Return PKCS7 object.
    """
    bio = BIO.MemoryBuffer(p7_der)
    if bio is None:
        raise PKCS7VerifyError(Err.get_error())

    p7_ptr = m2.pkcs7_read_bio_der(bio._ptr())

    if p7_ptr is None:
        raise PKCS7VerifyError(Err.get_error())
    return PKCS7(p7_ptr, 1)
