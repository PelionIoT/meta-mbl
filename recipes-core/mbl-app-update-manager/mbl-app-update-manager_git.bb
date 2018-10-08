SUMMARY = "mbl application update manager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4336ad26bb93846e47581adc44c4514d"

SRC_URI = " \
    git://git@github.com/ARMmbed/mbl-core.git;nobranch=1;protocol=ssh; \
    file://init \
"

SRCREV = "${MBL_CORE_SRCREV}"
S = "${WORKDIR}/git/firmware-management/mbl-app-update-manager"

RDEPENDS_${PN} = " \
    python3-core \
    python3-logging \
    mbl-app-manager \
    mbl-app-lifecycle-manager \
"

inherit update-rc.d
INITSCRIPT_NAME = "mbl-app-update-manager"
INITSCRIPT_PARAMS = "defaults 89 11"

do_install() {
    install -d "${D}${bindir}"
    install -m 0755 "${S}/mbl-app-update-manager" "${D}${bindir}"
    install -m 0755 "${S}/mbl-app-update-manager-daemon" "${D}${bindir}"

    install -d "${D}${sysconfdir}/init.d"
    install -m 0755 "${WORKDIR}/init" "${D}${sysconfdir}/init.d/mbl-app-update-manager"
}

FILES_${PN} = " \
    ${bindir}/mbl-app-update-manager \
    ${bindir}/mbl-app-update-manager-daemon \
    ${sysconfdir}/init.d/mbl-app-update-manager \
"
