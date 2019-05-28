# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_append := "${THISDIR}/${PN}-${PV}:"

# This series of patches reverts from the upstream project to fix the
# issue with brcmfmac driver (for Broadcom chipsets)  not supporting
# 802.1X 4-way handshake. In MBL, WaRP7 and Rpi3 use chipsets from
# this vendor.
SRC_URI_FIX_4_WAY_HANDSHAKE = " file://0001-REVERT-nl80211-Check-4-way-handshake-offload-support.patch \
                              "

SRC_URI_append_imx7s-warp-mbl   += "${SRC_URI_FIX_4_WAY_HANDSHAKE}"
SRC_URI_append_raspberrypi3-mbl += "${SRC_URI_FIX_4_WAY_HANDSHAKE}"
