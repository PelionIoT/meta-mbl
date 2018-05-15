DESCRIPTION="Upstream's U-boot configured for sunxi devices"
DEPENDS += "u-boot-mkimage-native dtc-native "
RDEPENDS_${PN}_append = " mbl-boot-scr"

require recipes-bsp/u-boot/u-boot.inc

PROVIDES += "u-boot"

DEPENDS += "dtc-native"

LICENSE = "GPLv2"

LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

COMPATIBLE_MACHINE = "(sun8i)"

DEFAULT_PREFERENCE_sun8i="1"

SRC_URI = " \
           git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;branch=linaro-bpi \
           "
PV = "v2017.09+git${SRCPV}"
SRCREV = "f3acbea45b9573fc474eab11ced203deb0d1057d"

PE = "2"

PACKAGE_ARCH = "${MACHINE_ARCH}"

UBOOT_CONFIG[sd] = "bananapi_zero_defconfig,sdcard"
S = "${WORKDIR}/git"

SPL_BINARY="spl/sunxi-spl.bin"
UBOOT_MAKE_TARGET="u-boot.bin u-boot.dtb u-boot-signed.itb spl/sunxi-spl.bin"

UBOOT_DTB="sun8i-h2-plus-bananapi-m2-zero.dtb"

do_install_append() {
	UBOOT_SIZE=$(stat -c %s ${B}/u-boot-signed.itb)
	dd if=/dev/zero of=${B}/u-boot-packed.bin count=$(expr 32 \* 1024 \+ ${UBOOT_SIZE}) bs=1
	dd if=${B}/spl/sunxi-spl.bin of=${B}/u-boot-packed.bin
	dd if=${B}/u-boot-signed.itb of=${B}/u-boot-packed.bin bs=1024 seek=32

	install -d ${D}/boot
	install -m 0644 ${B}/u-boot-packed.bin ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/spl/sunxi-spl.bin ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/u-boot-signed.itb ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/u-boot-nodtb.bin ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/u-boot.dtb ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/arch/arm/dts/${UBOOT_DTB} ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/u-boot.its ${DEPLOY_DIR_IMAGE}
}
