# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""
Functions for creating "testinfo" files.

testinfo files contain data that suggest how the application of an update
payload on a device can be tested. They are JSON documents that look something
like:

{
    "images": [
        {
            "image_name": "ROOTFS",
            "tests": [
                {
                    "test_type": "file_timestamp_compare",
                    "args": {
                        "path": "/etc/build"
                    }
                },
                {
                    "test_type": "mounted_bank_compare",
                    "args": {
                        "mount_point": "/"
                    }
                }
            ]
        },
        {
            "image_name": "APPS",
            "tests": [
                {
                    "test_type": "app_bank_compare",
                    "args": {
                        "app_name": "user-sample-app-package"
                    }
                }
            ]
        },
    ]
}
"""

import hashlib
import json

import mbl.util.fileutil as futil


def create_testinfo_file(images, path):
    """
    Create a "testinfo" file for an update payload.

    Args:
    * images list<PayloadImage>: list of PayloadImages that describe the images
      in the update payload.
    * path <str|Path>: path at which to create the file.

    """
    with open(str(path), mode="wt") as f:
        json.dump(_generate_testinfo(images), f, indent=4)


def file_compare(path_on_target):
    """
    Generate testinfo fragment for a "file_compare" test.

    A "file_compare" test should check that the contents of a file on the
    target device change after an update.
    """
    return _generate_test_testinfo("file_compare", path=str(path_on_target))


def file_timestamp_compare(path_on_target):
    """
    Generate testinfo fragment for a "file_timestamp_compare" test.

    A "file_timestamp_compare" test should check that the last modified time of
    a file on the target changes after an update.
    """
    return _generate_test_testinfo(
        "file_timestamp_compare", path=str(path_on_target)
    )


def file_sha256(path_on_host, path_on_target):
    """
    Generate testinfo fragment for a "file_sha256" test.

    A "file_sha256" test should check that the sha256 digest of a file is as
    expected after an update.
    """
    return _generate_test_testinfo(
        "file_sha256",
        path=str(path_on_target),
        sha256=_generate_sha256_hexdigest(path_on_host),
    )


def partition_sha256(part_name, path_on_host):
    """
    Generate testinfo fragment for a "partition_sha256" test.

    A "partition_sha256" test should check that the sha256 digest of a region
    of raw flash storage on the target device is as expected after an update.
    """
    return _generate_test_testinfo(
        "partition_sha256",
        part_name=part_name,
        size_B=path_on_host.stat().st_size,
        sha256=_generate_sha256_hexdigest(path_on_host),
    )


def mounted_bank_compare(mount_point_on_target):
    """
    Generate testinfo fragment for a "mounted_bank_compare" test.

    A "mounted_bank_compare" test should check that the partition mounted at a
    particular directory on the target changes after an update.
    """
    return _generate_test_testinfo(
        "mounted_bank_compare", mount_point=mount_point_on_target
    )


def app_bank_compare(app_name):
    """
    Generate testinfo fragment for an "app_bank_compare" test.

    An "app_bank_compare" test should check that an app's "bank" has changed
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
        for chunk in futil.read_chunks(f):
            sha.update(chunk)
    return sha.hexdigest()
