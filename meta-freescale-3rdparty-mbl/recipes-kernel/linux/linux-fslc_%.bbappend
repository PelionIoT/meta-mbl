# Based on: recipes-kernel/linux/linux-warp7_4.1.bb
# In open-source project: https://github.com/Freescale/meta-freescale-3rdparty
#
# Original file: Copyright (C) 2016 NXP Semiconductors
# Modifications: Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

PV = "${LINUX_VERSION}+git${SRCPV}"
LINUX_VERSION = "4.14.112"
SRCREV = "45bad79852d5a7f6c6097f54cee064f92e7d7647"

KBUILD_DEFCONFIG_imx7s-warp-mbl ?= "warp7_mbl_defconfig"
KBUILD_DEFCONFIG_imx7d-pico-mbl ?= "pico_mbl_mx6_mx7_defconfig"
KBUILD_DEFCONFIG_imx6ul-pico-mbl ?= "pico_mbl_mx6_mx7_defconfig"

FILESEXTRAPATHS_prepend:="${THISDIR}/files:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/linux.git;protocol=https;nobranch=1 \
           file://0001-menuconfig-check-lxdiaglog.sh-Allow-specification-of.patch \
           file://mqueue-mbl.cfg \
           file://verity-mbl.cfg \
           file://cgroups-mbl.cfg \
           file://namespaces-mbl.cfg \
           "


LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

do_preconfigure() {
	mkdir -p ${B}
	echo "" > ${B}/.config
	CONF_SED_SCRIPT=""

	kernel_conf_variable LOCALVERSION "\"${LOCALVERSION}\""
	kernel_conf_variable LOCALVERSION_AUTO y

	sed -e "${CONF_SED_SCRIPT}" < '${S}/arch/arm/configs/${KBUILD_DEFCONFIG}' >> '${B}/.config'

	cfgs=`find ${WORKDIR}/ -maxdepth 1 -name '*-mbl.cfg' | wc -l`;
	if [ ${cfgs} -gt 0 ]; then
		${S}/scripts/kconfig/merge_config.sh -m -O ${B} ${B}/.config ${WORKDIR}/*-mbl.cfg
	fi

	if [ "${SCMVERSION}" = "y" ]; then
		# Add GIT revision to the local version
		head=`git --git-dir=${S}/.git rev-parse --verify --short HEAD 2> /dev/null`
		printf "%s%s" +g $head > ${S}/.scmversion
	fi
}

# TO-BE-REMOVED: workaround until the following upstream patch
# gets merged and adapted to warrior-dev branch
# https://patchwork.openembedded.org/patch/161618/
do_clean[depends] += "make-mod-scripts:do_clean"
