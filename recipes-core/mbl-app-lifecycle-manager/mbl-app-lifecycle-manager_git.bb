# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "mbl application lifecycle manager"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE.BSD-3-Clause;md5=1a8858961a0fa364bc79169ca26815db"

SRC_URI = "\
    ${SRC_URI_MBL_CORE_REPO} \
    file://mbl-app-lifecycle-manager-init.sh \
    file://mbl-app-lifecycle-manager.service \
"
SRCNAME = "mbl-app-lifecycle-manager"
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

SYSTEMD_SERVICE_${PN} = "mbl-app-lifecycle-manager.service"

do_install_append() {
    install -d "${D}/opt/arm"
    install -m 0755 "${WORKDIR}/mbl-app-lifecycle-manager-init.sh" "${D}/opt/arm"

    install -d "${D}${systemd_unitdir}/system/"
    install -m 0644 "${WORKDIR}/mbl-app-lifecycle-manager.service" "${D}${systemd_unitdir}/system/"

}

# Replace placeholder strings in init script with values of BitBake variables
MBL_VAR_PLACEHOLDER_FILES = "${D}/opt/arm/mbl-app-lifecycle-manager-init.sh"
inherit mbl-var-placeholders

FILES_${PN} += " \
    /opt/arm/mbl-app-lifecycle-manager-init.sh \
"
