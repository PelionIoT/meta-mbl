SRCREV = "224318f95f9e41f916579a20f3275ff3773f9c94"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/ARMmbed/mbl-u-boot.git;protocol=ssh;nobranch=1"

UBOOT_CONFIG[sd] = "warp7_secure_defconfig,sdcard"

do_install_append() {

	install -d ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/warp7_secure_defconfig/u-boot.cfg ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/warp7_secure_defconfig/board/warp7/imximage.cfg.cfgtmp ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/warp7_secure_defconfig/u-boot.bin ${DEPLOY_DIR_IMAGE}
}

ALLOW_EMPTY_${PN} = "1"
