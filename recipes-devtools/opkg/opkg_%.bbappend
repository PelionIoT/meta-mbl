# make sure the local appending config file will be chosen by prepending and extra local path
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

FILES_libopkg += " \
    ${MBL_SCRATCH_DIR}/opkg/src_ipk \
    ${MBL_APP_DIR} \
"

fixup_opkg_conf() {
opkg_conf_file="$1"
    sed -i -e "s|__REPLACE_ME_WITH_MBL_CONFIG_DIR__|${MBL_CONFIG_DIR}|g" "$opkg_conf_file"
    sed -i -e "s|__REPLACE_ME_WITH_MBL_SCRATCH_DIR__|${MBL_SCRATCH_DIR}|g" "$opkg_conf_file"
    sed -i -e "s|__REPLACE_ME_WITH_MBL_APP_DIR__|${MBL_APP_DIR}|g" "$opkg_conf_file"      
}


do_install_append() {
    conf_file_path="${sysconfdir}/opkg/opkg.conf"    
    install -d ${D}${sysconfdir}/opkg
    install -m 0644 ${WORKDIR}/opkg.conf ${D}${conf_file_path}
    
    install -d ${D}/${MBL_SCRATCH_DIR}/opkg/src_ipk/    
    install -d ${D}/${MBL_APP_DIR}  
    
    fixup_opkg_conf "${D}${conf_file_path}"  
}

