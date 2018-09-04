# Copyright (c) 2018, Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: Apache-2.0

# This class is to aid customization of installed files by allowing values of
# BitBake variables to be inserted into them.
#
# In each file listed in ${MBL_VAR_PLACEHOLDER_FILES}, this class will replace
# occurrences of "__REPLACE_ME_WITH_SOME_BITBAKE_VARIABLE_NAME__" with the
# value of the "SOME_BITBAKE_VARIABLE_NAME" variable.
#
# This replacement is done after the do_install task (and before the
# do_populate_sysroot task).
#
# For an example, see the following files in meta-mbl:
# * recipes-core/base-files/base_files_%.bbappend
# * recipes-core/base-files/files/fstab

def expand_placeholders_in_line(d, line):
    import re

    def placeholder_replacement(match):
        return d.getVar(match.group(1), True)

    return re.sub(
        r'__REPLACE_ME_WITH_([A-Za-z_]+)__',
        placeholder_replacement,
        line
    )


fakeroot python do_expand_mbl_var_placeholders() {
    import os

    # Create a new file, expanding variable placeholders line by line
    for path in d.getVar("MBL_VAR_PLACEHOLDER_FILES", True).split():
        tmppath = "{}.do_expand_mbl_var_placeholders.tmp".format(path)
        with open(path, mode="r") as file:
            with open(tmppath, mode="w") as tmpfile:
                for _, line in enumerate(file):
                    new_line = expand_placeholders_in_line(d, line)
                    bb.warn("Replacing [{}] with [{}] in [{}]".format(line, new_line, path))
                    tmpfile.write(expand_placeholders_in_line(d, line))

    # Copy the original file's user, group and permission metadata to the new
    # file
    info = os.stat(path)
    os.chmod(tmppath, info.st_mode)
    os.chown(tmppath, info.st_uid, info.st_gid)

    # Replace the original file with the new file
    os.rename(tmppath, path)
}

addtask expand_mbl_var_placeholders after do_install before do_populate_sysroot
