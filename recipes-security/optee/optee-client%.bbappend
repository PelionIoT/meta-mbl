FILESEXTRAPATHS_prepend := "${THISDIR}/optee-client:"
SRC_URI += "file://init.d.optee"

inherit update-rc.d

do_install_append() {
        install -d ${D}${sysconfdir}/init.d
        install -m 0755 ${WORKDIR}/init.d.optee ${D}${sysconfdir}/init.d/init.d.optee
}

INITSCRIPT_NAME = "init.d.optee"
INITSCRIPT_PARAMS = "defaults"
