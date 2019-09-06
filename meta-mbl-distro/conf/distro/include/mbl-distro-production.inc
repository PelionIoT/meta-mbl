# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# This file sets default PACKAGECONFIG values for specific packages.
# These values can be used in recipes/classes to take specific actions
# when building its packages.

# In Production images we want the following pakages to be silent
# and don't print any messages into the serial console.

# Possible values for u-boot recipes PACKAGECONFIG:
# "noconsole": disables u-boot console only
# "silent": disables u-boot and kernel consoles
PACKAGECONFIG_append_pn-u-boot-fslc = " silent minimal"
PACKAGECONFIG_append_pn-u-boot-imx = " silent minimal"
PACKAGECONFIG_append_pn-u-boot = " silent minimal"

PACKAGECONFIG_append_pn-atf-${MACHINE} = " silent"

PACKAGECONFIG_append_pn-optee-os = " silent"

# For production images we want to set the minimum password length to 12
# characters.
MBL_PASS_MIN_LEN = "12"
