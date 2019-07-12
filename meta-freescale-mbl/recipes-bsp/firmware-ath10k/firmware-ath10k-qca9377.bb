# Copyright 2018 NXP

SUMMARY = "Qualcomm Wi-Fi and Bluetooth firmware"
DESCRIPTION = "Qualcomm Wi-Fi and Bluetooth firmware for modules such as QCA9377-3"
SECTION = "base"
LICENSE = "Proprietary"

inherit allarch

LIC_FILES_CHKSUM = "file://${S}/LICENSE.qca_firmware;md5=74852b14e2b35d8052226443d436a244"
SRC_URI = "git://github.com/kvalo/ath10k-firmware.git"
SRCREV = "7651f5bb299c40e34e05179b1bd15b211856a4b0"

S = "${WORKDIR}/git"

do_configure() {
}

do_compile() {
}

do_install () {
    # Install firmware files
    install -d ${D}${base_libdir}/firmware/ath10k/QCA9377/hw1.0
    install -m 644 ${S}/QCA9377/hw1.0/untested/firmware-sdio-5.bin_WLAN.TF.1.1.1-00061-QCATFSWPZ-1 ${D}${base_libdir}/firmware/ath10k/QCA9377/hw1.0/firmware-sdio-5.bin
    install -m 644 ${S}/QCA9377/hw1.0/board.bin ${D}${base_libdir}/firmware/ath10k/QCA9377/hw1.0/board-sdio.bin
}

FILES_${PN} = " \
    ${base_libdir}/firmware/ath10k/QCA9377/hw1.0 \
"
