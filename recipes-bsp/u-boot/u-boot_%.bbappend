# Don't let meta-raspberrypi's boot script overwrite meta-mbl's
RDEPENDS_${PN}_remove = "rpi-u-boot-scr"

RDEPENDS_${PN}_append = " mbl-boot-scr"
