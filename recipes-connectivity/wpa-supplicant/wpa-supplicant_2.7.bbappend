# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# wpa_supplicant 2.7 seems to have a bug where it fails to connect to WPA2
# Enterprise networks (https://bugzilla.redhat.com/show_bug.cgi?id=1665608)
#
# This bbappend rolls back wpa_supplicant to version 2.6.

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# As well as changing the version of the resulting package, this causes the
# base recipe in oe-core to fetch source for version 2.6
PV = "2.6"

# 2.6 requires some additional patches (these additions were in the oe-core
# recipe when that recipe was for 2.6).
SRC_URI += " \
    file://key-replay-cve-multiple1.patch \
    file://key-replay-cve-multiple2.patch \
    file://key-replay-cve-multiple3.patch \
    file://key-replay-cve-multiple4.patch \
    file://key-replay-cve-multiple5.patch \
    file://key-replay-cve-multiple6.patch \
    file://key-replay-cve-multiple7.patch \
    file://key-replay-cve-multiple8.patch \
    file://wpa_supplicant-CVE-2018-14526.patch \
"

LIC_FILES_CHKSUM = " \
    file://COPYING;md5=292eece3f2ebbaa25608eed8464018a3 \
    file://README;beginline=1;endline=56;md5=3f01d778be8f953962388307ee38ed2b \
    file://wpa_supplicant/wpa_supplicant.c;beginline=1;endline=12;md5=4061612fc5715696134e3baf933e8aba \
"

SRC_URI[md5sum] = "091569eb4440b7d7f2b4276dbfc03c3c"
SRC_URI[sha256sum] = "b4936d34c4e6cdd44954beba74296d964bc2c9668ecaa5255e499636fe2b1450"
