# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause


"""Utilities for asn1 data parsing."""

from pyasn1.type.univ import (
    ObjectIdentifier,
    OctetString,
    Sequence,
    Null,
    BitString,
    Integer,
    Any,
)
from pyasn1.type.namedtype import NamedType, NamedTypes
from pyasn1.codec.der.encoder import encode as der_encoder


class AlgorithmIdentifier(Sequence):
    """
    Define an AlgorithmIdentifier.

    AlgorithmIdentifier is a custom ASN1 sequence type
    containing an algortihm OID and any optional parameters.
    In this case the parameters are always null.
    """

    componentType = NamedTypes(
        NamedType("algorithm", ObjectIdentifier()),
        NamedType("parameters", Null()),
    )


class DigestInfo(Sequence):
    """
    Define a DigestInfo.

    DigestInfo is an ASN1 Sequence type containing an AlgorithmIdentifier
    and the actual digest.
    """

    componentType = NamedTypes(
        NamedType("digestAlgorithm", AlgorithmIdentifier()),
        NamedType("digest", OctetString()),
    )


def encode_asn1_digest_info(oid, digest):
    """
    Encode a DigestInfo to DER format bytes.

    :params oid string: Dotted string ObjectIdentifier.
    :params digest bytes: A digest to include in the ASN1 structure.
    """
    digest_info = DigestInfo()
    digest_info["digestAlgorithm"]["algorithm"] = oid
    digest_info["digest"] = digest
    return der_encoder(digest_info)


def encode_asn1_subject_key_info(pub_key):
    """Encode SubjectKeyInfo to DER format bytes."""
    return der_encoder(Any(pub_key))


def encode_asn1_nv_counter_info(val):
    """Encode an ASN1 integer value."""
    return der_encoder(Integer(val))
