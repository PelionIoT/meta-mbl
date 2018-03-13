#!/bin/sh
# SPDX-License-Identifier:      GPL-2.0
#
# $1 = git
# $2 = u-boot directory
# $3 = u-boot git URL
# $4 = SHA to checkout

git=$1
uboot_dir=$2
uboot_url=$3
sha=$4

# Check if u-boot directory exists
if [ ! -d "$uboot_dir" ]; then
    # Clone repo
    "$git" clone "$uboot_url" "$uboot_dir"
    # Make a branch we can build
    cd "$uboot_dir"
    "$git" checkout -b mbl-uboot "$sha"
fi
