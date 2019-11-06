# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""
Functions for creating sw-description files.

sw-description files describe the contents of update payloads in the format
expected by swupdate.
"""

import libconf


def create_swdesc_file(images, path):
    """Create a sw-description file for an update payload."""
    with open(str(path), mode="wt") as f:
        libconf.dump(_generate_swdesc(images), f)


def _generate_swdesc_for_image(image):
    return {"type": image.image_type, "filename": str(image.archived_path)}


def _generate_swdesc(images):
    return {
        "software": {
            "version": "0.0.0",
            "images": tuple(
                _generate_swdesc_for_image(image) for image in images
            ),
        }
    }
