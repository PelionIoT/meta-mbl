SUMMARY = "U-boot boot scripts for Freescale IMX WaRP7"
DESCRIPTION = "boot.scr Freescale IMX WaRP7"
SECTION = "base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"
DEPENDS += "u-boot-fslc u-boot-mkimage-native imx7-cst-native warp7-csf-native warp7-keys-native "

PACKAGE_ARCH = "all"

inherit image_sign_mbl

# Common signing data
BOARDNAME="warp7"
UBOOT_WARP_CFG="board/warp7/imximage.cfg.cfgtmp"
UBOOT_CSF="u-boot_sign.csf"
BOOT_SCR="boot.scr"
BOOT_IMX="boot.scr.imx"
BOOT_ADDR="CONFIG_LOADADDR"

SRC_URI = "file://boot.scr.txt;name=file1"

do_compile() {
    uboot-mkimage -A arm -O linux -T script -C none \
            -a 0 -e 0 -n boot -d "${WORKDIR}/boot.scr.txt" "${B}/boot.scr"
}

_generate_signed_bootscr_image() {
	image_sign_mbl_binary ${D}/boot/bootscr ${BOARDNAME} ${BOOT_SCR} ${BOOT_IMX} ${BOOT_ADDR} ${UBOOT_CSF} imximage.cfg.cfgtmp;
}

do_install() {
    install -D -m 0644 "${B}/boot.scr" "${D}/boot/bootscr/boot.scr"

    _generate_signed_bootscr_image
}

FILES_${PN} = "/boot/bootscr/boot.scr"
FILES_${PN} += "/boot/bootscr/boot.scr.imx-signed"

COMPATIBLE_MACHINE = "(imx7s-warp)"
