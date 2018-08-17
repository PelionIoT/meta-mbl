DESCRIPTION = "ARM Trusted Firmware Warp7 - FIP Tool"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://license.rst;md5=e927e02bca647e14efd87e9e914b2443"

BBCLASSEXTEND = "native nativesdk"
DEPENDS += "openssl-native"

EXTRA_OEMAKE_class-native = 'CC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}" HOSTCC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}" STRIP=true V=1'
EXTRA_OEMAKE_class-nativesdk = 'CROSS_COMPILE="${HOST_PREFIX}" CC="${CC} ${CFLAGS} ${LDFLAGS}" HOSTCC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}" STRIP=true V=1'

SRC_URI = "git://git@git.linaro.org/landing-teams/working/mbl/arm-trusted-firmware.git;protocol=https;branch=linaro-warp7"
SRCREV = "ac2ad596404e3f81c4a6e6d1a53e8de6375b3972"

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
