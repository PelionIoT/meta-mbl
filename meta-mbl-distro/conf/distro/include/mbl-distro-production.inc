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

# The MBL_PRODUCTION_ETH_DBG variable controls whether or not we want
# the production images to have an (usbgadget) ethernet debug interface
# and applies specific PACKAGECONFIG to the following packages.
# The debug interface name is set in the ${MACHINE}.conf file via
# MBL_DBG_IFNAME variable.
MBL_PRODUCTION_ETH_DBG ?= "1"
PACKAGECONFIG_append_pn-packagegroup-mbl-production = " ${@bb.utils.contains('MBL_PRODUCTION_ETH_DBG', '1', 'production-eth-dbg', '', d)}"
PACKAGECONFIG_pn-systemd-net-conf = " ${@bb.utils.contains('MBL_PRODUCTION_ETH_DBG', '1', 'eth-dbg-only', '', d)}"
PACKAGECONFIG_append_pn-dropbear = " ${@bb.utils.contains('MBL_PRODUCTION_ETH_DBG', '1', 'eth-dbg-only', '', d)}"
