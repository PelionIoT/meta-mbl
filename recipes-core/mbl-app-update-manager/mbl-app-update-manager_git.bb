SUMMARY = "mbl application update manager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4336ad26bb93846e47581adc44c4514d"
SRC_URI = "git://git@github.com/ARMmbed/mbl-core.git;nobranch=1;protocol=ssh; "
SRCREV = "f53e908e1d64e35fd4da0ba0da2d5938f6f3cdf1"
S = "${WORKDIR}/git/firmware-management/mbl-app-update-manager"

RDEPENDS_${PN} = " \
    python3-core \
    python3-logging \
    mbl-app-manager \
    mbl-app-lifecycle-manager \
"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/mbl-app-update-manager ${D}${bindir}
}

FILES_${PN} = " \
    ${bindir}/mbl-app-update-manager \
"

