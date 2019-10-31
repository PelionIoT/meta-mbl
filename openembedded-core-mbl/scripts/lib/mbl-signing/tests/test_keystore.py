# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

import pytest
from signing.pki import keystore
from unittest import mock
from collections import namedtuple


@pytest.fixture(scope="function")
def mock_responder_and_return_val():
    with mock.patch("signing.pki.keystore.requests") as mockrequests:
        yield mockrequests, namedtuple("ReturnVals", "text")


def test_generate_root(mock_responder_and_return_val):
    responder, return_val = mock_responder_and_return_val
    responder.post.return_value = return_val(
        '{"data":{"private_key": "VerySafeRsaKey"}}'
    )

    store = keystore.KeyStore()
    resp = store.generate_root(
        "test",
        alt_names="test",
        ttl="8750h",
        format="pem",
        key_type="rsa",
        key_bits=2048,
        serial_number="12345",
    )

    responder.post.assert_called_once_with(
        "http://localhost:5000/v1.0/root/generate/internal",
        json={
            "alt_names": "test",
            "ttl": "8750h",
            "format": "pem",
            "key_type": "rsa",
            "key_bits": 2048,
            "serial_number": "12345",
            "common_name": "test",
        },
    )

    assert resp.data["private_key"] == "VerySafeRsaKey"


def test_generate_intermediate(mock_responder_and_return_val):
    responder, return_val = mock_responder_and_return_val
    responder.post.return_value = return_val('{"data":{"certificate": "a"}}')

    store = keystore.KeyStore()
    resp = store.generate_intermediate("test", "internal", "test_root")

    responder.post.assert_called_once_with(
        "http://localhost:5000/v1.0/intermediate/generate/internal",
        json={"common_name": "test", "root_name": "test_root"},
    )
    assert resp.data["certificate"] == "a"


def test_read_certificate(mock_responder_and_return_val):
    responder, return_val = mock_responder_and_return_val
    responder.post.return_value = return_val('{"data":{"certificate": "a"}}')

    store = keystore.KeyStore()
    resp = store.read_certificate("12345", "test_root")

    responder.post.assert_called_once_with(
        "http://localhost:5000/v1.0/cert/12345",
        json={"issuer_name": "test_root"},
    )
    assert resp.data["certificate"] == "a"


def test_request_certificate(mock_responder_and_return_val):
    responder, return_val = mock_responder_and_return_val
    responder.post.return_value = return_val('{"data":{"certificate": "a"}}')

    store = keystore.KeyStore()
    resp = store.request_certificate(
        "12345",
        "test_cert",
        "test_issuer",
        signature_algorithm="pkcs_1_5_1",
        extensions=["ext", "ext1", "ext2"],
    )

    responder.post.assert_called_once_with(
        "http://localhost:5000/v1.0/issue/12345",
        json={
            "common_name": "test_cert",
            "issuer_name": "test_issuer",
            "extensions": ["ext", "ext1", "ext2"],
            "signature_algorithm": "pkcs_1_5_1",
        },
    )
    assert resp.data["certificate"] == "a"


def test_configure_role(mock_responder_and_return_val):
    responder, return_val = mock_responder_and_return_val
    responder.post.return_value = return_val('{"data":{"role": "a"}}')

    store = keystore.KeyStore()
    resp = store.configure_role(
        "role_name",
        "issuer",
        allow_any_name="true",
        ttl="430h",
        ext_key_usage=[],
        no_store="true",
        use_csr_sans="false",
        enforce_hostnames="false",
        allow_bare_domains="true",
    )

    responder.post.assert_called_once_with(
        "http://localhost:5000/v1.0/roles/role_name",
        json=dict(
            issuer="issuer",
            allow_any_name="true",
            ttl="430h",
            ext_key_usage=[],
            no_store="true",
            use_csr_sans="false",
            enforce_hostnames="false",
            allow_bare_domains="true",
        ),
    )
    assert resp.data["role"] == "a"


@pytest.mark.parametrize(
    "response, expected_attr, expected_val",
    [
        (
            '{"data": {"certificate": "Test"}}',
            "data",
            dict(certificate="Test"),
        ),
        ('{"response": "204"}', "response", "204"),
    ],
)
def test_keystore_response(
    response, expected_attr, expected_val, mock_responder_and_return_val
):
    _, return_val = mock_responder_and_return_val
    ret_val = return_val(response)
    ks_resp = keystore.KeyStoreResponse(ret_val)
    assert hasattr(ks_resp, expected_attr)
    assert getattr(ks_resp, expected_attr) == expected_val
