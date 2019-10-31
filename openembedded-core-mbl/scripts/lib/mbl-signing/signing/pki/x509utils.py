# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause


"""X509 extension and certificate objects."""

import binascii
from abc import abstractmethod

from cryptography import x509
from cryptography import utils
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend

from signing.pki import asn1parse


@utils.register_interface(x509.ExtensionType)
class ATFExtension:
    """Describes a custom X509v3 extension used by ATF."""

    def __init__(self, oid, critical=False, value=None):
        """
        Initialise the extension object.

        :params oid string: Dotted string OID for the extension type.
        :params critical bool: Specifies whether to mark this
        extension as critical or not.
        :params value bytes: Extension value in ASN1 format.
        """
        self._oid = x509.ObjectIdentifier(oid)
        self._critical = critical
        self._value = x509.UnrecognizedExtension(self.oid, value)

    def __str__(self):
        """Return a string representation of the object."""
        return "{};{};{}".format(
            self.oid.dotted_string,
            str(self.critical).lower(),
            binascii.hexlify(self.value.value).decode(),
        )

    @property
    def oid(self):
        """Object Identifier."""
        return self._oid

    @property
    def critical(self):
        """Specify if the extension will be marked as critical."""
        return self._critical

    @property
    def value(self):
        """Extension value wrapped in an UnrecognizedExtension."""
        return self._value

    @value.setter
    def value(self, new_val):
        """
        Extension value setter.

        :params new_val bytes: New value for the extension.
        """
        self._value = x509.UnrecognizedExtension(self.oid, new_val)

    @abstractmethod
    def encode_value(self, value_data):
        """Subclass must override this to encode specific value types."""
        pass


class HashExtension(ATFExtension):
    """An ATF extension containing a hash of a boot component."""

    def __init__(self, *args, content_file=None, **kwargs):
        """
        Initialise the extension object.

        :params content_file str: Name of the content file to hash.
        """
        super().__init__(*args, **kwargs)
        self.content_file = content_file

    def encode_value(self, data):
        """
        Create a digest of content_file and encode to an ASN1 value.

        :params data bytes: File data in bytes.
        """
        if data is None:
            digest = b"\x00" * 32
        else:
            hasher = hashes.Hash(hashes.SHA256(), backend=default_backend())
            hasher.update(data)
            digest = hasher.finalize()
        enc_val = asn1parse.encode_asn1_digest_info(
            "2.16.840.1.101.3.4.2.1", digest
        )
        self.value = enc_val


class PKExtension(ATFExtension):
    """ATFExtension containing a SubjectPublicKeyInfo value."""

    def __init__(self, *args, pub_key_name=None, **kwargs):
        """
        Init the extension object.

        :params pub_key_name str: The name of the public key to
        include in the extension.
        """
        super().__init__(*args, **kwargs)
        self.pub_key_name = pub_key_name

    def encode_value(self, pub_key):
        """
        Encode a subject public key and store in the extension.

        :params pub_key bytes: The raw subject public key bytes.
        """
        enc_val = asn1parse.encode_asn1_subject_key_info(pub_key)
        self.value = enc_val


class CounterExtension(ATFExtension):
    """ATFExtension containing NV counter values."""

    def encode_value(self, counter_value):
        """Encode the counter value as an asn1 integer."""
        self.value = asn1parse.encode_asn1_nv_counter_info(counter_value)


class X509CertificateExtensions:
    """A collection of ATFExtensions to be included in a certificate."""

    def __init__(self, name, exts, signer, file_name):
        """
        Initialise the object.

        :params name str: Certificate common name.
        :params exts dict: Dict of extension types to include.
        :params signer str: The signing key name.
        :params file_name str: Output file name for the cert.
        """
        self._extensions = exts
        self._cert_name = name
        self._signer = signer
        self._file_name = file_name

    @property
    def name(self):
        """Return the certificate name."""
        return self._cert_name

    @property
    def file_name(self):
        """Return the output file name."""
        return self._file_name

    @property
    def signer(self):
        """Return the signer name."""
        return self._signer

    @property
    def extensions(self):
        """Return a list of extension objects."""
        return list(self._extensions.values())

    def get_extension(self, name):
        """Get an extension by name."""
        return self._extensions[name]

    def get_ext_name_from_oid(self, oid):
        """Return the extension name associated with an OID."""
        for name, ext in self._extensions.items():
            if ext.oid == oid:
                return name

    def add_extension(self, name, ext):
        """Add a new extension to the set."""
        self._extensions[name] = ext

    def __iter__(self):
        """Make the object iterable so we can iterate over the extensions."""
        for i in self._extensions.values():
            yield i


