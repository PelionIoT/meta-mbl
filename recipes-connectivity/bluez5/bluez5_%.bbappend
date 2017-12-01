SRC_URI_append_imx7s-warp = " \
    file://BCM43430A1.hcd \
    "

do_install_append_imx7s-warp() {
    install -d ${D}/lib/firmware/brcm/
    install -m 0644 ${WORKDIR}/BCM43430A1.hcd ${D}/lib/firmware/brcm/BCM43430A1.hcd
}

FILES_${PN}_append_imx7s-warp = " \
    /lib/firmware/brcm/BCM43430A1.hcd \
    "
