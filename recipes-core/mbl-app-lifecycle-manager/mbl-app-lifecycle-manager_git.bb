SUMMARY = "mbl application lifecycle manager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4336ad26bb93846e47581adc44c4514d"
SRC_URI = "\
    git://git@github.com/ARMmbed/mbl-core.git;nobranch=1;protocol=ssh; \
    file://init \
"
SRCREV = "f53e908e1d64e35fd4da0ba0da2d5938f6f3cdf1"
S = "${WORKDIR}/git/application-framework/mbl-app-lifecycle-manager"

RDEPENDS_${PN} = " \
    python3-core \
    python3-json \
    python3-logging \
    docker \
"
# FIXME IOTMBL-778: This package only rdepends on the OCI runtime, not docker.

inherit python3-dir

inherit update-rc.d
INITSCRIPT_NAME = "mbl-app-lifecycle-manager"
INITSCRIPT_PARAMS = "defaults 91 9"


do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/mbl-app-lifecycle-manager ${D}${bindir}

    install -d ${D}${PYTHON_SITEPACKAGES_DIR}/mbl
    install -m 0644 ${S}/mbl/__init__.py ${D}${PYTHON_SITEPACKAGES_DIR}/mbl
    install -m 0644 ${S}/mbl/AppLifecycleManager.py ${D}${PYTHON_SITEPACKAGES_DIR}/mbl

    install -d "${D}${sysconfdir}/init.d"
    install -m 0755 "${WORKDIR}/init" "${D}${sysconfdir}/init.d/mbl-app-lifecycle-manager"
}

# Replace placeholder strings in init script with values of BitBake variables
MBL_VAR_PLACEHOLDER_FILES = "${D}${sysconfdir}/init.d/mbl-app-lifecycle-manager"
inherit mbl-var-placeholders

FILES_${PN} = " \
    ${bindir}/mbl-app-lifecycle-manager \
    ${PYTHON_SITEPACKAGES_DIR}/mbl/__init__.py \
    ${PYTHON_SITEPACKAGES_DIR}/mbl/AppLifecycleManager.py \
    ${sysconfdir}/init.d/mbl-app-lifecycle-manager \
"
