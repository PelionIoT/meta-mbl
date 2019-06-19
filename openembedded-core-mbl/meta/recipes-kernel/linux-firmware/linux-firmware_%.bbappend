# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Recipe for adding Cypress firmware to the upstream linux-firmware recipe

# NOTE: this bbappend is BBMASKed (not parsed) on raspberrypi and the
# meta-raspberrypi linux-firmware is BBMASKed on imx7s-warp-mbl

FILES_${PN}-bcm43430 += "${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.MUR1DX.txt"

LICENSE_${PN}-bcm43430 += "Firmware-GPLv2"
RDEPENDS_${PN}-bcm43430 += "${PN}-gplv2-license"

do_install_append() {
        ln -sf brcmfmac43430-sdio.MUR1DX.txt ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.txt
}
FILES_${PN}-bcm43430 += " ${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.txt"
