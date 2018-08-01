SUMMARY = "mbed linux OS - python3,pip3 and virtualenv (install into mbed Linux OS application installation folder)"
DESCRIPTION = "This package installs and configures target with minimal python 3, pip3 and virtual enviorment. This package must ibe installedinto the mbed Linux OS application installation folder (MBL_APP_DIR). Install this package when D is set e.g 'D=1 opkg install ...'"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
RDEPENDS_${PN} += "python3-pip"
SRC_URI += " \
    file://python3-run.sh \
    file://pip3-run.sh \
    file://virtualenv-run.sh \
    file://set-up-test-env.sh \
"

FILES_${PN} += " \
    ${bindir}/python3-run \
    ${bindir}/pip3-run \
    ${bindir}/virtualenv-run \
    ${libdir}/set-up-test-env.sh \
"

fixup_script() {
script_name="$1"
    sed -i -e "s|__REPLACE_ME_WITH_MBL_APP_DIR__|${MBL_APP_DIR}|g" "$script_name"
    sed -i -e "s|__REPLACE_ME_WITH_OE_USR_LIB_DIR__|${libdir}|g" "$script_name"
    sed -i -e "s|__REPLACE_ME_WITH_OE_USR_BIN_DIR__|${bindir}|g" "$script_name"
}

do_install() {
    install -d ${D}${libdir}  
    install -d ${D}${bindir}  
    
    install -m 0755 ${WORKDIR}/python3-run.sh ${D}${bindir}/python3-run
    install -m 0755 ${WORKDIR}/pip3-run.sh ${D}${bindir}/pip3-run
    install -m 0755 ${WORKDIR}/virtualenv-run.sh ${D}${bindir}/virtualenv-run
    install -m 0644 ${WORKDIR}/set-up-test-env.sh ${D}${libdir}/set-up-test-env.sh
    
    fixup_script "${D}${libdir}/set-up-test-env.sh"
    fixup_script "${D}${bindir}/pip3-run"
    fixup_script "${D}${bindir}/virtualenv-run"
    fixup_script "${D}${bindir}/python3-run"
}

pkg_postinst_${PN} () {
    ${MBL_APP_DIR}${bindir}/pip3-run install virtualenv
}

pkg_prerm_${PN} () {
    ${MBL_APP_DIR}${bindir}/pip3-run uninstall -y virtualenv
}
