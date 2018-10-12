SUMMARY = "mbl application manager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4336ad26bb93846e47581adc44c4514d"
SRC_URI = "\
    git://git@github.com/ARMmbed/mbl-core.git;nobranch=1;protocol=ssh; \
"
SRCREV = "${MBL_CORE_SRCREV}"
S = "${WORKDIR}/git/firmware-management/mbl-app-manager"

RDEPENDS_${PN} = " \
    python3-core \
    python3-logging \
"

inherit python3-dir

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/mbl-app-manager ${D}${bindir}

    install -d ${D}${PYTHON_SITEPACKAGES_DIR}/mbl-app-manager/mbl/AppManager
    install -m 0644 ${S}/mbl/__init__.py ${D}${PYTHON_SITEPACKAGES_DIR}/mbl-app-manager/mbl/AppManager
    install -m 0644 ${S}/mbl/AppManager.py ${D}${PYTHON_SITEPACKAGES_DIR}/mbl-app-manager/mbl/AppManager
    install -m 0644 ${S}/mbl/setup.py ${D}${PYTHON_SITEPACKAGES_DIR}/mbl-app-manager
}

FILES_${PN} = " \
    ${bindir}/mbl-app-manager \
    ${PYTHON_SITEPACKAGES_DIR}/mbl-app-manager/mbl/AppManager__init__.py \
    ${PYTHON_SITEPACKAGES_DIR}/mbl-app-manager/mbl/AppManagerAppManager.py \
    ${PYTHON_SITEPACKAGES_DIR}/mbl-app-manager/setup.py \
"
