#!/usr/bin/env python
# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause


"""
Handle the HTTP requests to the endpoints defined in swagger/keystore.yaml.

This should be launched as __main__. It is the front-end of a Flask App.

A server will be spawned at the address given.
"""

import connexion
import pathlib
from signing.pki.backends import signing_backend


SPEC_DIR = pathlib.Path(__file__).parent / "swagger"

# Set the signing engine to None as it needs to be instantiated
# after this module is imported, and it needs to be globally available
# to the module. The engine is set in main.
# We're not using the flask g object here as we only need to
# handle a single request at a time.
engine = None


def connect_to_storage_backend(**body):
    """Handle /connect endpoint."""
    engine.server_url = body["params"]["server_url"]
    return {"data": {"server_url": engine.server_url}}, 200


def list_certificates():
    """Handle /certs endpoint."""
    certs = engine.list_certificates()
    return certs, 200


def generate_certificate(name, **body):
    """Handle /issue/{name} endpoint."""
    params = body["params"]
    common_name = params.pop("common_name")
    issuer_name = params.pop("issuer_name")
    resp = engine.request_certificate(name, common_name, issuer_name, **params)
    return resp.json(), 200


def generate_root(**body):
    """Handle /root/generate/{root_type} endpoint."""
    params = body["params"]
    common_name = params.pop("common_name")
    resp = engine.generate_root(common_name, **params)
    return resp.json(), 200


def create_or_update_role(name, **body):
    """Handle /roles/{name} endpoint."""
    params = body["params"]
    issuer = params.pop("issuer")
    engine.create_or_update_role(name, issuer, **params)
    return {}, 200


def generate_intermediate(name, **body):
    """Handle /root/generate/{root_type} endpoint."""
    params = body["params"]
    common_name = params.pop("common_name")
    int_type = params.pop("int_type")
    issuer_name = params.pop("issuer_name")
    extensions = params.pop("extensions")
    resp = engine.generate_intermediate(
        name, common_name, int_type, issuer_name, extensions, **params
    )
    return resp.json(), 200


def read_certificate(serial, **body):
    """Handle /cert/{serial} endpoint."""
    params = body["params"]
    resp = engine.read_certificate(serial, params["issuer_name"])
    return resp, 200


def main():
    """Entry point."""
    # This is needed because global variables don't work in python without it.
    global engine
    engine = signing_backend()
    app = connexion.FlaskApp("keystore-api-server", specification_dir=SPEC_DIR)
    app.add_api("keystore.yaml", arguments={"title": "KeyStore"})
    app.run(port=5000)
