# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

setenv root /dev/mmcblk1p3
ext4size mmc 0:2 rootfs2 && setenv root /dev/mmcblk1p5
setenv bootargs console=${console},${baudrate} root=${root} rootwait rw
setenv mmcargs
fdt addr ${fdt_addr}
fatload mmc 0:1 ${fdt_addr} ${fdt_file}
fatload mmc 0:1 ${loadaddr} ${image}
bootz ${loadaddr} - ${fdt_addr}
