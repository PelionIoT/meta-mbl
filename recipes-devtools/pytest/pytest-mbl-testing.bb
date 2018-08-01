SUMMARY = "mbed linux pytest"
DESCRIPTION = "This package installs and configures target with pytest."

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI += " \
    file://pytest.ini \
"

RDEPENDS_${PN} += "python3-mbl-testing python3-pytest"

FILES_${PN} += " \
    pytest.ini \
"

do_install() {    
    install -d ${D}/${bindir}   
    install -m 0644 ${WORKDIR}/pytest.ini ${D}/${bindir}/pytest.ini
}

