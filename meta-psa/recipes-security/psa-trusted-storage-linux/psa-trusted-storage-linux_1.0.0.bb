# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "ARM Platform Security Architecture (PSA) Protected Storage Library"
DEPENDS = ""
HOMEPAGE = "https://github.com/ARMmbed/psa_trusted_storage_linux.git"
DESCRIPTION = "A Linux C library reference implementation of the PSA protected_storage.h API"
SECTION = "libs"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE;md5=302d50a6369f5f22efdb674db908167a \
    file://apache-2.0.txt;md5=3b83ef96387f14655fc854ddc3c6bd57 \
    "

SRC_URI = "git://git@github.com/armmbed/psa_trusted_storage_linux.git;protocol=ssh;nobranch=1"
SRCREV = "2be73f8a50eca10b45f952798e2100afd00a99f2"

PACKAGES =+ "${PN}-example"

PV .= "+git${SRCPV}"
S = "${WORKDIR}/git"

FILES_${PN}-example = "${bindir}"

do_install () {
    oe_runmake install prefix=${D} bindir=${D}${bindir} libdir=${D}${libdir} includedir=${D}${includedir}
}

RDEPENDS_${PN} = "\
    ecryptfs-utils \
    keyutils \
"
