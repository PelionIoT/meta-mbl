SUMMARY = "mbl application update manager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4336ad26bb93846e47581adc44c4514d"

SRC_URI = " \
    git://git@github.com/ARMmbed/mbl-core.git;nobranch=1;protocol=ssh; \
    file://init \
"
SRCNAME = "mbl-app-update-manager"
SRCREV = "${MBL_CORE_SRCREV}"
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
    install -d "${D}${bindir}"
    install -m 0755 "${S}/${SRCNAME}-daemon" "${D}${bindir}"

    install -d "${D}${sysconfdir}/init.d"
    install -m 0755 "${WORKDIR}/init" "${D}${sysconfdir}/init.d/${INITSCRIPT_NAME}"
}

FILES_${PN} += " \
    ${bindir}/${SRCNAME}-daemon \
    ${sysconfdir}/init.d/${INITSCRIPT_NAME} \
"
