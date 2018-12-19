# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT
#
# This file contains imx7s-pico-mbl.conf changes needed for the current
# (non-standard) form of the BSP. These changes will be removed when
# the BSP adopts mbl-fitimage.bbclass to generate the FIT image.

DEPENDS += " u-boot-tools-native"


do_compile_append_imx7d-pico-mbl() {
    mkimage -A arm -T script -C none -n "Boot script" -d "${WORKDIR}/boot.cmd" boot.scr
}


do_deploy_append_imx7d-pico-mbl() {
    # It's unnecessary to create the DEPLOYDIR before installing to it because is created
    # automatically as part of deploy.bbclass processing (do_deploy[dirs] = "S{DEPLOYDIR} ${B}")
    install -m 0644 boot.scr ${DEPLOYDIR}
}

