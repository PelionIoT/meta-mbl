SUMMARY = "U-boot boot scripts for mbed Linux"
HOMEPAGE = "https://github.com/ARMmbed/meta-mbl"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
DEPENDS = "u-boot-mkimage-native dtc-native mbl-console-image-initramfs"
RCONFLICTS_${PN} = "rpi-u-boot-scr"

FILESEXTRAPATHS_append := "${THISDIR}/files:"

SRC_URI = "file://boot.cmd"

SRC_URI_append := " file://boot.its"

do_compile[depends] += "virtual/kernel:do_deploy"

do_compile() {
    uboot-mkimage -A arm -T script -C none -n "Boot script" -d "${WORKDIR}/boot.cmd" boot.scr
}

do_compile_append_imx7s-warp() {
    openssl genrsa -out ${DEPLOY_DIR_IMAGE}/mblkey.key 2048
    openssl req -batch -new -x509 -key ${DEPLOY_DIR_IMAGE}/mblkey.key -out ${DEPLOY_DIR_IMAGE}/mblkey.crt
    ln -sf ${DEPLOY_DIR_IMAGE}/mblkey.key mblkey.key
    ln -sf ${DEPLOY_DIR_IMAGE}/mblkey.crt mblkey.crt
    ln -sf ${DEPLOY_DIR_IMAGE}/zImage ${WORKDIR}/zImage
    ln -sf ${DEPLOY_DIR_IMAGE}/mbl-console-image-initramfs-imx7s-warp-mbl.cpio.gz ${WORKDIR}/mbl-console-image-initramfs-imx7s-warp-mbl.cpio.gz
    uboot-mkimage -f "${WORKDIR}/boot.its" -k ${B} boot.scr
}

do_compile_append_raspberrypi3-mbl() {
    ln -sf ${DEPLOY_DIR_IMAGE}/zImage ${WORKDIR}/zImage
    ln -sf ${DEPLOY_DIR_IMAGE}/bcm2710-rpi-3-b-plus.dtb ${WORKDIR}/bcm2710-rpi-3-b-plus.dtb
    ln -sf ${DEPLOY_DIR_IMAGE}/mbl-console-image-initramfs-raspberrypi3-mbl.cpio.gz ${WORKDIR}/mbl-console-image-initramfs-raspberrypi3-mbl.cpio.gz
    uboot-mkimage -f ${WORKDIR}/boot.its -k ${B} boot.scr
}

inherit deploy

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 boot.scr ${DEPLOYDIR}
}

addtask do_deploy after do_compile before do_build
