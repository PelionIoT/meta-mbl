require recipes-bsp/u-boot/u-boot.inc
require recipes-bsp/u-boot/u-boot-fslc-common_2017.11.inc

DESCRIPTION = "U-Boot based on mainline U-Boot used by FSL Community BSP in \
order to provide support for some backported features and fixes, or because it \
was submitted for revision and it takes some time to become part of a stable \
version, or because it is not applicable for upstreaming."

DEPENDS_append = " dtc-native"

PROVIDES = "u-boot-imx7-recovery"

# FIXME: Allow linking of 'tools' binaries with native libraries
#        used for generating the boot logo and other tools used
#        during the build process.
EXTRA_OEMAKE += 'HOSTCC="${BUILD_CC} ${BUILD_CPPFLAGS}" \
                 HOSTLDFLAGS="${BUILD_LDFLAGS}" \
                 HOSTSTRIP=true'

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(mxs|mx5|mx6|mx7|vf|use-mainline-bsp)"

SRCREV = "e9f595924a34c75eb3cc571fbc604911460e0fd0"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;nobranch=1"

UBOOT_CONFIG[sd] = "warp7_defconfig,sdcard"

do_deploy_append_imx7s-warp-mbl() {

	install -d ${DEPLOYDIR}
	install -m 0644 ${B}/warp7_defconfig/u-boot.bin ${DEPLOYDIR}/u-boot.bin.recovery
	install -m 0644 ${B}/warp7_defconfig/u-boot.imx ${DEPLOYDIR}/u-boot.imx.recovery
}
