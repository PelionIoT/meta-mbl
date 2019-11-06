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

SRC_URI = " \
    git://git@github.com/armmbed/psa_trusted_storage_linux.git;protocol=ssh;nobranch=1 \
    file://psa-ecryptfs.service \
    file://psa-ecryptfs-init.sh \
    "

SRCREV = "2be73f8a50eca10b45f952798e2100afd00a99f2"

PACKAGES =+ "${PN}-test"

PV .= "+git${SRCPV}"
S = "${WORKDIR}/git"

FILES_${PN} += "${bindir}/psa-ecryptfs-init.sh"
FILES_${PN}-test = "${bindir}/psa-storage-example-app"

do_install () {
    oe_runmake install prefix=${D} bindir=${D}${bindir} libdir=${D}${libdir} includedir=${D}${includedir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -D -m 0644 ${WORKDIR}/psa-ecryptfs.service ${D}${systemd_system_unitdir}/psa-ecryptfs.service
        install -D -m 0755 ${WORKDIR}/psa-ecryptfs-init.sh ${D}${bindir}/psa-ecryptfs-init.sh
    fi
}

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE_${PN} = "psa-ecryptfs.service"
