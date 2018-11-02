SUMMARY = "mbl firmware update manager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4336ad26bb93846e47581adc44c4514d"

SRC_URI = "\
    git://git@github.com/ARMmbed/mbl-core.git;nobranch=1;protocol=ssh; \
"
SRCNAME = "mbl-firmware-update-manager"
SRCREV = "${MBL_CORE_SRCREV}"
S = "${WORKDIR}/git/firmware-management/${SRCNAME}"

RDEPENDS_${PN} = " \
    python3-core \
    python3-logging \
"

inherit setuptools3
inherit python3-dir

do_install_append() {
    install -d "${D}${bindir}"
    install -m 0755 "${S}/${SRCNAME}" "${D}${bindir}"
}

FILES_${PN} += " \
    ${bindir}/${SRCNAME} \
"