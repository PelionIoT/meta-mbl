# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# We need to configure swupdate to unset CONFIG_UBOOT and set CONFIG_BOOTLOADER_NONE
# as we don't have a u-boot environment. Add the path to our defconfig to FILESEXTRAPATHS.
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"


do_configure_prepend() {
    printf 'CONFIG_SW_VERSIONS_FILE="%s"' "${MBL_CONFIG_DIR}/sw-versions" >> "${WORKDIR}/defconfig"
}
