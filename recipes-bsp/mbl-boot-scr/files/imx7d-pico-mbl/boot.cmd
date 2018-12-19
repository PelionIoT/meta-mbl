# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: Apache-2.0

# Specify a kernel image containing mbl-console-image-initramfs (do not use the default uImage)
setenv image uImage-initramfs-imx7d-pico-mbl.bin

setenv kernel_addr_r 0x88000000

setenv bootargs "console=ttymxc4,115200"

# Load Linux Kernel image from the boot partition (Linux Kernel image contains the initramfs image)
echo "Load Linux Kernel image containing initramfs image: ${image}"
fatload mmc 0:1 ${kernel_addr_r} ${image}

fatload mmc 0:1 ${fdt_addr} imx7d-pico.dtb

# Boot Linux with the device tree
bootm ${kernel_addr_r} - ${fdt_addr}

# Failsafe if something goes wrong
echo Fail to boot Linux, try hab_failsafe ...;
hab_failsafe
