# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

###############################################################################
# initscripts_%.bbappend
#   This file modifies the behaviour of the initscripts_1.0.bb recipe to
#   patch the initialisation script bootmisc.init to start to set the system
#   date time correctly.   
###############################################################################
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " file://0001-IOTMBL58-bootmisc.sh-fix-issue-with-setting-system-d.patch;striplevel=5;patchdir=${WORKDIR} \
             file://0001-IOTMBL1092-remount-rw-partitions-to-ro-before-umount.patch;striplevel=5;patchdir=${WORKDIR} \
"

# make sure the local appending config file will be chosen by prepending and extra local path
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = "  file://hostname.sh"
