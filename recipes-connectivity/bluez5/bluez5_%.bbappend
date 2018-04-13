SRC_URI_append_bcm43430a1 = " \
    file://BCM43430A1.hcd \
    "

do_install_append_bcm43430a1() {
    install -d ${D}/lib/firmware/brcm/
    install -m 0644 ${WORKDIR}/BCM43430A1.hcd ${D}/lib/firmware/brcm/BCM43430A1.hcd
}

FILES_${PN}_append_bcm43430a1 = " \
    /lib/firmware/brcm/BCM43430A1.hcd \
    "
