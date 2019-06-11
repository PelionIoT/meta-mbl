# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

# Point to our temporary integrated zImage+initramfs
setenv image zImage-initramfs-imx6ul-des0258-mbl.bin

# Point to our DTB
setenv fdt_file imx6ul-des0258.dtb

# Fix loadimage and loadfdt
setenv loadimage load mmc ${mmcdev}:${mmcpart} ${loadaddr} ${image}
setenv loadfdt load mmc ${mmcdev}:${mmcpart} ${fdt_addr} ${fdt_file}

# Now boot
echo Booting secure Linux from eMMC ...;
mmc dev ${mmcdev}; run mmcboot

# Failsafe if something goes wrong
hab_failsafe
