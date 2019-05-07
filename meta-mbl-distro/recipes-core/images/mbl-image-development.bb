# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

###############################################################################
# mbl-image-development.bb
#   This file is the mbed linux OpenEmbedded recipe for building a minimal 
#   uboot/kernel/filesystem image including test packages. 
###############################################################################

require mbl-image-production.bb

SUMMARY = "Mbed Linux Basic Minimal Image With Test Packages"
DESCRIPTION = "Image with development, debug, SDK and test support."

###############################################################################
# Uncomment the following lines as required to include the feature in the test
# image. Note, there is a maximum image size of ~2.5GB which is exceeded if all
# features are included.
###############################################################################

# IMAGE_FEATURES += " dev-pkgs"
# IMAGE_FEATURES += " ptest-pkgs"
# IMAGE_FEATURES += " tools-sdk"
# IMAGE_FEATURES += " tools-debug"
# IMAGE_FEATURES += " tools-testapps"

IMAGE_INSTALL += " \
	packagegroup-mbl-development \
	"

# No GPLv3 allowed in the non-rootfs parts of the image
IMAGE_LICENSE_CHECKER_NON_ROOTFS_BLACKLIST = "GPL-3.0 LGPL-3.0 AGPL-3.0"
inherit license-json
inherit image-license-checker

# Temporary workaround to fix do_image "systemctl: not found" error
do_image[depends] += "systemd-systemctl-native:do_populate_sysroot"
