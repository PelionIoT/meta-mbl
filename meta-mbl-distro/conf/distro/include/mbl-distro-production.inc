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
# "minimal": disables network booting, fastboot, usb mass storage and,
#            device firmware upgrade(DFU)
UBOOT_PRODUCTION_CFG ?= "silent minimal"
PACKAGECONFIG_append_pn-u-boot-fslc = " ${UBOOT_PRODUCTION_CFG}"
PACKAGECONFIG_append_pn-u-boot-imx = " ${UBOOT_PRODUCTION_CFG}"
PACKAGECONFIG_append_pn-u-boot = " ${UBOOT_PRODUCTION_CFG}"

# Possible value for atf recipes PACKAGECONFIG:
# "silent": only warning level messages are printed out
ATF_PRODUCTION_CFG ?= "silent"
PACKAGECONFIG_append_pn-atf-${MACHINE} = " ${ATF_PRODUCTION_CFG}"

# Possible value for optee-os recipe PACKAGECONFIG:
# "silent": only error level messages are printed out
OPTEE_PRODUCTION_CFG ?= "silent"
PACKAGECONFIG_append_pn-optee-os = " ${OPTEE_PRODUCTION_CFG}"

# For production images we want to set the minimum password length to 12
# characters.
MBL_PASS_MIN_LEN = "12"
