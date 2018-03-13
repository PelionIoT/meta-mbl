#!/bin/bash
# SPDX-License-Identifier:      GPL-2.0
#
# $1 = u-boot directory
# $2 = defconfig to use
uboot_dir=$1
uboot_target=$2

cd "$uboot_dir"

# Determine if we need to build
if [ -e "tools/mkimage" ]; then
    exit 0
fi

# We do need to build mkimage - do so now
make distclean
make "$uboot_target"
make tools-only
