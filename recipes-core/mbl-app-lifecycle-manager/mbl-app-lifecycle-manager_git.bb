# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "mbl application lifecycle manager"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE.BSD-3-Clause;md5=1a8858961a0fa364bc79169ca26815db"

SRC_URI = "\
    ${SRC_URI_MBL_CORE_REPO} \
    file://init \
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

inherit update-rc.d
INITSCRIPT_NAME = "${SRCNAME}"
INITSCRIPT_PARAMS = "defaults 91 9"


do_install_append() {
    install -d "${D}${sysconfdir}/init.d"
    install -m 0755 "${WORKDIR}/init" "${D}${sysconfdir}/init.d/${INITSCRIPT_NAME}"
}

# Replace placeholder strings in init script with values of BitBake variables
MBL_VAR_PLACEHOLDER_FILES = "${D}${sysconfdir}/init.d/${INITSCRIPT_NAME}"
inherit mbl-var-placeholders

FILES_${PN} += " \
    ${sysconfdir}/init.d/${INITSCRIPT_NAME} \
"
