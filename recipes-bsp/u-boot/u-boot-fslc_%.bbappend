SRCREV = "902e76534d72702ad1d13948d9f667c7be847bd2"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;nobranch=1"

UBOOT_CONFIG[sd] = "warp7_defconfig,sdcard"

do_deploy_append_imx7s-warp-mbl() {

	install -d ${DEPLOYDIR}
	install -m 0644 ${B}/warp7_defconfig/u-boot.cfg ${DEPLOYDIR}
	install -m 0644 ${B}/warp7_defconfig/board/warp7/imximage.cfg.cfgtmp ${DEPLOYDIR}
	install -m 0644 ${B}/warp7_defconfig/u-boot.bin ${DEPLOYDIR}
}
