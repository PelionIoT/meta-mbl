# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SRCREV = "d719ae84d09af63e511dbea5228e34ed837cbfa6"
PV = "6.8"

# NIST Randomness Beacon support requires curl which rdepends on (L)GPLv3
# packages. Add an option to configure out the support to remove these
# dependencies.
DEPENDS_remove = "curl"
PACKAGECONFIG[nistbeacon] = ",--without-nistbeacon,curl,curl"
