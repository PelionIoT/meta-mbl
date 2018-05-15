#
# Recipe for adding Cypress firmware to the upstream linux-firmware recipe
# SPDX-License-Identifier: Apache-2.0
#

# Changes that will to go upstream when the firmware is submitted to linux-firmware.git
LICENSE_append = "\
    & Firmware-cypress \
"

LIC_FILES_CHKSUM_remove = "\
    file://WHENCE;md5=6f46986f4e913ef16b765c2319cc5141 \
    file://LICENCE.Netronome;md5=cd2a3e6effe3cdf42731575b8e9477ed \
"

LIC_FILES_CHKSUM_append = "\
    file://LICENCE.cypress;md5=cbc5f665d04f741f1e006d2096236ba7 \
    file://WHENCE;md5=4ced610de73544e4a36e07400566a5f1 \
    file://LICENCE.Netronome;md5=4add08f2577086d44447996503cddf5f \
"

NO_GENERIC_LICENSE[Firmware-cypress] = "LICENCE.cypress"

# The meta-raspberrypi layer may have already added ${PN}-cypress-license to
# PACKAGES, and if that's happened we don't want to add it again (BitBake
# doesn't like duplicates in PACKAGES).
#
# To check whether ${PN}-cypress-license has already been added to PACKAGES we
# need to force a copy of PACKAGES to be expanded now. (Note that getVar()'s
# default behaviour is to expand).
EXPANDED_PACKAGES := "${@d.getVar('PACKAGES')}"
PACKAGES_prepend = " \
             ${@bb.utils.contains('EXPANDED_PACKAGES', '${PN}-cypress-license', '', '${PN}-cypress-license', d)} \
             ${PN}-cyw43430a1 \
             "

LICENSE_${PN}-bcm43012 = "Firmware-cypress"
LICENSE_${PN}-bcm43340 = "Firmware-cypress"
LICENSE_${PN}-bcm43362 = "Firmware-cypress"
LICENSE_${PN}-bcm4339 = "Firmware-cypress"
LICENSE_${PN}-bcm43430 = "Firmware-cypress"
LICENSE_${PN}-bcm43455 = "Firmware-cypress"
LICENSE_${PN}-bcm4354 = "Firmware-cypress"
LICENSE_${PN}-bcm4356 = "Firmware-cypress"
LICENSE_${PN}-cypress-license = "Firmware-cypress"

FILES_${PN}-cypress-license = " \
  ${nonarch_base_libdir}/firmware/LICENCE.cypress \
"
FILES_${PN}-bcm43013 = " \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43012-sdio.bin \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43012-sdio.clm_blob \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43012-sdio.1LV.txt \
"
FILES_${PN}-bcm43340 = " \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43340-sdio.bin \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43340-sdio.1BW.txt \
"
FILES_${PN}-bcm43362 = " \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43362-sdio.bin \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43362-sdio.SN8000.txt \
"
FILES_${PN}-bcm4339 = " \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac4339-sdio.bin \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac4339-sdio.1CK.txt \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac4339-sdio.ZP.txt \
"
FILES_${PN}-bcm43430 = " \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.bin \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.1DX.txt \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.1LN.txt \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.AP6212.txt \
"
FILES_${PN}-bcm43455 = " \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.bin \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.clm_blob \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.1HK.txt \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.1LC.txt \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.1MW.txt \
"
FILES_${PN}-bcm4354 = " \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac4354-sdio.bin \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac4354-sdio.1BB.txt \
"
FILES_${PN}-bcm4356 = " \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac4356-pcie.bin \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac4356-pcie.1CX.txt \
"

RDEPENDS_${PN}-bcm43012 += "${PN}-cypress-license"
RDEPENDS_${PN}-bcm43340 += "${PN}-cypress-license"
RDEPENDS_${PN}-bcm43362 += "${PN}-cypress-license"
RDEPENDS_${PN}-bcm4339 += "${PN}-cypress-license"
RDEPENDS_${PN}-bcm43430 += "${PN}-cypress-license"
RDEPENDS_${PN}-bcm43455 += "${PN}-cypress-license"
RDEPENDS_${PN}-bcm4354 += "${PN}-cypress-license"
RDEPENDS_${PN}-bcm4356 += "${PN}-cypress-license"

# Cypress Bluetooth patch files
LICENSE_${PN}-cyw43012c0 = "Firmware-cypress"
LICENSE_${PN}-cyw43341b0 = "Firmware-cypress"
LICENSE_${PN}-cyw4335c0 = "Firmware-cypress"
LICENSE_${PN}-cyw43430a1 = "Firmware-cypress"
LICENSE_${PN}-cyw4345c0 = "Firmware-cypress"
LICENSE_${PN}-cyw4350c0 = "Firmware-cypress"
LICENSE_${PN}-cyw4354a2 = "Firmware-cypress"

FILES_${PN}-cyw43012c0 = " \
  ${nonarch_base_libdir}/firmware/cyw_bt/CYW43012C0.1LV.hcd \
"
FILES_${PN}-cyw43341b0 = " \
  ${nonarch_base_libdir}/firmware/cyw_bt/CYW43341B0.1BW.hcd \
"
FILES_${PN}-cyw4335c0 = " \
  ${nonarch_base_libdir}/firmware/cyw_bt/CYW4335C0.ZP.hcd \
"
FILES_${PN}-cyw43430a1 = " \
  ${nonarch_base_libdir}/firmware/cyw_bt/CYW43430A1.1DX.1dB_Less.hcd \
  ${nonarch_base_libdir}/firmware/cyw_bt/CYW43430A1.1DX.2dB_Less.hcd \
  ${nonarch_base_libdir}/firmware/cyw_bt/CYW43430A1.1DX.hcd \
"
FILES_${PN}-cyw4345c0 = " \
  ${nonarch_base_libdir}/firmware/cyw_bt/CYW4345C0.1MW.hcd \
"
FILES_${PN}-cyw4350c0 = " \
  ${nonarch_base_libdir}/firmware/cyw_bt/CYW4350C0.1BB.hcd \
"
FILES_${PN}-cyw4354a2 = " \
  ${nonarch_base_libdir}/firmware/cyw_bt/CYW4354A2.1CX.hcd \
"

RDEPENDS_${PN}-cyw43012c0 += "${PN}-cypress-license"
RDEPENDS_${PN}-cyw43341b0 += "${PN}-cypress-license"
RDEPENDS_${PN}-cyw4335c0 += "${PN}-cypress-license"
RDEPENDS_${PN}-cyw43430a1 += "${PN}-cypress-license"
RDEPENDS_${PN}-cyw4345c0 += "${PN}-cypress-license"
RDEPENDS_${PN}-cyw4350c0 += "${PN}-cypress-license"
RDEPENDS_${PN}-cyw4354a2 += "${PN}-cypress-license"

# Stuff that is specific to this bbappend, not upstream
SRCREV = "210e5127e833180c994990851b83d9e2ea518ace"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/linux-firmware.git;protocol=https;nobranch=1"

# Changes that are specific to our distro/board/chip and will not go into upstream linux-firmware recipe
# but may need a better upstream home
do_install_append_imx7s-warp-mbl() {
    (cd ${D}${nonarch_base_libdir}/firmware/brcm/ ; ln -sf brcmfmac43430-sdio.1DX.txt brcmfmac43430-sdio.txt)
}

do_install_append_bananapi-zero() {
    (cd ${D}${nonarch_base_libdir}/firmware/brcm/ ; ln -sf brcmfmac43430-sdio.AP6212.txt brcmfmac43430-sdio.txt)
}

FILES_${PN}-bcm43430_append = " \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.txt \
"
