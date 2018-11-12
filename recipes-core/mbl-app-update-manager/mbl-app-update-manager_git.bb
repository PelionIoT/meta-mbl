SUMMARY = "mbl application update manager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4336ad26bb93846e47581adc44c4514d"

SRC_URI = " \
    ${SRC_URI_MBL_CORE_REPO} \
    file://init \
"
SRCNAME = "mbl-app-update-manager"
SRCREV = "${SRCREV_MBL_CORE_REPO}"
S = "${WORKDIR}/git/firmware-management/${SRCNAME}"

RDEPENDS_${PN} = " \
    python3-core \
    python3-logging \
    mbl-app-manager \
    mbl-app-lifecycle-manager \
"

inherit setuptools3
inherit python3-dir

inherit update-rc.d
INITSCRIPT_NAME = "${SRCNAME}"
INITSCRIPT_PARAMS = "defaults 89 11"

do_install_append() {
    install -d "${D}${sysconfdir}/init.d"
    install -m 0755 "${WORKDIR}/init" "${D}${sysconfdir}/init.d/${INITSCRIPT_NAME}"
}

FILES_${PN} += " \
    ${sysconfdir}/init.d/${INITSCRIPT_NAME} \
"
