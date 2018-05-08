# Don't let meta-raspberrypi's boot script overwrite meta-mbl's
RDEPENDS_${PN}_remove = "rpi-u-boot-scr"

RDEPENDS_${PN}_append = " mbl-boot-scr"

SRC_URI_remove_rpi = "file://0002-rpi_0_w-Add-configs-consistent-with-RpI3.patch"
