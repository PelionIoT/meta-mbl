# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

###############################################################################
# mbl-console-image.bb
#   This file is the mbed linux OpenEmbedded recipe for building a minimal 
#   uboot/kernel/filesystem image 
###############################################################################
SUMMARY = "Mbed Linux Basic Minimal Image"

###############################################################################
# IMAGE_INSTALL: 
#   Specify the packages installed in the distribution images prior to
#   inheriting from core-image to override the default behaviour. 
#   
#     packagegroup-core-boot        Essential packages to boot minimal sysmtem.
#     packagegroup-mbl              mbed linux packages added for this image.
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
	packagegroup-mbl \
	${CORE_IMAGE_EXTRA_INSTALL}"

IMAGE_LINGUAS = " "
IMAGE_FEATURES += "debug-tweaks"

LICENSE = "MIT"
HOMEPAGE = "https://github.com/ARMmbed/meta-mbl"

do_image_wic[depends] += "virtual/atf:do_deploy"

inherit core-image extrausers

IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "" ,d)}"

# Add a root account with empty password
EXTRA_USERS_PARAMS = "useradd -p '' root;"

# No GPLv3 allowed in this image
IMAGE_LICENSE_CHECKER_BLACKLIST = "GPL-3.0 LGPL-3.0 AGPL-3.0"
inherit image-license-checker image-signing image-verity key-generation



