# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

inherit mbl-distro-image-common

IMAGE_INSTALL += "\
    packagegroup-mbl-production \
    "

MBL_PRODUCTION_IMAGE_FEATURES_BLACKLIST ?= "debug-tweaks"

python __anonymous () {
    mbl_image_features_blacklist = d.getVar('MBL_PRODUCTION_IMAGE_FEATURES_BLACKLIST', True)
    if mbl_image_features_blacklist and bb.utils.contains_any('IMAGE_FEATURES', mbl_image_features_blacklist.split(), True, False, d):
        features_intersection = list(set(mbl_image_features_blacklist.split()) & set(d.getVar('IMAGE_FEATURES', True).split()))
        raise bb.parse.SkipRecipe("Mbed Linux OS production image blacklists the following added IMAGE_FEATURES {}.".format(features_intersection))
}
