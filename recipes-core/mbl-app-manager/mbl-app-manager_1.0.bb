
SUMMARY = "mbl application manager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://mbl-app-manager \
           file://init \
          "

S = "${WORKDIR}"


inherit update-rc.d
INITSCRIPT_NAME = "mbl-app-manager"
INITSCRIPT_PARAMS = "defaults 90 10"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/mbl-app-manager ${D}${bindir}

    install -d "${D}${sysconfdir}/init.d"
    install -m 755 "${WORKDIR}/init" "${D}${sysconfdir}/init.d/mbl-app-manager"
}

# Replace placeholder strings in mbl-app-manager with values of BitBake variables
MBL_VAR_PLACEHOLDER_FILES = "${D}${sysconfdir}/init.d/mbl-app-manager"
inherit mbl-var-placeholders
