inherit image_sign_mbl
SRCREV = "9d0cacf402425e29a316b09610be2debbf38dc6c"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/ARMmbed/mbl-u-boot.git;protocol=ssh;nobranch=1"

UBOOT_CONFIG[sd] = "warp7_secure_optee_defconfig,sdcard"

do_compile_append () {
	install -d ${UBOOT_SHARED_DATA}
	cp ${WORKDIR}/build/warp7_secure_optee_defconfig/${UBOOT_BIN} ${UBOOT_SHARED_DATA}
	cp ${WORKDIR}/build/warp7_secure_optee_defconfig/${UBOOT_CFG} ${UBOOT_SHARED_DATA}
	cp ${WORKDIR}/build/warp7_secure_optee_defconfig/board/warp7/imximage.cfg.cfgtmp ${UBOOT_SHARED_DATA}
}
