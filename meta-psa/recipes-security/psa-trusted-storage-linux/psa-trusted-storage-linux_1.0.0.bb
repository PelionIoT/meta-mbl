# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "ARM Platform Security Architecture (PSA) Protected Storage Library"
HOMEPAGE = "https://github.com/ARMmbed/psa_trusted_storage_linux.git"
DESCRIPTION = "A Linux C library reference implementation of the PSA protected_storage.h API"
SECTION = "libs"

DEPENDS = ""
RDEPENDS_${PN}-test += "${PN}"
RDEPENDS_${PN} = "\
    ecryptfs-utils \
    keyutils \
    "

inherit systemd

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE;md5=302d50a6369f5f22efdb674db908167a \
    file://apache-2.0.txt;md5=3b83ef96387f14655fc854ddc3c6bd57 \
    "

SRC_URI = "git://git@github.com/armmbed/psa_trusted_storage_linux.git;protocol=ssh;nobranch=1"
SRCREV = "7b67400f58dddc4f5ff419df3575749b84b42abf"

PACKAGES =+ "${PN}-test"

PV .= "+git${SRCPV}"
S = "${WORKDIR}/git"

FILES_${PN} += "${bindir}/psa-ecryptfs-init.sh"
FILES_${PN}-test = "${bindir}/psa-storage-example-app"

do_install () {
    oe_runmake install prefix=${D} bindir=${D}${bindir} libdir=${D}${libdir} includedir=${D}${includedir} systemd_system_unitdir=${D}${systemd_system_unitdir}
}

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE_${PN} = "psa-ecryptfs.service"
