# Based on: firmware-qca9377_2.0.3.bb
# In open-source project: https://source.codeaurora.org/external/imx/meta-fsl-bsp-release/tree/imx/meta-bsp/recipes-qca/
#
# Copyright 2018 NXP
# Modifications: Copyright (c) 2019 Arm Limited and Contributors. All rights reserved

require firmware-qca_${PV}.inc

inherit allarch

do_install () {
    # Install firmware.conf for QCA modules
    install -d ${D}${sysconfdir}/bluetooth
    install -m 644 ${S}/1PJ_QCA9377-3_LEA_2.0/etc/bluetooth/firmware.conf ${D}${sysconfdir}/bluetooth

    # Install firmware files
    install -d ${D}${base_libdir}
    cp -r ${S}/1PJ_QCA9377-3_LEA_2.0/lib/firmware ${D}${base_libdir}
}


FILES_${PN} = " \
                ${sysconfdir}/bluetooth/firmware.conf \
                ${base_libdir}/firmware/qca \
                ${base_libdir}/firmware/qca9377 \
                ${base_libdir}/firmware/wlan \
"
