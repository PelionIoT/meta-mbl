
SUMMARY = "mbl application manager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://mbl-app-manager \
           file://AppManager.py"

S = "${WORKDIR}"

inherit python3-dir

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/mbl-app-manager ${D}${bindir}

    install -d ${D}${PYTHON_SITEPACKAGES_DIR}/mbl
    install -m 0644 ${S}/AppManager.py ${D}${PYTHON_SITEPACKAGES_DIR}/mbl
}

FILES_${PN} = " \
    ${bindir}/mbl-app-manager \
    ${PYTHON_SITEPACKAGES_DIR}/mbl/AppManager.py \
"
