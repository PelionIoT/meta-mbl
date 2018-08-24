DESCRIPTION = "Linaro AArch64 toolchain"
LICENSE = "GPL-3.0-with-GCC-exception"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

SRC_URI = " http://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/aarch64-linux-gnu/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu.tar.xz "
SRC_URI[md5sum] = "74451220ef91369da0b6e2b7534b0767"
SRC_URI[sha256sum] = "20181f828e1075f1a493947ff91e82dd578ce9f8638fbdfc39e24b62857d8f8d"

S = "${WORKDIR}/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu"
B = "${WORKDIR}/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu"

BBCLASSEXTEND="native"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"
do_package_qa[noexec] = "1"

do_compile() {
}

do_install() {
    install -d ${D}${base_prefix}/usr/bin/aarch64-linux-gnu
    cp -R ${B}/* ${D}${base_prefix}/usr/bin/aarch64-linux-gnu
}

sysroot_stage_all_append() {
    sysroot_stage_dirs ${D}${base_prefix}/usr ${SYSROOT_DESTDIR}/usr
}

FILES_${PN} = " usr "
