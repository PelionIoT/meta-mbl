FILESEXTRAPATHS_prepend := "${THISDIR}/optee-client:"
SRC_URI += "file://init.d.optee"
SRCREV_raspberrypi3 = "2d542f2074223fde918e68efa4a9ff37f927e604"

SRC_URI_remove_raspberrypi3 = "file://0001-Respect-LDFLAGS-set-from-OE-build.patch"

inherit update-rc.d

do_install_append() {
        install -d ${D}${sysconfdir}/init.d
        install -m 0755 ${WORKDIR}/init.d.optee ${D}${sysconfdir}/init.d/init.d.optee
}

INITSCRIPT_NAME = "init.d.optee"
INITSCRIPT_PARAMS = "defaults"
