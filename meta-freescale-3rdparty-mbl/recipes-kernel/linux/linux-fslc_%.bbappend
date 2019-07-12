# Based on: recipes-kernel/linux/linux-warp7_4.1.bb
# In open-source project: https://github.com/Freescale/meta-freescale-3rdparty
#
# Original file: Copyright (C) 2016 NXP Semiconductors
# Modifications: Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SRCREV_imx6ul-des0258-mbl = "83d967e82fe285635be7845c6b578fee2c441996"

KBUILD_DEFCONFIG_imx7d-pico-mbl ?= "imx_v6_v7_defconfig"

LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

FILESEXTRAPATHS_prepend:="${THISDIR}/files:"

#SRCBRANCH = "kvalo-qca9377/ath10k-pending-sdio-usb"
SRC_URI = "git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/ath.git;branch=ath10k-pending-sdio-usb \
           file://mqueue-mbl.cfg \
           file://cgroups-mbl.cfg \
           file://namespaces-mbl.cfg \
           file://qca9377-mbl.cfg \
"
SRCREV = "b1e5798d5f183742279d66e4cf0a8a6d852b0634"

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
