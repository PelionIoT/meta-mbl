# Don't let meta-raspberrypi's boot script overwrite meta-mbl's
RDEPENDS_${PN}_remove = "rpi-u-boot-scr"

RDEPENDS_${PN}_append = " mbl-boot-scr"

FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot:"
SRC_URI_append_rpi = " file://0100-rpi3-Change-u-boot-loading-address.patch \
		   file://rpi3-boot-script-fit-file.diff \
		   "

do_deploy_append_rpi() {

       install -d ${DEPLOYDIR}/fip
       install -m 0644 ${B}/dts/dt.dtb ${DEPLOYDIR}/fip/dt.dtb
       install -m 0644 ${B}/u-boot-nodtb.bin ${DEPLOYDIR}/fip/u-boot-nodtb.bin
}
