# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

inherit mbl-distro-image-common

IMAGE_INSTALL += "\
    packagegroup-mbl-production \
    packagegroup-mbl-development \
    "

IMAGE_FEATURES += "debug-tweaks"
