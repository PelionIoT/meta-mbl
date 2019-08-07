# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " file://0001-menuconfig-check-lxdiaglog.sh-Allow-specification-of.patch \
                   file://config-env-nowhere-mbl.cfg \
                 "
