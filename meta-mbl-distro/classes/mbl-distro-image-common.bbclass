# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# By default no GPLv3 allowed in the non-rootfs parts of the image
IMAGE_LICENSE_CHECKER_NON_ROOTFS_BLACKLIST ?= "GPL-3.0 LGPL-3.0 AGPL-3.0"

# Images based on the MBL distribution and secure boot should inherit from this
# class

###############################################################################
# IMAGE_INSTALL:
#   Specify the packages installed in the distribution images prior to
#   inheriting from core-image to override the default behaviour.
#
###############################################################################

IMAGE_INSTALL = "\
    packagegroup-core-boot \
    packagegroup-base \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    "

IMAGE_LINGUAS = " "

# Make sure we generate an initramfs image license manifest.
do_populate_lic_deploy[depends] += "${@ "${INITRAMFS_IMAGE}:do_populate_lic_deploy" if d.getVar('INITRAMFS_IMAGE') else "" }"

IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "" ,d)}"

inherit core-image
inherit mbl-secure-boot-image
inherit mbl-firmware-update-header
inherit image-license-checker
inherit license-json
inherit mbl-external-ssh-pub-key
