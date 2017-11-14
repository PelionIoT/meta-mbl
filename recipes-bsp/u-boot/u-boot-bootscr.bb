SUMMARY = "Freescale IMX WaRP7 bootscr"
DESCRIPTION = "boot.scr Freescale IMX WaRP7"
SECTION = "base"
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"
DEPENDS += "u-boot-mkimage-native"

BB_STRICT_CHECKSUM = "0"
SRC_URI = "file://boot.scr.txt;name=file1"

do_compile() {
    uboot-mkimage -A arm -O linux -T script -C none \
            -a 0 -e 0 -n boot -d ${WORKDIR}/boot.scr.txt ${WORKDIR}/boot.scr
}

do_install() {
    install -d ${D}/boot/bootscr
    
    cp -rfv ${WORKDIR}/boot.scr ${D}/boot/bootscr
}

ALLOW_EMPTY_${PN} = "1"
FILES_${PN} = "/boot/bootscr/boot.scr"

COMPATIBLE_MACHINE = "(imx7s-warp)"
