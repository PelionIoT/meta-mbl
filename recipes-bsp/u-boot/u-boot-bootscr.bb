SUMMARY = "Freescale IMX WaRP7 bootscr"
DESCRIPTION = "boot.scr Freescale IMX WaRP7"
SECTION = "base"
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"
DEPENDS += "u-boot-mkimage-native imx7-cst-native warp7-csf-native warp7-keys-native "

inherit image_sign_mbl

# Common signing data
BOARDNAME="warp7"
UBOOT_WARP_CFG="board/warp7/imximage.cfg.cfgtmp"
UBOOT_CSF="u-boot_sign.csf"
BOOT_SCR="boot.scr"
BOOT_IMX="boot.scr.imx"
BOOT_ADDR="CONFIG_LOADADDR"


BB_STRICT_CHECKSUM = "0"
SRC_URI = "file://boot.scr.txt;name=file1"

do_compile() {
    uboot-mkimage -A arm -O linux -T script -C none \
            -a 0 -e 0 -n boot -d ${WORKDIR}/boot.scr.txt ${WORKDIR}/boot.scr
}

_generate_signed_bootscr_image() {
	image_sign_mbl_binary ${D}/boot/bootscr ${BOARDNAME} ${BOOT_SCR} ${BOOT_IMX} ${BOOT_ADDR} ${UBOOT_CSF} imximage.cfg.cfgtmp;
}

do_install() {
    install -d ${D}/boot/bootscr

    cp -rfv ${WORKDIR}/${BOOT_SCR} ${D}/boot/bootscr
    _generate_signed_bootscr_image
}

ALLOW_EMPTY_${PN} = "1"
FILES_${PN} = "/boot/bootscr/boot.scr"
FILES_${PN} += "/boot/bootscr/boot.scr.imx-signed"

COMPATIBLE_MACHINE = "(imx7s-warp)"
