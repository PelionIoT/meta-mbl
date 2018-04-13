SRC_URI_append_bananapi-zero = " \
    file://BCM43430A1.hcd \
    "
SRC_URI_append_imx7s-warp-mbl = " \
    file://BCM43430A1.hcd \
    "

do_install_append_bananapi-zero() {
    install -d ${D}/lib/firmware/brcm/
    install -m 0644 ${WORKDIR}/BCM43430A1.hcd ${D}/lib/firmware/brcm/BCM43430A1.hcd
}
do_install_append_imx7s-warp-mbl() {
    install -d ${D}/lib/firmware/brcm/
    install -m 0644 ${WORKDIR}/BCM43430A1.hcd ${D}/lib/firmware/brcm/BCM43430A1.hcd
}

FILES_${PN}_append_bananapi-zero = " \
    /lib/firmware/brcm/BCM43430A1.hcd \
    "
FILES_${PN}_append_imx7s-warp-mbl = " \
    /lib/firmware/brcm/BCM43430A1.hcd \
    "
