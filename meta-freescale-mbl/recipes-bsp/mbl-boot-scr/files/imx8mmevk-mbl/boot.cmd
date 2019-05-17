# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: Apache-2.0

# Change root partition to /dev/mmcblk1p3
setenv mmcroot /dev/mmcblk1p3 rootwait rw

# Set bootscriptaddr
setenv bootscriptaddr 0x55000000

# The rootfs selection is done in the initramfs other kernel params are set in mmcargs
run mmcargs

echo "Load fit blob with Linux Kernel image and initramfs image"
fatload mmc 0 ${bootscriptaddr} boot.scr

# Extract FDT from FIT
imxtract ${bootscriptaddr}#conf@freescale_fsl-imx8mm-evk.dtb fdt@freescale_fsl-imx8mm-evk.dtb ${fdt_addr}

# Boot Linux
bootm ${bootscriptaddr}#conf@freescale_fsl-imx8mm-evk.dtb ${bootscriptaddr}:ramdisk@1 ${fdt_addr}
