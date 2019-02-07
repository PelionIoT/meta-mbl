# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY="Google tests for MBED Cloud Client (target only)"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE.BSD-3-Clause;md5=1a8858961a0fa364bc79169ca26815db"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

S = "${WORKDIR}/git/cloud-services/mbl-cloud-client/tests/gtest"

SRC_URI = "${SRC_URI_MBL_CORE_REPO}"

SRCREV = "${SRCREV_MBL_CORE_REPO}"

DEPENDS = "gtest mbl-cloud-client glibc jsoncpp systemd"

# Allowed [Debug|Release]
RELEASE_TYPE="Debug"

inherit cmake
inherit deploy
inherit noinstall
inherit pythonnative

MBL_CLOUD_CLIENT_INCLUDE_DIR = "${WORKDIR}/git/cloud-services/mbl-cloud-client"
INC_DIR = "${STAGING_INCDIR}"
MBED_CLOUD_CLIENT_INCLUDE_DIR = "${INC_DIR}/mbed-cloud-client"

EXTRA_OECMAKE += "-DCMAKE_BUILD_TYPE=${RELEASE_TYPE} \
                  -DCMAKE_FIND_LIBRARY_PREFIXES=".a .so" \
                  -DMBL_CLOUD_CLIENT_INCLUDE_DIR:PATH=${MBL_CLOUD_CLIENT_INCLUDE_DIR} \
                  -DINC_DIR:PATH=${INC_DIR} \
                  -DMBED_CLOUD_CLIENT_INCLUDE_DIR:PATH=${MBED_CLOUD_CLIENT_INCLUDE_DIR} \
                  -DEXTERNAL_DEFINE_FILE="${INC_DIR}/define.txt" \
"


do_deploy() {
     install -d "${DEPLOYDIR}/${TARGET_OS}/bin" 
     install -m 755 "${B}/mbl-cloud-client-gtest"  "${DEPLOYDIR}/${TARGET_OS}/bin"
}

addtask deploy after do_compile

