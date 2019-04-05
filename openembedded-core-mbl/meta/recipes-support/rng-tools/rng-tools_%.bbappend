# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# make sure the local appending config file will be chosen by prepending and extra local path
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# NIST Randomness Beacon support requires curl which rdepends on (L)GPLv3
# packages. Add an option to configure out the support to remove these
# dependencies.
DEPENDS_remove = "curl"
PACKAGECONFIG[nistbeacon] = ",--without-nistbeacon,curl,curl"

# Ensure rng-tools starts before networking to avoid the networking code
# waiting ages for entropy from /dev/random.
INITSCRIPT_PARAMS = "start 00 2 3 4 5 . stop 30 0 6 1 ."
