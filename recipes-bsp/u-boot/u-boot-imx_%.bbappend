# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

do_deploy_append() {
    # Fixup the name expected by the incoming imx-boot recipe
    cd ${DEPLOYDIR}/${BOOT_TOOLS}
    ln -sf u-boot-nodtb.bin-${MACHINE}-${UBOOT_CONFIG} u-boot-nodtb.bin 
}
