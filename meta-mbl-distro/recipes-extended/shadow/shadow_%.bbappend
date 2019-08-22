# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_append := "${THISDIR}/files:"

SRC_URI += "file://faillog.logrotate"

do_install_append () {

    # We want to use SHA512 as encryption method to generate passwords
    sed -i 's/^#ENCRYPT_METHOD.*$/ENCRYPT_METHOD SHA512/' ${D}${sysconfdir}/login.defs

    if [ -n "${MBL_PASS_MIN_LEN}" ]; then
        # We want the minimum password length set by MBL_PASS_MIN_LEN
        sed -i 's/^PASS_MIN_LEN.*$/PASS_MIN_LEN ${MBL_PASS_MIN_LEN}/' ${D}${sysconfdir}/login.defs
    fi

    # We want the login fail delay of 5 seconds
    sed -i 's/^FAIL_DELAY.*$/FAIL_DELAY 5/' ${D}${sysconfdir}/login.defs

    # We want the maximum 3 login failures
    sed -i 's/^LOGIN_RETRIES.*$/LOGIN_RETRIES 3/' ${D}${sysconfdir}/login.defs

    # We want to log login failures
    sed -i 's/^FAILLOG_ENAB.*$/FAILLOG_ENAB yes/' ${D}${sysconfdir}/login.defs

    # For the FAILLOG_ENAB to work we need to have the /var/log/faillog in place
    mkdir -p ${D}/var/log
    touch ${D}/var/log/faillog

   # Add logrorate config for /var/log/faillog
   install -d ${D}${sysconfdir}/logrotate.d
   install -m 0644 ${WORKDIR}/faillog.logrotate ${D}${sysconfdir}/logrotate.d/faillog
}