class ExtensionValueGetter:
    """
    This class deduces the extension value type.

    It does this based on the extension object's type.
    This should be changed and the ATFExtension classes
    should be refactored to be polymorphic without using this object.

    This is temporary and will be removed in the next version.
    """

    def __init__(self, pub_keys, content_dir):
        """
        Initialise the ValueGetter.

        :params pub_keys dict: Dict of public keys.
        :params content_dir Path: Directory where the
        boot components to be hashed live.
        """
        self._pub_keys = pub_keys
        self._content_dir = content_dir

    def get(self, ext, cert):
        """
        Get the extension value based on the object type.

        :params ext ATFExtension: The extension object.
        :params cert X509CertificateExtensions: the certificate object.
        """
        if isinstance(ext, HashExtension):
            if ext.content_file is None:
                return None
            fp = self._content_dir / ext.content_file
            ext.content_file = str(fp.absolute())
            if not fp.is_file():
                return None
            return fp.read_bytes()
        if isinstance(ext, PKExtension):
            pkey = self._pub_keys.get(ext.pub_key_name, None)
            if pkey is None:
                return b"\x00"
            return pkey
        if isinstance(ext, CounterExtension):
            return 0


def extract_public_key(cert_pem, output_format):
    """
    Extract the public key from a PEM encoded cert.

    :params cert_pem str: PEM encoded certificate.
    :params output_format str: PEM or DER output.
    """
    c = x509.load_pem_x509_certificate(cert_pem.encode(), default_backend())
    if output_format.lower() == "pem":
        return c.public_key().public_bytes(
            serialization.Encoding.PEM,
            serialization.PublicFormat.SubjectPublicKeyInfo,
        )
    if output_format.lower() == "der":
        return c.public_key().public_bytes(
            serialization.Encoding.DER,
            serialization.PublicFormat.SubjectPublicKeyInfo,
        )
    raise ValueError("output_format must be 'pem' or 'der'")


def cert_pem_to_der(certificate):
    """Convert a PEM formatted cert to DER."""
    c = x509.load_pem_x509_certificate(certificate.encode(), default_backend())
    return c.public_bytes(serialization.Encoding.DER)


def private_key_pem_to_der(private_key):
    """Convert a PEM formatted private key to DER."""
    return serialization.load_pem_private_key(
        private_key.encode(), password=None, backend=default_backend()
    ).private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.TraditionalOpenSSL,
        encryption_algorithm=serialization.NoEncryption(),
    )


def public_key_pem_to_der(public_key):
    """Convert a PEM formatted public key to DER."""
    return serialization.load_pem_public_key(
        public_key.encode(), backend=default_backend()
    ).public_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PublicFormat.SubjectPublicKeyInfo,
    )


def private_key_der_to_pem(private_key):
    """Convert a DER encoded private key to PEM format."""
    return serialization.load_der_private_key(
        private_key, password=None, backend=default_backend()
    ).private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.TraditionalOpenSSL,
        encryption_algorithm=serialization.NoEncryption(),
    )


def add_extensions(cert_pem, encoding, extensions):
    """
    Add extension objects to a certificate object.

    :params cert_pem str: PEM encoded certificate.
    :params encoding str: Output cert encoding DER, PEM or RAW.
    (RAW is a cryptography `Certificate` object).
    :params extensions List[ATFExtension]: List of extension objects to patch
    in to the cert.
    """
    certificate = x509.load_pem_x509_certificate(cert_pem, default_backend())
    certificate.extensions._extensions + extensions
    if encoding.lower() == "der":
        return certificate.public_bytes(serialization.Encoding.DER)
    elif encoding.lower() == "pem":
        return certificate.public_bytes(serialization.Encoding.PEM).decode()
    elif encoding.lower() == "raw":
        return certificate
    else:
        raise ValueError("encoding must be 'der' 'pem' or 'raw'.")
