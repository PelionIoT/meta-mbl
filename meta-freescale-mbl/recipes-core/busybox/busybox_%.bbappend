# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# Enable dd ibs and obs support so that it is possible to run the Qualcomm
# firmware package.
SRC_URI += "file://dd_ibs_obs.cfg"
