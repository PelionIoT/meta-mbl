# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "mbl firmware update manager"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE.BSD-3-Clause;md5=1a8858961a0fa364bc79169ca26815db"

SRC_URI = "\
    ${SRC_URI_MBL_CORE_REPO} \
"
SRCNAME = "mbl-firmware-update-manager"
SRCREV = "${SRCREV_MBL_CORE_REPO}"
S = "${WORKDIR}/git/firmware-management/${SRCNAME}"

RDEPENDS_${PN} = " \
    python3-core \
    python3-logging \
    mbl-firmware-update-header-util \
"

inherit setuptools3
inherit python3-dir
