# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# This class, for now, is used to set the root password by passing it
# as plain text in the file listed in the MBL_ROOT_PASSWD_FILE variable.

# TODO: It is expected that this class will handle password and other
# related settings for custom users.

MBL_PASS_MIN_LEN ?= "12"

MBL_ROOT_PASSWD_FILE ?= "${TOPDIR}/mbl_root_passwd_file"

# At parsing time we need to check if the file holding the root password
# exists and if it meets the requirements set by the MBL_PASS_MIN_LEN
# variable.
python __anonymous () {
    mbl_root_passwd_file = d.getVar('MBL_ROOT_PASSWD_FILE', True)

    try:
        with open(mbl_root_passwd_file, 'r') as f:
            mbl_root_passwd = f.readline().strip()
    except OSError as err:
        raise bb.parse.SkipRecipe("{}".format(str(err)))

    if len(mbl_root_passwd) < int(d.getVar('MBL_PASS_MIN_LEN', True)):
        raise bb.parse.SkipRecipe("root password set in MBL_ROOT_PASSWD_FILE \"{}\" minimum length is {}"\
                  .format(mbl_root_passwd_file, d.getVar('MBL_PASS_MIN_LEN', True)))

    d.setVar('MBL_ROOT_PASSWORD', mbl_root_passwd)

    # We need to re-parse each time the file changes, and bitbake
    # needs to be told about that explicitly.
    bb.parse.mark_dependency(d, mbl_root_passwd_file)
}

inherit extrausers
EXTRA_USERS_PARAMS += "usermod -P ${@d.getVar('MBL_ROOT_PASSWORD', True)} root;"
