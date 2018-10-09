SUMMARY = "mbl application manager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4336ad26bb93846e47581adc44c4514d"
SRC_URI = "\
    git://git@github.com/ARMmbed/mbl-core.git;nobranch=1;protocol=ssh; \
"
SRCREV = "46f912c04bd559c63d865b5961ce6b7281efb21f"
S = "${WORKDIR}/git/firmware-management/mbl-app-manager"

RDEPENDS_${PN} = " \
    python3-core \
    python3-logging \
"

inherit python3-dir

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/mbl-app-manager ${D}${bindir}

    install -d ${D}${PYTHON_SITEPACKAGES_DIR}/mbl
    install -m 0644 ${S}/mbl/AppManager.py ${D}${PYTHON_SITEPACKAGES_DIR}/mbl
}

FILES_${PN} = " \
    ${bindir}/mbl-app-manager \
    ${PYTHON_SITEPACKAGES_DIR}/mbl/AppManager.py \
"
