# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: Apache-2.0

setenv mmcroot /dev/mmcblk1p3 rootwait rw
setenv image Image-initramfs-imx8mmevk-mbl.bin
run loadimage
run mmcboot
