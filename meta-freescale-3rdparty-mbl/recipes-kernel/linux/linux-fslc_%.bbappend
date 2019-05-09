# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

##############################################################################
# linux-fslc_%.bbappend
#
# This recipe adds the files directory to FILESEXTRAPATHS.
##############################################################################
FILESEXTRAPATHS_append := "${THISDIR}/files:"

SRC_URI += "file://*-mbl.cfg"
