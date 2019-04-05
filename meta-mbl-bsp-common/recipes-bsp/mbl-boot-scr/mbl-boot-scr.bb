# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

##############################################################################
# mbl-boot-scr.bb
#
# This recipe is to manage MBL specific operations for FIT image preparation,
# including the following:
# - Copy the MACHINE specific u-boot boot.cmd boot script to the
#   DEPLOY_DIR_IMAGE for use by mbl-fitimage.bbclass. A platform specific
#   mbl-boot-scr.bbappend should add the location of the boot.cmd file to the
#   FILESEXTRAPATHS.
##############################################################################

SUMMARY = "U-boot boot scripts for mbed Linux"
HOMEPAGE = "https://github.com/ARMmbed/meta-mbl"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://boot.cmd"

inherit mbl-artifact-names

do_compile() {
}

inherit deploy

do_deploy() {
    install -m 0644 ${WORKDIR}/${MBL_UBOOT_CMD_FILENAME} ${DEPLOYDIR}
}

addtask do_deploy after do_compile before do_build

inherit noinstall
