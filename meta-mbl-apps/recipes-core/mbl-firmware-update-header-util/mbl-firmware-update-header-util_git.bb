# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "MBL firmware update header library"
DESCRIPTION="This component reads/writes the HEADER file that comes with an update payload. The header contains info about an update (e.g. hash of payload, manifest version)."
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE.BSD-3-Clause;md5=1a8858961a0fa364bc79169ca26815db"

SRC_URI = "${SRC_URI_MBL_CORE_REPO}"
SRCREV = "${SRCREV_MBL_CORE_REPO}"
S = "${WORKDIR}/git/firmware-management/mbl-firmware-update-header-util"

RDEPENDS_${PN} = "python3-core"

inherit setuptools3
inherit python3-dir

BBCLASSEXTEND = "native"
