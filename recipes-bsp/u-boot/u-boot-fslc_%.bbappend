SRCREV = "902e76534d72702ad1d13948d9f667c7be847bd2"

LIC_FILES_CHKSUM_remove = "file://Licenses/README;md5=30503fd321432fc713238f582193b78e"
LIC_FILES_CHKSUM_append = "file://Licenses/README;md5=a2c678cfd4a4d97135585cad908541c6"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;nobranch=1"

LIC_FILES_CHKSUM = "file://Licenses/README;md5=a2c678cfd4a4d97135585cad908541c6"

do_deploy_append_imx7s-warp-mbl() {

	install -d ${DEPLOYDIR}
	install -m 0644 ${B}/warp7_defconfig/u-boot.cfg ${DEPLOYDIR}
	install -m 0644 ${B}/warp7_defconfig/u-boot.cfgout ${DEPLOYDIR}
	install -m 0644 ${B}/warp7_defconfig/u-boot.bin ${DEPLOYDIR}
}
