# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

# The rootfs selection is done in the initramfs other kernel params are set in mmcargs
run mmcargs

# Now boot
echo Booting secure Linux from FIT ...;
bootm ${bootscriptaddr}#conf@0 ${bootscriptaddr}:ramdisk@1 ${fdt_addr}

# Failsafe if something goes wrong
hab_failsafe
