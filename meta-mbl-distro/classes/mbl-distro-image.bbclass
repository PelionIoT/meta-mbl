# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Images based on the MBL distribution and secure boot should inherit from this
# class

###############################################################################
# IMAGE_INSTALL: 
#   Specify the packages installed in the distribution images prior to
#   inheriting from core-image to override the default behaviour.
#
#     packagegroup-core-boot        Essential packages to boot minimal sysmtem.
#     packagegroup-mbl-production   mbed linux packages added for this image.
#     CORE_IMAGE_EXTRA_INSTALL      Symbol conventionally defined in local.conf
#                                   to add extra packages.
#
# IMAGE_FEATURES: specify additional packages
#   debug-tweaks
#       Included in image so root has empty password.The extrausers class
#       in also used so EXTRA_USERS_PARAMS can specify the empty password.
###############################################################################
IMAGE_INSTALL = "\
	packagegroup-core-boot \
	packagegroup-base \
	packagegroup-mbl-production \
	packagegroup-mbl-development \
	${CORE_IMAGE_EXTRA_INSTALL}"

IMAGE_LINGUAS = " "
IMAGE_FEATURES += "debug-tweaks"

# Make sure we generate an initramfs image license manifest.
do_populate_lic_deploy[depends] += "${@ "${INITRAMFS_IMAGE}:do_populate_lic_deploy" if d.getVar('INITRAMFS_IMAGE') else "" }"

IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "" ,d)}"

# Add a root account with empty password
EXTRA_USERS_PARAMS = "useradd -p '' root;"

inherit core-image
inherit mbl-secure-boot-image
inherit extrausers
inherit image-signing
inherit image-verity
inherit key-generation
inherit mbl-firmware-update-header
inherit image-license-checker
inherit license-json
