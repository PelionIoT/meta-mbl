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
