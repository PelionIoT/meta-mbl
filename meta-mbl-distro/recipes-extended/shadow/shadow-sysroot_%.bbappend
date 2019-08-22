# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

do_install_append () {
    # We want to use SHA512 as encryption method to generate passwords for the target
    sed -i 's/^#ENCRYPT_METHOD.*$/ENCRYPT_METHOD SHA512/' ${D}${sysconfdir}/login.defs

    if [ -n "${MBL_PASS_MIN_LEN}" ]; then
        # We want the minimum password length set by MBL_PASS_MIN_LEN
        sed -i 's/^PASS_MIN_LEN.*$/PASS_MIN_LEN ${MBL_PASS_MIN_LEN}/' ${D}${sysconfdir}/login.defs
    fi

}
