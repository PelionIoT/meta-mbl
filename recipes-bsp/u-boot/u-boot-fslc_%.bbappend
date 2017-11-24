inherit image_sign_mbl
SRCREV = "9d0cacf402425e29a316b09610be2debbf38dc6c"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

DEPENDS += "u-boot-mkimage-native imx7-cst-native warp7-csf-native warp7-keys-native "

SRC_URI = "git://git@github.com/ARMmbed/mbl-u-boot.git;protocol=ssh;nobranch=1"

UBOOT_CONFIG[sd] = "warp7_secure_optee_defconfig,sdcard"

do_compile_append () {
	install -d ${UBOOT_SHARED_DATA}
	cp ${WORKDIR}/build/warp7_secure_optee_defconfig/${UBOOT_CFG} ${UBOOT_SHARED_DATA}
	cp ${WORKDIR}/build/warp7_secure_optee_defconfig/board/warp7/imximage.cfg.cfgtmp ${UBOOT_SHARED_DATA}
}

# u-boot signing data
UBOOT_CSF="u-boot_sign.csf"
UBOOT_ADDR="CONFIG_SYS_TEXT_BASE"

# Common signing data
BOARDNAME="warp7"
UBOOT_WARP_CFG="board/warp7/imximage.cfg.cfgtmp"

_generate_signed_uboot_image() {
    image_sign_mbl_binary ${B}/warp7_secure_optee_defconfig ${BOARDNAME} ${UBOOT_BIN} ${UBOOT_IMX} ${UBOOT_ADDR} ${UBOOT_CSF} imximage.cfg.cfgtmp;
}

do_install_append() {

    _generate_signed_uboot_image
    install -d ${DEPLOY_DIR_IMAGE}
    install -m 0644 ${B}/warp7_secure_optee_defconfig/${UBOOT_IMX}-signed ${DEPLOY_DIR_IMAGE}
}

ALLOW_EMPTY_${PN} = "1"
FILES_${PN} += "/boot/bootscr/boot.scr.imx-signed"
