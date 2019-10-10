# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# MBL_UBOOT_VERSION should be updated to match version pointed to by SRCREV
MBL_UBOOT_VERSION = "2018.11-rc1"
MBL_UBOOT_VERSION_imx6ul-pico-mbl = "v2019.10-rc1"

inherit mbl-uboot-sign

SRCREV = "a1588ac8228881f9fe65539fa8e31f0ee3556864"
SRCREV_imx6ul-pico-mbl = "d0d07ba86afc8074d79e436b1ba4478fa0f0c1b5"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git.denx.de/u-boot.git;protocol=https;nobranch=1"

SRC_URI_append_imx7s-warp-mbl = " \
     file://0001-ARM-arm-smccc-Remove-dependency-on-PSCI.patch \
     file://0002-imx-mx7-avoid-some-initialization-if-low-level-is-sk.patch \
     file://0003-optee-adjust-dependencies-and-default-values-for-dra.patch \
     file://0004-warp7-include-configs-set-skip-low-level-init.patch \
     file://0005-warp7-configs-add-bl33-defconfig.patch \
     file://0006-warp7_bl33-configs-Enable-FIT-as-the-boot.scr-format.patch \
     file://0007-warp7-include-configs-Differentiate-bootscript-addre.patch \
     file://0008-warp7-include-configs-Specify-image-name-of-bootscri.patch \
     file://0009-warp7-Build-dtb-into-u-boot.patch \
     file://0010-warp7_bl33-configs-Enable-CONFIG_OF_LIBFDT_OVERLAY.patch \
     file://0011-warp7-include-configs-Specify-an-fdtovaddr.patch \
     file://0012-cmd-image_info-Add-checking-of-default-FIT-config.patch \
     file://0013-pico-Modify-defconfig-to-support-boot.scr.patch \
     file://0014-pico-Disable-SPL-and-add-DCD-file.patch \
     file://0015-pico-change-bits-in-DCD.patch \
     file://0016-pico-switch-to-bl33-in-defconfig.patch \
     file://0017-pico-enable-bootz-and-pre-console-buffer.patch \
     file://0018-serial-add-skipping-init-option.patch \
     file://0019-pico-skip-uart-initialization.patch \
     file://0020-picopi-Build-dtb-into-u-boot.patch \
     file://0021-pico-convert-uboot-to-support-fit-image.patch \
     file://0022-pico-fall-back-to-hab_failsafe-when-fitimage-fail.patch \
     file://0023-warp7-check-fitimage-before-running-boot-script.patch \
     file://0024-pico-shrink-DRAM-size-to-avoid-memory-override.patch \
     ${@bb.utils.contains_any('PACKAGECONFIG','noconsole silent',' file://0002-set-silent-envs.patch','',d)} \
     ${@bb.utils.contains('PACKAGECONFIG','minimal',' file://0002-enable-net-without-net-commands.patch','',d)} \
     "
SRC_URI_append_imx7d-pico-mbl = " \
     file://0001-ARM-arm-smccc-Remove-dependency-on-PSCI.patch \
     file://0002-imx-mx7-avoid-some-initialization-if-low-level-is-sk.patch \
     file://0003-optee-adjust-dependencies-and-default-values-for-dra.patch \
     file://0004-warp7-include-configs-set-skip-low-level-init.patch \
     file://0005-warp7-configs-add-bl33-defconfig.patch \
     file://0006-warp7_bl33-configs-Enable-FIT-as-the-boot.scr-format.patch \
     file://0007-warp7-include-configs-Differentiate-bootscript-addre.patch \
     file://0008-warp7-include-configs-Specify-image-name-of-bootscri.patch \
     file://0009-warp7-Build-dtb-into-u-boot.patch \
     file://0010-warp7_bl33-configs-Enable-CONFIG_OF_LIBFDT_OVERLAY.patch \
     file://0011-warp7-include-configs-Specify-an-fdtovaddr.patch \
     file://0012-cmd-image_info-Add-checking-of-default-FIT-config.patch \
     file://0013-pico-Modify-defconfig-to-support-boot.scr.patch \
     file://0014-pico-Disable-SPL-and-add-DCD-file.patch \
     file://0015-pico-change-bits-in-DCD.patch \
     file://0016-pico-switch-to-bl33-in-defconfig.patch \
     file://0017-pico-enable-bootz-and-pre-console-buffer.patch \
     file://0018-serial-add-skipping-init-option.patch \
     file://0019-pico-skip-uart-initialization.patch \
     file://0020-picopi-Build-dtb-into-u-boot.patch \
     file://0021-pico-convert-uboot-to-support-fit-image.patch \
     file://0022-pico-fall-back-to-hab_failsafe-when-fitimage-fail.patch \
     file://0023-warp7-check-fitimage-before-running-boot-script.patch \
     file://0024-pico-shrink-DRAM-size-to-avoid-memory-override.patch \
     ${@bb.utils.contains('PACKAGECONFIG','minimal',' file://0001-pico7-disable-PXE-and-DHCP-boot.patch','',d)} \
     ${@bb.utils.contains('PACKAGECONFIG','minimal',' file://0002-enable-net-without-net-commands.patch','',d)} \
     ${@bb.utils.contains_any('PACKAGECONFIG','noconsole silent',' file://0002-set-silent-envs.patch','',d)} \
     "

SRC_URI_append_imx6ul-pico-mbl = " \
    file://0001-optee-Add-CONFIG_OPTEE_SKIP_LOWLEVEL_INIT.patch \
    file://0002-mx6_common-Share-configs-to-skip-low-level-init.patch \
    file://0003-pico-imx6ul-Add-bl33-config.patch \
    file://0004-mx7_common-Disjunct-on-CONFIG_OPTEE_SKIP_LOWLEVEL_IN.patch \
    file://0005-imx-imx6-Add-arch_misc_init.patch \
    file://0006-imx-imx6-arch_misc_init-Call-into-sec_init.patch \
    file://0007-pico-imx6ul-Reserve-region-of-memory-to-OPTEE.patch \
    file://0008-pico-imx6ul_bl33-configs-Enable-FIT-as-the-boot.scr-.patch \
    file://0009-pico-imx6ul_bl33-configs-Enable-CONFIG_OF_LIBFDT.patch \
    file://0010-pico-imx6ul_bl33-configs-Enable-CONFIG_OF_LIBFDT_OVE.patch \
    file://0011-distro_bootcmd-Provide-a-define-to-select-a-FIT-subi.patch \
    file://0012-pico-imx6ul-Define-the-name-of-the-FIT-bootscript-su.patch \
    file://0013-cmd-image_info-Add-checking-of-default-FIT-config.patch \
    ${@bb.utils.contains_any('PACKAGECONFIG','noconsole silent',' file://0002-set-silent-envs.patch','',d)} \
    ${@bb.utils.contains('PACKAGECONFIG','minimal',' file://0009-minimal-U-boot-service-for-pico-imx6ul.patch','',d)} \
    ${@bb.utils.contains('PACKAGECONFIG','minimal',' file://0002-enable-net-without-net-commands.patch','',d)} \
    ${@bb.utils.contains('PACKAGECONFIG','minimal',' file://0003-enable-net-without-net-commands-kconfig.patch','',d)} \
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
