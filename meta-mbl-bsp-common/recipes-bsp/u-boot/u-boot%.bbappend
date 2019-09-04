# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://0001-menuconfig-check-lxdiaglog.sh-Allow-specification-of.patch \
    file://0001-config-env-nowhere-mbl.cfg \
    ${@bb.utils.contains('PACKAGECONFIG','noconsole',' file://0002-config-silent-console-mbl.cfg','',d)} \
    ${@bb.utils.contains('PACKAGECONFIG','silent',' file://0003-config-all-silent-mbl.cfg','',d)} \
    ${@bb.utils.contains('PACKAGECONFIG','minimal',' file://0004-disable-development-services.cfg','',d)} \
    "

# Possible values for u-boot recipes PACKAGECONFIG:
# "noconsole": disables u-boot console only
# "silent": disables u-boot and kernel consoles
PACKAGECONFIG[noconsole] = ""
PACKAGECONFIG[silent] = ""
PACKAGECONFIG[minimal] = ""

# Default partitions to read the boot.scr (FIT image)
UBOOT_DEFAULT_BOOT_PARTITION ?= "1"

python __anonymous() {
    if bb.utils.contains('PACKAGECONFIG','noconsole', True, False, d) and bb.utils.contains('PACKAGECONFIG','silent', True, False, d):
        raise bb.parse.SkipRecipe("The u-boot PACKAGECONFIG options 'noconsole' and 'silent' are mutually exclusive")
}
