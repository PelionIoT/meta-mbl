# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# MBL_UBOOT_VERSION should be updated to match version pointed to by SRCREV
MBL_UBOOT_VERSION = "2018.11-rc1"
MBL_UBOOT_VERSION_imx6ul-pico-mbl = "v2019.10-rc1"

inherit mbl-uboot-sign

SRCREV = "c0c4ee5fce01ec0818c4f27ce029d9b16c8849ad"
SRCREV_imx6ul-pico-mbl = "ee3b9f43dfdde29ba939342bbdc22a0549015979"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;nobranch=1 \
           ${@bb.utils.contains_any('PACKAGECONFIG','noconsole silent',' file://0002-set-silent-envs.patch','',d)} \
          "

SRC_URI_append_imx7d-pico-mbl = " \
           ${@bb.utils.contains('PACKAGECONFIG','minimal',' file://0001-pico7-disable-PXE-and-DHCP-boot.patch','',d)} \
	   "
LIC_FILES_CHKSUM = "file://Licenses/README;md5=30503fd321432fc713238f582193b78e"

DEPENDS += "flex-native bison-native"

do_configure_prepend_imx7s-warp-mbl() {
    # change default boot partition
    sed -i 's/[#]define[[:space:]]*CONFIG_SYS_MMC_IMG_LOAD_PART[[:space:]]*.*/#define CONFIG_SYS_MMC_IMG_LOAD_PART ${UBOOT_DEFAULT_BOOT_PARTITION}/' ${S}/include/configs/warp7.h
}

do_configure_prepend_imx7d-pico-mbl() {
    # change default boot partition
    sed -i 's/[#]define[[:space:]]*CONFIG_SYS_MMC_IMG_LOAD_PART[[:space:]]*.*/#define CONFIG_SYS_MMC_IMG_LOAD_PART ${UBOOT_DEFAULT_BOOT_PARTITION}/' ${S}/include/configs/pico-imx7d.h
}

do_compile_append_imx7s-warp-mbl() {
	# Copy device tree to default name for fit image signature verification usage.
	cp ${B}/dts/dt.dtb ${B}/${UBOOT_DTB_BINARY}
	# Generate u-boot-dtb.cfgout for board early initlization.
	oe_runmake u-boot-dtb.imx
}

DCD_FILE_PATH_imx7s-warp-mbl = "${B}"
DCD_FILE_PATH_imx7d-pico-mbl = "${B}"
DCD_FILE_PATH_imx6ul-pico-mbl = "${B}"
DCD_FILE_PATH_imx6ul-des0258-mbl = "${B}"

# Temporary prepend to create u-boot-dtb.cfgout
do_deploy_prepend_imx6ul-des0258-mbl() {
	cp ${B}/mx6ul_14x14_evk_config/spl/u-boot-spl.cfgout ${B}/u-boot-dtb.cfgout
}

do_deploy_append() {
	install -D -p -m 0644 ${DCD_FILE_PATH}/u-boot-dtb.cfgout ${DEPLOYDIR}
}
