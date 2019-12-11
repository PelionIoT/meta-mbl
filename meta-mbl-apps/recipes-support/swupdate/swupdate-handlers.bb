# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Building swupdate together with MBL's custom handlers is a bit convoluted.
# See the comment in swupdate_%.bbappend for details.

SUMMARY = "Swupdate handlers library"
LICENSE = "BSD-3-Clause"

LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE.BSD-3-Clause;md5=1a8858961a0fa364bc79169ca26815db"
SRC_URI = "\
    ${SRC_URI_MBL_CORE_REPO} \
"
SRCREV = "${SRCREV_MBL_CORE_REPO}"
SRCNAME = "swupdate-handlers"

S = "${WORKDIR}/git/firmware-management/${SRCNAME}"

DEPENDS += "swupdate-headers"

inherit cmake

# We need to add this include path so the swupdate header files can include
# other swupdate header files.
CFLAGS += "-I ${STAGING_DIR_TARGET}${includedir}/swupdate"

EXTRA_OECMAKE += "\
-DBOOTFLAGS_DIR=${MBL_BOOTFLAGS_DIR} \
-DUPDATE_PAYLOAD_DIR=${MBL_SCRATCH_DIR} \
-DLOG_DIR=${MBL_LOG_DIR} \
-DFACTORY_CONFIG_DIR=${MBL_FACTORY_CONFIG_DIR} \
-DPART_INFO_DIR=${MBL_PART_INFO_DIR} \
"
