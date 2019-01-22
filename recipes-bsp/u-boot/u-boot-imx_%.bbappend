# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SRCBRANCH = "imx_v2018.03_4.14.78_1.0.0_ga"
SRCREV = "654088cc211e021387b04a8c33420739da40ebbe"

FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot-imx:"

do_deploy_append() {
    # Fixup the name expected by the incoming imx-boot recipe
    cd ${DEPLOYDIR}/${BOOT_TOOLS}
    ln -sf u-boot-nodtb.bin-${MACHINE}-${UBOOT_CONFIG} u-boot-nodtb.bin 
}
