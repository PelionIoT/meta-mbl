# Based on: meta-initramfs/recipes-bsp/images/initramfs-debug-image.bb
# In open-source project: http://git.openembedded.org/meta-openembedded
#
# Original file: No copyright notice was included
# Modifications: Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

DESCRIPTION = "Small image capable of booting a device. The kernel includes \
the Minimal RAM-based Initial Root Filesystem (initramfs). This image includes \
initramfs script for switching to rootfs."

PACKAGE_INSTALL = "mbl-initramfs-init"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""

export IMAGE_BASENAME = "mbl-image-initramfs"
IMAGE_LINGUAS = ""

LICENSE = "MIT"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
inherit core-image

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

# Tell the "image" base class that this image does not have a dependency on the
# kernel. Otherwise we'll end up with the kernel and some other dependencies
# listed in the initramfs's image_license.manifest
KERNELDEPMODDEPEND = ""

NO_RECOMMENDATIONS = "1"

# No GPLv3 allowed anywhere in this image
IMAGE_LICENSE_CHECKER_NON_ROOTFS_BLACKLIST = "GPL-3.0 LGPL-3.0 AGPL-3.0"
IMAGE_LICENSE_CHECKER_ROOTFS_BLACKLIST = "GPL-3.0 LGPL-3.0 AGPL-3.0"

inherit license-json
inherit image-license-checker
