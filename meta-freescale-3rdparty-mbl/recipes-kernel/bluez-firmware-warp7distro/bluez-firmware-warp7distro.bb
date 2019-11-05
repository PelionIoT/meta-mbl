# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "Linux kernel Bluetooth firmware files from Murata distribution"
DESCRIPTION = "Bluetooth firmware files for Warp7 hardware."
HOMEPAGE = "https://github.com/murata-wireless/cyw-bt-patch"
SECTION = "kernel"

LICENSE = "Firmware-cypress"

LIC_FILES_CHKSUM_remove = "\
    file://LICENCE.cypress;md5=48cd9436c763bf873961f9ed7b5c147b \
"

LIC_FILES_CHKSUM_append = "\
    file://LICENCE.cypress;md5=cbc5f665d04f741f1e006d2096236ba7 \
"

SRC_URI = "git://github.com/murata-wireless/cyw-bt-patch;protocol=https"
SRCREV = "748462f0b02ec4aeb500bedd60780ac51c37be31"
PV = "0.0+git${SRCPV}"

S = "${WORKDIR}/git"

inherit allarch

do_compile() {
    :
}

do_install() {
    install -d ${D}${nonarch_base_libdir}/firmware/brcm
    install -m 0644 ${S}/CYW43430A1.1DX.hcd ${D}${nonarch_base_libdir}/firmware/brcm
}

PACKAGES = "\
    ${PN}-bcm43430a1-hcd \
"

FILES_${PN}-bcm43430a1-hcd = "\
    ${nonarch_base_libdir}/firmware/brcm/CYW43430A1.1DX.hcd \
"
