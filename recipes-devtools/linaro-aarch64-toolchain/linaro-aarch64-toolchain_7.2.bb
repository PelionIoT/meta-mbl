DESCRIPTION = "Linaro AArch64 toolchain"
LICENSE = "BSD-3-Clause & GPL-2.0 & GPL-3.0 & GPL-3.0-with-GCC-exception & LGPL-2.1 & LGPL-3.0 & MIT"

SRC_URI = " http://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/aarch64-linux-gnu/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu.tar.xz;name=pkg1; "
SRC_URI[pkg1.md5sum] = "74451220ef91369da0b6e2b7534b0767"
SRC_URI[pkg1.sha256sum] = "20181f828e1075f1a493947ff91e82dd578ce9f8638fbdfc39e24b62857d8f8d"
DEPENDS += "linaro-aarch64-toolchain-license"

# The Linaro toolchain tarball contains a number of license files. Check that
# these licenses have not changed from those previously checked.
LIC_FILES_CHKSUM = "\
    file://share/doc/libgomp.html/Copying.html;md5=71b03b87f3ec16b1070c56d7064bbd00\
    file://share/doc/gdb/gdb/Copying.html;md5=8f99b808f67a9b03df78eb24c5534578\
    file://share/doc/mpfr/COPYING;md5=d32239bcb673463ab874e80d47fae504\
    file://share/doc/mpfr/COPYING.LESSER;md5=6a6a8e020838b23406c81b19c1d46df6\
    file://share/doc/gfortran/Copying.html;md5=f3deb24992eb843f73308d2fc0663259\
    file://share/doc/gccint/Copying.html;md5=b0b9ee453db9dd117f4398e1d31b1e2a\
    file://share/doc/gcc/Copying.html;md5=4d3dd12c455cd0ef6a53bead7defe99a\
    "

S = "${WORKDIR}/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu"
B = "${WORKDIR}/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu"

BBCLASSEXTEND="native"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

do_install() {
    install -d ${D}${base_prefix}/usr/bin/aarch64-linux-gnu
    cp -R ${B}/* ${D}${base_prefix}/usr/bin/aarch64-linux-gnu
}

sysroot_stage_all_append() {
    sysroot_stage_dirs ${D}${base_prefix}/usr ${SYSROOT_DESTDIR}/usr
}

FILES_${PN} = " usr "
