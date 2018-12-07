# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

DESCRIPTION = "ARM Trusted Firmware Warp7 - FIP Tool"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://license.rst;md5=e927e02bca647e14efd87e9e914b2443"

BBCLASSEXTEND = "native nativesdk"
DEPENDS += "openssl"

EXTRA_OEMAKE_class-target = 'CROSS_COMPILE="${TARGET_PREFIX}" CC="${CC} ${CFLAGS} ${LDFLAGS}" HOSTCC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}" STRIP=true V=1'
EXTRA_OEMAKE_class-native = 'CC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}" HOSTCC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}" STRIP=true V=1'
EXTRA_OEMAKE_class-nativesdk = 'CROSS_COMPILE="${HOST_PREFIX}" CC="${CC} ${CFLAGS} ${LDFLAGS}" HOSTCC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}" STRIP=true V=1'

SRC_URI = "git://github.com/ARM-software/arm-trusted-firmware.git;protocol=https;nobranch=1"
SRCREV = "36044baf08a9f816a8a062a8a50ede12a816a6dd"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

do_compile() {
   oe_runmake -C ${S} BUILD_BASE=${B} fiptool
}

do_install () {
	install -d ${D}${bindir}
	install -m 0755 ${S}/tools/fiptool/fiptool ${D}${bindir}/atf-fiptool
	install -m 0755 ${S}/tools/fip_create/fip_create ${D}${bindir}/atf-fip_create
}
