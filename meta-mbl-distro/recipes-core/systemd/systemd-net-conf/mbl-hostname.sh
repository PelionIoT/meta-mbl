#!/bin/sh
# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

if [ -r __REPLACE_ME_WITH_MBL_CONFIG_DIR__/hostname ] && [ -s __REPLACE_ME_WITH_MBL_CONFIG_DIR__/hostname ]; then
   cat __REPLACE_ME_WITH_MBL_CONFIG_DIR__/hostname > __REPLACE_ME_WITH_sysconfdir__/hostname
elif [ -r __REPLACE_ME_WITH_MBL_FACTORY_CONFIG_DIR__/hostname ] && [ -s __REPLACE_ME_WITH_MBL_FACTORY_CONFIG_DIR__/hostname ]; then
    cat __REPLACE_ME_WITH_MBL_FACTORY_CONFIG_DIR__/hostname > __REPLACE_ME_WITH_sysconfdir__/hostname
else
    rand=$(shuf -i0-9999 -n1)
    echo "mbed-linux-os-${rand}" > __REPLACE_ME_WITH_MBL_CONFIG_DIR__/hostname
    cat __REPLACE_ME_WITH_MBL_CONFIG_DIR__/hostname > __REPLACE_ME_WITH_sysconfdir__/hostname
fi

hostname -F __REPLACE_ME_WITH_sysconfdir__/hostname
