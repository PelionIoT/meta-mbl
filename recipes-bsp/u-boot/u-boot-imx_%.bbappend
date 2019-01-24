# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot-imx:"
SRC_URI_append_imx8mmevk-mbl = " file://0001-tools-fix-cross-compiling-tools-when-HOSTCC-is-overr.patch \
               file://0002-Pass-empty-CFLAGS-on-invocation-of-libfdt-setup.py.patch \
               file://0003-tools-sunxi-Add-spl-image-builder.patch \
               file://0004-tools-allow-to-override-python.patch \
               file://0005-fdt-Add-all-source-files-to-the-libfdt-build.patch \
               file://0006-fdt-Rename-existing-python-libfdt-module.patch \
"
do_deploy_append() {
    # Fixup the name expected by the incoming imx-boot recipe
    cd ${DEPLOYDIR}/${BOOT_TOOLS}
    ln -sf u-boot-nodtb.bin-${MACHINE}-${UBOOT_CONFIG} u-boot-nodtb.bin 
}
