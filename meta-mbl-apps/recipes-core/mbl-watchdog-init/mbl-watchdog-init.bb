# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT


SUMMARY = "Set up the hardware watchdog"
LICENSE = "BSD-3-Clause"
DESCRIPTION = "\
    Set the hardware watchdog timeout. \
    The purpose is to enable the watchdog before trying to boot into the rootfs.\
"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE.BSD-3-Clause;md5=1a8858961a0fa364bc79169ca26815db"
SRC_URI = "\
    ${SRC_URI_MBL_CORE_REPO} \
"
SRCREV = "${SRCREV_MBL_CORE_REPO}"
SRCNAME = "mbl-watchdog-init"
S = "${WORKDIR}/git/firmware-management/${SRCNAME}"

inherit cmake
