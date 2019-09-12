#!/bin/sh
# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

if [ ! -s __REPLACE_ME_WITH_MBL_CONFIG_DIR__/modprobe.d/g_ether.conf ]; then
    mkdir -p __REPLACE_ME_WITH_MBL_CONFIG_DIR__/modprobe.d
    # In the first octet of the MAC addr we need to ensure that b0 is 0 (unicast)
    # and b1 is 1 (locally administered).
    # We decided to prefix the dev_addr with "ee" and host_addr with "aa".
    dev_addr=ee:$(cut -b 0-8,10-11 /proc/sys/kernel/random/uuid | sed "s/../&:/g;s/:$//")
    host_addr=aa:$(cut -b 0-8,10-11 /proc/sys/kernel/random/uuid | sed "s/../&:/g;s/:$//")
    echo "options g_ether dev_addr=$dev_addr host_addr=$host_addr" > __REPLACE_ME_WITH_MBL_CONFIG_DIR__/modprobe.d/g_ether.conf
fi

modprobe -C __REPLACE_ME_WITH_MBL_CONFIG_DIR__/modprobe.d/g_ether.conf g_ether
