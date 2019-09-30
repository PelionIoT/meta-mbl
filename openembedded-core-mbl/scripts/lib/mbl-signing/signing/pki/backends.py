# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause


"""
This module defines a "SigningBackend" interface for secrets storage engines.

The interface allows the storage engine to be called by the signing REST API.

If you want to configure your own secrets backend, you must implement the
SigningBackend interface.

The example backend is a wrapper around a Hashicorp Vault client.
For more information on the Vault PKI engine see the following link:

https://www.vaultproject.io/api/secret/pki/index.html
"""

from abc import abstractmethod, ABC
import hvac
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography import x509
from requests import ConnectionError


def signing_backend():
    """Return the chosen signing backend."""
    return VaultBackend()


class SigningBackend(ABC):
    """Abstract interface for signing backends.

    To create a backend all of the abstract methods must be overriden.
    You can define your own method signatures, however these must be
    compatible with the REST API definition.

    An example implementation is in the signing.pki.endpoints module
    """

    @property
    @abstractmethod
    def server_url(self):
        """URL of the signing backend server."""

    @abstractmethod
    def generate_root(self, *args, **kwargs):
        """Generate a root CA."""

    @abstractmethod
    def generate_intermediate(self, *args, **kwargs):
        """Generate an intermediate CA."""

    @abstractmethod
    def create_or_update_role(self, *args, **kwargs):
        """
        Create or update a role.

        Roles are a set of parameters used to create the certificate.
        These parameters include TTL, allowed common names, key usage etc.
        """

    @abstractmethod
    def request_certificate(self, *args, **kwargs):
        """Request an end entity certificate."""

    @abstractmethod
    def read_certificate(self, *args, **kwargs):
        """Read a stored certificate from the backend."""

    @abstractmethod
    def list_certificates(self, *args, **kwargs):
        """List certificates stored in the backend."""


class VaultBackend(SigningBackend):
    """
    Implementation of the SigningBackend interface.

    The backend used in this case is Hashicorp Vault.
    """

    def __init__(self, server_url=None):
        """
        Initialise the Vault client.

        :params server_url str: Vault server url.
        """
        self._client = hvac.Client(url=server_url)
        try:
            self._client.sys.is_initialized()
        except ConnectionError:
            raise EnvironmentError("Vault sever is not running!") from None

    @property
    def mount_points(self):
        """List of the mounted secret engines."""
        return self._client.sys.list_mounted_secrets_engines()

    @property
    def server_url(self):
        """Vault server url."""
        return self._client.url

    @server_url.setter
    def server_url(self, new_url):
        """Vault server url setter."""
        self._client.url = new_url

    def add_mount(self, new_mount, max_lease_ttl):
        """
        Add a new mounted secrets engine and tune it.

        :params new_mount str: Name of the new mount.
        :params max_lease_ttl str: Max TTL for certs issued by this mount.
        """
        self._client.sys.enable_secrets_engine(
            backend_type="pki", path=new_mount
        )
        self._client.sys.tune_mount_configuration(
            max_lease_ttl=max_lease_ttl, path=new_mount
        )

    def generate_root(self, common_name, **params):
        """
        Generate a root CA.

        :params common_name str: Common name for the CA.
        :params params dict: Optional config params to pass to Vault.
        """
        self._client.sys.enable_secrets_engine(
            backend_type="pki", path=common_name
        )
        self._client.sys.tune_mount_configuration(
            max_lease_ttl=params.get("ttl", "8750h"), path=common_name
        )
        response = self._client.secrets.pki.generate_root(
            "internal",
            common_name=common_name,
            extra_params=params,
            mount_point=common_name,
        )
        return response

    def submit_ca_information(self, pem_bundle, mount_point):
        """
        Submit external CA information to be stored in Vault.

        :params pem_bundle str: PEM formatted cert bundle (cert and prv key).
        :params mount_point str: The mounted secrets engine to store the info.
        """
        return self._client.secrets.pki.submit_ca_information(
            pem_bundle=pem_bundle, mount_point=mount_point
        )

    def generate_intermediate(
        self, common_name, int_type, issuer_name, **params
    ):
        """
        Create an intermediate CSR and private key for signing.

        :params common_name str: Intermediate common_name.
        :params int_type str: Either "internal" or "exported" -
        tells Vault whether to export the intermediate private key.
        If set to internal, the private key is not exported and cannot
        be retrieved later.
        """
        return self._client.secrets.pki.generate_intermediate(
            int_type, common_name=issuer_name, **params
        )

    def sign_intermediate(self, csr, common_name, root_mount, **params):
        """
        Sign a CSR and produce an intermediate CA certificate.

        :params csr str: PEM format CSR.
        :params common_name str: The common name to include in the cert.
        :params root_mount str: The signing root name.
        :params params dict: Optional config params.
        """
        return self._client.secrets.pki.sign_intermediate(
            csr=csr,
            common_name=common_name,
            extra_params=params,
            mount_point=root_mount,
        )

    def set_signed_intermediate(self, pem_certificate, mount_point):
        """
        Store a signed intermediate in the secrets engine.

        :params pem_certificate str: PEM formatted cert.
        :params mount_point str: The root signer mount name.
        """
        return self._client.secrets.pki.set_signed_intermediate(
            pem_certificate, mount_point=mount_point
        )

    def create_or_update_role(self, name, mount_point, **params):
        """
        Create or update a role.

        :params name str: The role name.
        :params mount_point str: The mount this role is associated with.
        :params params dict: Optional config params for the role.
        """
        return self._client.secrets.pki.create_or_update_role(
            name, extra_params=params, mount_point=mount_point
        )

    def request_certificate(
        self, role_name, common_name, mount_point, **params
    ):
        """
        Generate an end-entity certificate.

        :params role_name str: The name of the role to issue this cert against.
        :params common_name str: Common name to include in the issued cert.
        :params mount_point str: The root signer's mount point.
        :params params dict: Optional config params including optional x509v3
        extensions to be included in the cert. Extensions is a list of strings
        in the form "oid-dotted-string;type;value"
        """
        return self._client.secrets.pki.generate_certificate(
            role_name,
            common_name,
            extra_params=params,
            mount_point=mount_point,
        )

    def read_certificate(self, serial, mount_point):
        """
        Read a stored certificate.

        :params serial str: Serial number of the cert to read.
        :params mount_point str: The signer's mount point.
        """
        return self._client.secrets.pki.read_certificate(
            serial, mount_point=mount_point
        )

    def list_certificates(self, issuer_name):
        """
        List the certificates stored in the backend.

        :params issuer_name str: The signer's mount point.
        """
        return self._client.secrets.pki.list_certificates(
            mount_point=issuer_name
        )

    def generate_encryption_key(self, name, **params):
        self._client.sys.enable_secrets_engine(backend_type="transit", path=name)
        return self._client.secrets.transit.create_key(
            name, **params, mount_point=name
        )

    def read_encryption_key(self, name):
        return self._client.secrets.transit.read_key(name, mount_point=name)

    def encrypt_data(self, name, **params):
        return self._client.secrets.transit.encrypt_data(name, **params, mount_point=name)
