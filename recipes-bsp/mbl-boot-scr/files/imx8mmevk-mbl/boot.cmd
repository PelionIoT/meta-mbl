# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: Apache-2.0

setenv mmcroot /dev/mmcblk1p3 rootwait rw
run loadimage
run mmcboot
