# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

DESCRIPTION = "ARM AArch64 toolchain"
LICENSE = "BSD-3-Clause & GPL-2.0 & GPL-3.0 & GPL-3.0-with-GCC-exception & LGPL-2.1 & LGPL-3.0 & MIT"

SRC_URI = " https://developer.arm.com/-/media/Files/downloads/gnu-a/8.2-2019.01/gcc-arm-8.2-2019.01-x86_64-aarch64-linux-gnu.tar.xz;name=pkg1; "
SRC_URI[pkg1.md5sum] = "ed467a18abc7cf81d53c0cf6014b1867"
SRC_URI[pkg1.sha256sum] = "6683d51b0dd61a91ab1e8e478a0a8a50ccb34d5590c84aa36697e956b16f14a1"
DEPENDS += "arm-aarch64-toolchain-license"

# The ARM toolchain tarball contains a number of license files. Check that
# these licenses have not changed from those previously checked.
LIC_FILES_CHKSUM = "\
    file://share/doc/gdb/Copying.html;md5=49d76657ba5b4672a83d377cddd33a6f\
    "

S = "${WORKDIR}/gcc-arm-8.2-2019.01-x86_64-aarch64-linux-gnu"
B = "${WORKDIR}/gcc-arm-8.2-2019.01-x86_64-aarch64-linux-gnu"

BBCLASSEXTEND="native"
INHIBIT_SYSROOT_STRIP = "1"

do_install() {
    install -d ${D}${base_prefix}/usr/bin/aarch64-linux-gnu
    cp -R ${B}/* ${D}${base_prefix}/usr/bin/aarch64-linux-gnu
}

sysroot_stage_all_append() {
    sysroot_stage_dirs ${D}${base_prefix}/usr ${SYSROOT_DESTDIR}/usr
}

FILES_${PN} = " usr "

# It unnecessary to package the native tools so these tasks 
# can be skipped to save time. Also, these tasks currently
# generate errors under some build environments
# (e.g. mbed Linux Jenkins instance).
deltask package
deltask package_qa
deltask packagedata
deltask package_write_ipk
