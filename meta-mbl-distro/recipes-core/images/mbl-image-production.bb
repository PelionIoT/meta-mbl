# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

###############################################################################
# mbl-image-production.bb
#   This file is the mbed linux OpenEmbedded recipe for building a minimal
#   uboot/kernel/filesystem image only including production packages.
###############################################################################
inherit mbl-distro-image-production

SUMMARY = "Mbed Linux OS basic minimal image with production packages"
DESCRIPTION = "Mbed Linux OS basic minimal image with production packages"
HOMEPAGE = "https://github.com/ARMmbed/meta-mbl"
