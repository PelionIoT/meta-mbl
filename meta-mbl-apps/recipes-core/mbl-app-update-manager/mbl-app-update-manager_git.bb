# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "mbl application update manager"
DESCRIPTION="This entity is an application component update installer. It integrates the main update script, mbl-app-manager and mbl-app-lifecycle-manager."
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE.BSD-3-Clause;md5=1a8858961a0fa364bc79169ca26815db"

SRC_URI = " \
    ${SRC_URI_MBL_CORE_REPO} \
    file://mbl-app-update-manager.service \
"
SRCNAME = "mbl-app-update-manager"
SRCREV = "${SRCREV_MBL_CORE_REPO}"
S = "${WORKDIR}/git/firmware-management/${SRCNAME}"

RDEPENDS_${PN} = " \
    python3-core \
    python3-logging \
    mbl-app-manager \
    mbl-app-lifecycle-manager \
"

inherit setuptools3
inherit python3-dir
inherit systemd

SYSTEMD_SERVICE_${PN} = "mbl-app-update-manager.service"

do_install_append() {
    install -d "${D}${systemd_unitdir}/system/"
    install -m 0644 "${WORKDIR}/mbl-app-update-manager.service" "${D}${systemd_unitdir}/system/"
}
