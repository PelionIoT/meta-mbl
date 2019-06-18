# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

##############################################################################
# mbl-boot-scr.bbappend
#
# This recipe adds the boot.cmd location to FILESEXTRAPATHS.
##############################################################################

SUMMARY = "U-boot boot scripts for mbed Linux"
HOMEPAGE = "https://github.com/ARMmbed/meta-mbl"

FILESEXTRAPATHS_append := "${THISDIR}/files:"

inherit noinstall

do_compile_append_imx6ul-pico-mbl() {
    mkimage -A arm -T script -C none -n "Boot script" -d "${WORKDIR}/boot.cmd" boot.scr
}

do_deploy_append_imx6ul-pico-mbl() {
    install -d "${DEPLOY_DIR_IMAGE}"
    install -m 0644 boot.scr ${DEPLOY_DIR_IMAGE}
}

do_compile_append_imx6ul-des0258-mbl() {
    mkimage -A arm -T script -C none -n "Boot script" -d "${WORKDIR}/boot.cmd" boot.scr
}

do_deploy_append_imx6ul-des0258-mbl() {
    install -d "${DEPLOY_DIR_IMAGE}"
    install -m 0644 boot.scr ${DEPLOY_DIR_IMAGE}
}
