# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause


"""
This module contains an interface for generating code signing credentials.

The interface sends HTTP requests to a REST API server.

The REST API forwards the calls to a "backend" secrets engine,
which will do the real work of generating and storing the keys.

The secrets engine interface is defined in the signing.pki.backends
module.
"""

import json
import logging
import multiprocessing
import pathlib
import subprocess
import time

import requests

from signing.pki import endpoints

logger = logging.getLogger("mbl-signing.pki")


class KeyStoreError(Exception):
    """API call failed."""


class KeyStoreResponse:
    """Convert HTTPResponse json objects from the backend to an object."""

    def __init__(self, response):
        """
        Initialise the response.

        Take a HTTPResponse and iterate over the json object.
        Set attributes on this class from the json object.

        :params response HTTPResponse: A raw HTTPResponse.
        """
        if isinstance(response, dict):
            self._data = response
        else:
            try:
                self._data = json.loads(response.text)
            except json.decoder.JSONDecodeError:
                # The response content is empty, just return an empty instance.
                return
        for k, v in self._data.items():
            setattr(self, k, v)
        if hasattr(self, "status") and self.status != 200:
            msg = "Returned status: {}\n\nError message from server: {}\n"
            raise KeyStoreError(msg.format(self.status, self.detail))


def run_server_proc():
    """Run the REST api server as a subprocess."""
    proc = multiprocessing.Process(target=endpoints.main)
    proc.start()
    time.sleep(1)
    return proc


class KeyStore:
    """
    This object sends HTTP requests to a REST API server.

    The REST API forwards the calls to a "backend" secrets engine,
    which will do the real work of generating and storing the keys.

    This object must be used as a context manager. This is to ensure
    the server lifetime is managed.

    All methods take a **params set of kwargs. These optional parameters
    are forwarded to the API server.
    """

    def __init__(self, proxy_url="http://localhost:5000/v1.0"):
        """
        Initialise the KeyStore.

        :params str proxy_url: The url of the REST API server.
        """
        self._path = proxy_url

    def __enter__(self):
        """Upon entering the context manager, initialise the API server."""
        self._server = run_server_proc()
        return self

    def __exit__(self, *exc_info):
        """Terminate the server before exiting the context."""
        self._server.terminate()
        return False

    def connect(self, server_url, **params):
        """Connect to a backend secrets engine."""
        endpoint = _format_path(self._path, "connect")
        params["server_url"] = server_url
        return KeyStoreResponse(requests.post(endpoint, json=params))

    def generate_root(self, common_name, **params):
        """
        Generate and store a root private key and certificate.

        :param common_name str: The certificate Subject Name.
        :param **params dict: json payload to pass to the secrets backend.
        """
        endpoint = _format_path(self._path, "root", "generate", "internal")
        params["common_name"] = common_name
        return KeyStoreResponse(requests.post(endpoint, json=params))

    def generate_intermediate(
        self, common_name, int_type, issuer_name, **params
    ):
        """
        Generate an intermediate CA certificate, signed by a root.

        :params common_name str: The certificate Subject Name.
        :params int_type str: Specifies if the private key is exported or not.
        :params issuer_name str: Name of the signing root key.
        """
        endpoint = _format_path(
            self._path, "intermediate", "generate", int_type
        )
        params["common_name"] = common_name
        params["root_name"] = issuer_name
        return KeyStoreResponse(requests.post(endpoint, json=params))

    def read_certificate(self, serial, issuer_name):
        """
        Fetch a stored certificate.

        :param serial str: Serial number of the certificate.
        :param issuer_name str: The signing root name.
        """
        endpoint = _format_path(self._path, "cert", serial)
        params = {"issuer_name": issuer_name}
        return KeyStoreResponse(requests.post(endpoint, json=params))

    def list_certificates(self):
        """Return a list of stored certificates."""
        return self._backend.list_certificates()

    def request_certificate(
        self, role_name, common_name, issuer_name, **params
    ):
        """
        Request a new certificate based on a configured role.

        :params role_name str: The name of the role to generate against.
        :params common_name str: The common name for the certificate.
        :params issuer_name str: Name of the root key the cert is signed by.
        """
        endpoint = _format_path(self._path, "issue", role_name)
        params["common_name"] = common_name
        params["issuer_name"] = issuer_name
        return KeyStoreResponse(requests.post(endpoint, json=params))

    def configure_role(self, role_name, issuer_name, **params):
        """
        Create or update a role.

        :params str role_name: the name of the role to create or update.
        :params str issuer: The root key associated with this role.
        """
        endpoint = _format_path(self._path, "roles", role_name)
        params["issuer"] = issuer_name
        return KeyStoreResponse(requests.post(endpoint, json=params))


def _format_path(*args):
    return "/".join(args)
