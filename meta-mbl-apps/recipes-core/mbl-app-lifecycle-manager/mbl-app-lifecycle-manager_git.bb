# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "mbl application lifecycle manager"
DESCRIPTION="This service starts applications at boot time. In future, systemd may undertake this role."
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE.BSD-3-Clause;md5=1a8858961a0fa364bc79169ca26815db"

SRCNAME = "mbl-app-lifecycle-manager"
SRC_URI = "\
    ${SRC_URI_MBL_CORE_REPO} \
    file://${SRCNAME}.service \
"
SRCREV = "${SRCREV_MBL_CORE_REPO}"
S = "${WORKDIR}/git/application-framework/${SRCNAME}"

RDEPENDS_${PN} = " \
    python3-core \
    python3-json \
    python3-logging \
    virtual/runc \
"

inherit setuptools3
inherit python3-dir
inherit systemd

SYSTEMD_SERVICE_${PN} = "${SRCNAME}.service"

do_install_append() {
    install -d "${D}${systemd_unitdir}/system/"
    install -m 0644 "${WORKDIR}/${SRCNAME}.service" "${D}${systemd_unitdir}/system/"
}

# Replace placeholder strings in systemd service file with values of BitBake variables
MBL_VAR_PLACEHOLDER_FILES = "${D}${systemd_unitdir}/system/${SRCNAME}.service"
inherit mbl-var-placeholders
