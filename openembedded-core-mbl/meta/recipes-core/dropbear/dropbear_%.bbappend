# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://dropbear-ssh.service"

DNS_SD_SERVICES = "ssh"
DNS_SD_SERVICE_SRC[ssh] = "${WORKDIR}/dropbear-ssh.service"
DNS_SD_SERVICE_RDEPENDS[ssh] = "dropbear"

inherit dns-sd-services
