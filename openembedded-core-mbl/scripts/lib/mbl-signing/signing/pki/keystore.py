# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause


"""The keystore module contains an interface to store and retrieve certificates
and keys used for signing.

The KeyStore class wraps a backend class and delegates all calls to it.

The backend is the interface to the secrets engine you have chosen to use.
The backend class will typically be a wrapper around some REST api calls.
To use the KeyStore, instantiate a backend and pass it to the KeyStore
constructor.
"""

import json
import logging


logger = logging.getLogger("mbl-signing.pki")


class KeyStoreResponse:
    """Convert HTTPResponse json objects from the backend to an object."""
    def __init__(self, response):
        self.raw = response.text
        self._data = None
        try:
            self._data = json.loads(self.raw)
        except json.decoder.JSONDecodeError:
            # The response content is empty, just return an empty instance.
            return
        for k, v in self._data.items():
            setattr(self, k, v)


class KeyStore:
    """This class is an interface to generate and recall keys and certificates.

    This is a wrapper around a 'backend' class, which forwards calls to a REST
    api.
    The 'backend' will do the real work of generating and storing the keys.

    The backend object is passed to the constructor, allowing you to plug in
    any secrets storage / key generation engine you like.

    All methods take a **params set of kwargs. This is for backend specific
    options and is just forwarded to the backend class.
    """

    def __init__(self, backend):
        """Initialise the KeyStore with a backend."""
        self._backend = backend

    def generate_root(self, common_name, **params):
        """Generate a root private key and certificate and store it in the backend.

        :param common_name str: The certificate Subject Name.
        :param **params dict: json payload to pass to the secrets backend.
        """
        return KeyStoreResponse(
            self._backend.generate_root(
                common_name=common_name,
                extra_params=params,
                mount_point=common_name,
            )
        )

    def generate_intermediate(
        self, common_name, int_type, root_name, extensions, **params
    ):
        """Generate an intermediate CA certificate, signed by a root.

        :params common_name str: The certificate Subject Name.
        :params int_type str: Specifies if the private key is exported or not.
        :params extensions List: list of x509.Extension objects to copy into
        the cert.
        """
        return KeyStoreResponse(
            self._backend.generate_intermediate(
                int_type=int_type,
                common_name=common_name,
                issuer_name=root_name,
                extensions=extensions,
                **params,
            )
        )

    def read_certificate(self, serial, root):
        """Read a certificate stored in the backend.

        :param serial str: Serial number of the certificate.
        :param root str: The signing root name.
        """
        return self._backend.read_certificate(
            serial, mount_point=root
        )

    def list_certificates(self):
        """Return a list of stored certificates."""
        return self._backend.list_certificates()
