SUMMARY = "mbl application lifecycle manager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4336ad26bb93846e47581adc44c4514d"
SRC_URI = "git://git@github.com/ARMmbed/mbl-core.git;nobranch=1;protocol=ssh; "
SRCREV = "a12ef1d1e7cee837aa14ce6221f3fcf56f02f4a8"
S = "${WORKDIR}/git/application-framework/mbl-app-lifecycle-manager"

RDEPENDS_${PN} = " \
    python3-core \
    python3-json \
    python3-logging \
    docker \
"
# FIXME IOTMBL-778: This package only rdepends on the OCI runtime, not docker.

inherit python3-dir

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/mbl-app-lifecycle-manager ${D}${bindir}

    install -d ${D}${PYTHON_SITEPACKAGES_DIR}/mbl
    install -m 0644 ${S}/mbl/__init__.py ${D}${PYTHON_SITEPACKAGES_DIR}/mbl
    install -m 0644 ${S}/mbl/AppLifecycleManager.py ${D}${PYTHON_SITEPACKAGES_DIR}/mbl
}

FILES_${PN} = " \
    ${bindir}/mbl-app-lifecycle-manager \
    ${PYTHON_SITEPACKAGES_DIR}/mbl/__init__.py \
    ${PYTHON_SITEPACKAGES_DIR}/mbl/AppLifecycleManager.py \
"
