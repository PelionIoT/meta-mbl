# Based on: meta-initramfs/recipes-bsp/images/initramfs-debug-image.bb
# In open-source project: http://git.openembedded.org/meta-openembedded
#
# Original file: No copyright notice was included
# Modifications: Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

DESCRIPTION = "Small image capable of booting a device. The kernel includes \
the Minimal RAM-based Initial Root Filesystem (initramfs). This image includes \
initramfs script for switching to rootfs. Later on we will use this script to \
verify signatures and activating dm-verity."

PACKAGE_INSTALL = "mbl-initramfs-init util-linux-findfs busybox"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""

export IMAGE_BASENAME = "mbl-console-image-initramfs"
IMAGE_LINGUAS = ""

LICENSE = "MIT"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
inherit core-image

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

NO_RECOMMENDATIONS = "1"

# EXTRA_IMAGEDEPENDS may be set to include atf-* in the <MACIHNE>.conf file
#  which is required for mbl-console-image. However, in the case of
#  mbl-console-image-initramfs for atf-warp7 it creates an unwanted circular
#  dependency. There EXTRA_IMAGEDEPENDS is therefore cleared in mbl-console-image-initramfs
#  to stop this circular dependency being formed.
EXTRA_IMAGEDEPENDS = ""
