# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT
inherit mbl-kernel-config
require recipes-kernel/linux/linux-mbl.inc

LINUX_VERSION = "4.14.95"

# This variable is needed because now linux-raspberrypi_4.19.bb in
# meta-raspberrypi are using this variable for checkout branch.
# And also in openembedded-core commit 324f9c818115 they are changing
# the way of applying patches so that's why previously we don't need this
# but need now. We should remove this variable when we move to any
# revision that rpi-4.19.y has. That means we move to 4.19 kernel.
# And we can go further to openbedded-core commit at 324f9c818115.
LINUX_RPI_BRANCH = "rpi-4.14.y"

SRCREV = "83b36f98e1a48d143f0b466fcf9f8c4e382c9a1c"

FILESEXTRAPATHS_prepend:="${THISDIR}/files:${THISDIR}/linux-raspberrypi:"

SRC_URI += "file://mqueue-mbl.cfg \
            file://rpi3-enable-optee-mbl.cfg \
            file://rpi3-psci-smp-mbl.cfg \
            file://watchdog-mbl.cfg \
"

# LOADADDR is 0x00080000 by default. But we need to put FIP between
# 0x00020000 ~ 0x00200000. Thus we move kernel to another address.
KERNEL_EXTRA_ARGS += " LOADADDR=0x04000000 "
