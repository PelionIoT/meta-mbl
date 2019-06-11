# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

# Point to our temporary integrated zImage+initramfs
setenv image zImage-initramfs-imx6ul-pico-mbl.bin

# Load kernel+initrd to target address
load mmc 0:1 ${kernel_addr_r} ${image}

# Load the fdt
load mmc 0:1 ${fdt_addr_r} ${fdtfile}

# find uuid
run finduuid

# The command line
setenv bootargs root=${uuid} rootwait rw console=ttymxc5,115200

# Now boot
echo Booting secure Linux from FIT ...;
bootz ${kernel_addr_r} - ${fdt_addr}

# Failsafe if something goes wrong
hab_failsafe
