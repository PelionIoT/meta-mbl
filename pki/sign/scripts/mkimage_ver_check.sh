#!/bin/bash
# SPDX-License-Identifier:      GPL-2.0
#
# $1 mkimage

mkimage=$1

# Get mkimage version
ver=$("$mkimage" -V | awk '{print $3}')
major=$(echo "$ver" | awk '{print substr($0, 0, 4)}')
minor=$(echo "$ver" | awk '{print substr($0, 6, 2)}')
min=2017
# Bug out if version is too old
if [ "$major" -lt "$min" ]; then
    echo "mimimum mkimage criteria not met. mkimage ver $major.$minor > $min.xx required"
    exit 1
fi
# Good to go
exit 0
