# Copyright (c) 2018-2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# BusyBox: udhcpc: fix IPv6 support when using udhcpc
# https://patchwork.openembedded.org/patch/150758/
SRC_URI += "file://busybox-udhcpc-fix-IPv6-support-when-using-udhcpc.patch;patchdir=${WORKDIR}"
