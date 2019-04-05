# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# This file contains imx8mmevk-mbl BSP changes needed for the current
# (non-standard) form of the BSP. These changes will be removed when
# the BSP adopts the atf-${MACHINE}bb/atf.inc generic code.
do_compile[depends] += " u-boot-imx:do_deploy"
do_compile[depends] += " optee-os:do_deploy"

do_compile_prepend() {
    install -m 0644 ${DEPLOY_DIR_IMAGE}/optee/tee.bin ${BOOT_STAGING}
}
