# Copyright (c) 2018-2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT


# The format of the SSH public key filename is ${username}_something.
# The __username__ is mandatory in order to the installing function to
# be able to know to which user home directory the public key should be
# copied to.
MBL_SSH_AUTHORIZED_KEYS_FILENAMES ?= "root_authorized_keys"
MBL_SSH_AUTHORIZED_KEYS_DIR ?= "${MBL_KEYSTORE_DIR}"

ROOTFS_POSTPROCESS_COMMAND_append = " copy_ssh_auth_keys; "

# For MBL Production Reference Distro we want to check the ssh authorized_keys
# files exist at parsing time.
python () {
    distro = d.getVar('DISTRO', True).strip()
    auth_keys_files = d.getVar('MBL_SSH_AUTHORIZED_KEYS_FILENAMES', True).split()
    auth_keys_dir = d.getVar('MBL_SSH_AUTHORIZED_KEYS_DIR', True)
    for auth_keys_file in auth_keys_files:
        auth_keys_file_path = os.path.join(auth_keys_dir, auth_keys_file)
        if distro == "mbl-production" and not os.path.isfile(auth_keys_file_path):
            raise bb.parse.SkipRecipe ("{} file doesn't exist.".format(auth_keys_file_path))
        else:
            # We need to re-parse each time the file changes, and bitbake
            # needs to be told about that explicitly.
            bb.parse.mark_dependency(d, auth_keys_file_path)
}

copy_ssh_auth_keys () {

    auth_keys_files="${@d.getVar('MBL_SSH_AUTHORIZED_KEYS_FILENAMES', True)}"
    auth_keys_dir="${@d.getVar('MBL_SSH_AUTHORIZED_KEYS_DIR', True)}"

    for auth_keys_file in $auth_keys_files
    do
        auth_keys_file_path="$auth_keys_dir/$auth_keys_file"
        if [ ! -f $auth_keys_file_path ]; then
            bbwarn "copy_ssh_auth_keys: $auth_keys_file_path doesn't exist."
            continue
        fi
        user=$(echo $auth_keys_file | sed 's/_.*//')
        if [ -d ${IMAGE_ROOTFS}/home/$user ]; then
            bbnote "Installing $auth_keys_file_path to ${IMAGE_ROOTFS}/home/$user/.ssh/authorized_key"
            install -d -m 700 ${IMAGE_ROOTFS}/home/$user/.ssh
            install -m 600 $auth_keys_file_path ${IMAGE_ROOTFS}/home/$user/.ssh/authorized_keys
        else
            message="The user $user home directory doesn't exist in the rootfs."
            [ "${@d.getVar('DISTRO', True).strip()}" = "mbl-production" ] && bbfatal $message || bbwarn $message
        fi
    done

}

do_rootfs[vardeps] += "MBL_SSH_AUTHORIZED_KEYS_FILENAMES MBL_SSH_AUTHORIZED_KEYS_DIR"
