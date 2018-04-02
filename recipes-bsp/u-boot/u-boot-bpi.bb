DESCRIPTION="Upstream's U-boot configured for sunxi devices"
DEPENDS += "u-boot-mkimage-native dtc-native "
RDEPENDS_${PN}_append = " mbl-boot-scr"

require recipes-bsp/u-boot/u-boot.inc

PROVIDES += "u-boot"

DEPENDS += "dtc-native"

LICENSE = "GPLv2"

LIC_FILES_CHKSUM = "\
file://Licenses/Exceptions;md5=338a7cb1e52d0d1951f83e15319a3fe7 \
file://Licenses/bsd-2-clause.txt;md5=6a31f076f5773aabd8ff86191ad6fdd5 \
file://Licenses/bsd-3-clause.txt;md5=4a1190eac56a9db675d58ebe86eaf50c \
file://Licenses/eCos-2.0.txt;md5=b338cb12196b5175acd3aa63b0a0805c \
file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
file://Licenses/ibm-pibs.txt;md5=c49502a55e35e0a8a1dc271d944d6dba \
file://Licenses/isc.txt;md5=ec65f921308235311f34b79d844587eb \
file://Licenses/lgpl-2.0.txt;md5=5f30f0716dfdd0d91eb439ebec522ec2 \
file://Licenses/lgpl-2.1.txt;md5=4fbd65380cdd255951079008b364516c \
file://Licenses/x11.txt;md5=b46f176c847b8742db02126fb8af92e2 \
"

COMPATIBLE_MACHINE = "(sun4i|sun5i|sun7i|sun8i)"

DEFAULT_PREFERENCE_sun4i="1"
DEFAULT_PREFERENCE_sun5i="1"
DEFAULT_PREFERENCE_sun7i="1"
DEFAULT_PREFERENCE_sun8i="1"

SRC_URI = " \
           git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;branch=linaro-bpi \
           "
PV = "v2017.09+git${SRCPV}"
SRCREV = "313219a7d17aa46cd8886b6c2bd82ab2f0b6ffc1"

PE = "2"

PACKAGE_ARCH = "${MACHINE_ARCH}"

UBOOT_CONFIG[sd] = "bananapi_zero_defconfig,sdcard"
S = "${WORKDIR}/git"

SPL_BINARY="spl/sunxi-spl.bin"
UBOOT_MAKE_TARGET="u-boot.bin u-boot.dtb u-boot-signed.itb spl/sunxi-spl.bin"

UBOOT_DTB="sun8i-h2-plus-bananapi-m2-zero.dtb"

do_install_append() {
	install -d ${D}/boot
	install -m 0644 ${B}/spl/sunxi-spl.bin ${D}/boot
	install -m 0644 ${B}/spl/sunxi-spl.bin ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/u-boot-signed.itb ${D}/boot
	install -m 0644 ${B}/u-boot-signed.itb ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/u-boot-nodtb.bin ${D}/boot
	install -m 0644 ${B}/u-boot-nodtb.bin ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/u-boot.dtb ${D}/boot
	install -m 0644 ${B}/u-boot.dtb ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/arch/arm/dts/${UBOOT_DTB} ${D}/boot
	install -m 0644 ${B}/arch/arm/dts/${UBOOT_DTB} ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/u-boot.its ${D}/boot
	install -m 0644 ${B}/u-boot.its ${DEPLOY_DIR_IMAGE}
}
