#!/usr/bin/env python3
# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

import hashlib
import json

from update.util import read_chunks


def create_testinfo_file(images, path):
    """
    Create a "testinfo" file with info required to test an update payload.
    """
    with open(str(path), mode="wt") as f:
        json.dump(_generate_testinfo(images), f, indent=4)


def file_compare(path_on_target):
    """
    Generate testinfo fragment for a test that the content of a file on the
    target changes after an update.
    """
    return _generate_test_testinfo("file_compare", path=str(path_on_target))


def file_timestamp_compare(path_on_target):
    """
    Generate testinfo fragment for a test that the timestamp of a file on the
    target changes after an update.
    """
    return _generate_test_testinfo(
        "file_timestamp_compare", path=str(path_on_target)
    )


def file_sha256(path_on_host, path_on_target):
    """
    Generate testinfo fragment for a test that the sha256 digest of a file is
    as expected after an update.
    """
    return _generate_test_testinfo(
        "file_sha256",
        path=str(path_on_target),
        sha256=_generate_sha256_hexdigest(path_on_host),
    )


def partition_sha256(part_name, path_on_host):
    """
    Generate testinfo fragment for a test that a raw partition's sha256 digest
    is as expected after an update.
    """
    return _generate_test_testinfo(
        "partition_sha256",
        part_name=part_name,
        size_B=path_on_host.stat().st_size,
        sha256=_generate_sha256_hexdigest(path_on_host),
    )


def mounted_bank_compare(mount_point_on_target):
    """
    Generate testinfo fragment for a test that the partition mounted at a
    particular mount changes after an update.
    """
    return _generate_test_testinfo(
        "mounted_bank_compare", mount_point=mount_point_on_target
    )


def app_bank_compare(app_name):
    """
    Generate testinfo fragment for a test that an app's "bank" has changed
    after an update.
    """
    return _generate_test_testinfo("app_bank_compare", app_name=app_name)


def _generate_test_testinfo(test_type, **kwargs):
    return {"test_type": test_type, "args": kwargs}


def _generate_image_testinfo(image):
    return {"image_name": image.image_type, "tests": image.generate_testinfo()}


def _generate_testinfo(images):
    return {"images": [_generate_image_testinfo(image) for image in images]}


def _generate_sha256_hexdigest(path):
    sha = hashlib.sha256()
    with path.open(mode="rb") as f:
        for chunk in read_chunks(f):
            sha.update(chunk)
    return sha.hexdigest()
