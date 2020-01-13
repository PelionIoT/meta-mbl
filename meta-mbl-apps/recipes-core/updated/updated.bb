# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT


SUMMARY = "UpdateD is a daemon which coordinates firmware updates"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE.BSD-3-Clause;md5=1a8858961a0fa364bc79169ca26815db"
SRC_URI = "\
    ${SRC_URI_MBL_CORE_REPO} \
    file://updated.service \
"
SRCREV = "${SRCREV_MBL_CORE_REPO}"
SRCNAME = "updated"
S = "${WORKDIR}/git/firmware-management/${SRCNAME}"

DEPENDS += "systemd protobuf grpc protobuf-native grpc-native spdlog"

inherit cmake
inherit systemd

SYSTEMD_SERVICE_${PN} = "updated.service"

PACKAGECONFIG[release] = ""

UPDATED_LOG_LEVEL = "${@bb.utils.contains('PACKAGECONFIG', 'release', '-l ERROR', '-l INFO', d)}"

do_install_append() {
    install -d "${D}${systemd_unitdir}/system/"
    install -m 0644 "${WORKDIR}/updated.service" "${D}${systemd_unitdir}/system/"
}

MBL_VAR_PLACEHOLDER_FILES = "${D}${systemd_unitdir}/system/updated.service"
inherit mbl-var-placeholders
