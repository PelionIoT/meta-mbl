# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# This file sets default PACKAGECONFIG values for specific packages.
# These values can be used in recipes/classes to take specific actions
# when building its packages.

# NOTE: PACKAGECONFIG VARIABLES PLACEHOLDERS FOR FUTURE USE

# In Production images we want the following pakages to be silent
# and don't print any messages into the serial console.
PACKAGECONFIG_append_pn-u-boot-fslc = " silent"
PACKAGECONFIG_append_pn-atf-${MACHINE} = " silent"
