# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

# find uuid
run finduuid

# The command line
setenv bootargs root=${uuid} rootwait rw console=ttymxc5,115200

# Verify image drop to bootloader failsafe if it fails
iminfo ${scriptaddr}
if test "$?" = "1"; then hab_failsafe; fi

# Extract FDT from FIT
imxtract ${scriptaddr}#conf@imx6ul-pico-pi.dtb fdt@imx6ul-pico-pi.dtb ${fdt_addr}

# Extract Kernel
setenv loadaddr 0x80800000
imxtract ${scriptaddr}#conf@imx6ul-pico-pi.dtb kernel@1 ${loadaddr}

# Apply OP-TEE provided overlay
setenv fdtovaddr 0x83100000
fdt addr ${fdt_addr}
fdt resize 0x1000
fdt apply ${fdtovaddr}

# Now boot
echo Booting secure Linux from FIT ...;
bootz ${loadaddr}  ${scriptaddr}:ramdisk@1 ${fdt_addr}

# Failsafe if something goes wrong
hab_failsafe
