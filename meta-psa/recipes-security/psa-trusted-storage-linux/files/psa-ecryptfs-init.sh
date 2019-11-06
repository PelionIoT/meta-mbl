#!/bin/sh
#
###############################################################################
# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
# ecryptfs homepage: http://ecryptfs.org/
# Summary: Utilities for the Linux cryptographic filesystem ecryptfs.
#
# Description
# ===========
#  This script is used to mount an ecryptfs ciphered directory at system
#  startup. If the ciphered directory is being mounted for the first time
#  (e.g. when the system boots after flashing an image) then the required
#  configuration is generated and stored. The configuration includes:
#  - An ecyptfs FEKEK (File Encryption Key Encryption Key).
#  - A passphrase to protect the FEKEK, and the storing of the passphrase
#    in a file.
#  - An entry in /etc/fstab specifying the mount operation. This uses the
#    passphrase file.
#  - The creation of the upper (unencrypted) and lower (encrypted) storage
#    directories.
#
#  The following operations happen during boot:
#  - The passphrase protected FEKEK is added to the user kernel keyring.
#  - The unecrypted (upper) directory is mounted on the encrypted (lower)
#    directory by ecryptfs to provide deciphered access to stored files.
#    Mount options in fstab specify the FEKEK key signature so ecryptfs
#    can read the cipher key from the keyring. The passphrase is also read
#    to decode the FEKEK.
#
#  The upper and lower directory terminology is explained in:
#    <src/>/Documentation/filesystems/overlayfs.txt
#
# Outstanding Issues
# ==================
#  - The passphrase should not be stored on the filesystem, but retrieved
#    from secure storage e.g. on-chip internal trusted flash, or secure flash,
#    or from a keyring key populated earlier in the boot, and perhaps
#    removed from the keyring after use.
#  - This script requires filesystem write access to store configuration files
#    e.g. the passphrase file. Once the passphrase is provided by alternative
#    means, a read-only filesystem can be supported. This script can then be
#    modified appropriately.
###############################################################################

###############################################################################
# Tools. These ecryptfs-util tools are required to be on the PATH.
###############################################################################
EFS_DAEMON="ecryptfsd"
EFS_INSERT_PASSPH="ecryptfs-insert-wrapped-passphrase-into-keyring"
EFS_WRAP_PASSPH="ecryptfs-wrap-passphrase"

###############################################################################
# Symbols
###############################################################################
EFS_FSTAB_PATH="/etc/fstab"
EFS_HOME="/home/root"
EFS_RANDOM="/dev/random"

# Directory to store configuration artifacts
EFS_CONFIG_DIR=".ecryptfs"
EFS_CONFIG_DIR_PATH=${EFS_HOME}/${EFS_CONFIG_DIR}
EFS_CONFIG_FSTAB_PATH=${EFS_CONFIG_DIR_PATH}/"fstab.old"
EFS_CONFIG_KEY_FILENAME_PATH=${EFS_CONFIG_DIR_PATH}/"wrapped-passphrase.bin"
EFS_CONFIG_PASSPHRASE_FILE_PATH=${EFS_CONFIG_DIR_PATH}/"passphrase.txt"

# This is the path to the encrypted storage directory on the underlying
# filesystem.
EFS_CONFIG_LOWER_PATH=${EFS_HOME}/".secret"

# This is the path to the unencrypted mounted directory.
EFS_CONFIG_UPPER_PATH=${EFS_HOME}/"secret"

EFS_KEY_WIDTH="30"
EFS_SESSION_KEY_BYTES="16"

###############################################################################
# Global Variables
###############################################################################

# Error codes
EFS_SUCCESS_KEY_CREATED=1
EFS_SUCCESS=0
EFS_ERROR=-1

###############################################################################
# FUNCTION: efs_sys_init()
#  Perform the first boot system initialisation. In summary:
#  - Generate the key.
#  - Gnerate the passphrase for potecting the key
#  - Wrap the key with the passphrase
#  - Insert the wrapped key into the keyring and recover the key signature.
#  - Update /etc/fstab
###############################################################################
efs_sys_init()
{
    ret=${EFS_ERROR}
    efs_fekek=""
    efs_fekek_passphrase=""
    sig=""

    if [ ! -f "${EFS_FSTAB_PATH}" ]; then
        echo "Error: ${EFS_FSTAB_PATH} is not in expected location."
        return $ret
    fi

    # If the directory exists then the one-time system initialisation has already
    # been performed, and should not be run again.
    if [ -d "${EFS_CONFIG_DIR_PATH}" ]; then
        # setup has been run previously on first time startup
        return ${EFS_SUCCESS}
    else
        mkdir -p ${EFS_CONFIG_DIR_PATH}
        mkdir -p ${EFS_CONFIG_LOWER_PATH}
        mkdir -p ${EFS_CONFIG_UPPER_PATH}
    fi

    # This is the File Encryption Key Encryption Key. It is intended to be stored
    # on the file system protected by the passphrase.
    efs_fekek=$(od -x --read-bytes=100 --width=${EFS_KEY_WIDTH} ${EFS_RANDOM} | head -n 1 | sed "s/^0000000//" | sed "s/\\s*//g")

    # The passphrase protects the FEKEK. It should be stored securely (e.g. in
    # secure on-chip flash for key storage). One option if the secure boot to
    # install it in the key ring and supply its signature to this script.
    efs_fekek_passphrase=$(od -x --read-bytes=100 --width=${EFS_KEY_WIDTH} ${EFS_RANDOM} | head -n 1 | sed "s/^0000000//" | sed "s/\\s*//g")

    # Store key and passphrase in files for use later.
    echo "passphrase_passwd=${efs_fekek_passphrase}" > ${EFS_CONFIG_PASSPHRASE_FILE_PATH}

    # Create the wrapped-passphrase file.
    printf "%s\n%s" "${efs_fekek}" "${efs_fekek_passphrase}" | ${EFS_WRAP_PASSPH} ${EFS_CONFIG_KEY_FILENAME_PATH} -

    # Install the wrapped key in the keyring for use by ecryptfs
    # cat "<passphrase>" | ecryptfs-insert-wrapped-passphrase-into-keyring /home/root/.ecryptfs/wrapped-passphrase -
    sig=$(echo "${efs_fekek_passphrase}" | ${EFS_INSERT_PASSPH} ${EFS_CONFIG_KEY_FILENAME_PATH} -)

    # Extract the key signature from within "[]" (e.g. "<some text> [dd0a45455a291a98] <other text> ").
    sig=${sig##*[}
    sig=${sig%%]*}

    # Update /etc/fstab so can do mount operation.
    # This involves inserting the key so that the signature can be recovered
    # and therefore used in the fstab entry line.

    rm -f ${EFS_CONFIG_FSTAB_PATH}
    cp -f ${EFS_FSTAB_PATH} ${EFS_CONFIG_FSTAB_PATH}

    # Create the fstab configuration entry by concatenation option substrings.
    # See the ecryptfs.7 manpage for the description of the options used here.
    # The options permit non-interactive mounting  i.e. a user doesn't
    # have to respond to prompts. Note the ecryptfs_unlink_sigs option causes
    # umount to remove the key from the keyring.
    s="${s:+${s}}${EFS_CONFIG_LOWER_PATH}"
    s="${s:+${s} }${EFS_CONFIG_UPPER_PATH}"
    s="${s:+${s} }ecryptfs"
    s="${s:+${s} }noauto"
    s="${s:+${s},}user"
    s="${s:+${s},}ecryptfs_sig=${sig}"
    s="${s:+${s},}ecryptfs_fnek_sig=${sig}"
    s="${s:+${s},}ecryptfs_cipher=aes"
    s="${s:+${s},}ecryptfs_key_bytes=${EFS_SESSION_KEY_BYTES}"
    s="${s:+${s},}key=passphrase:passphrase_passwd_file=${EFS_CONFIG_PASSPHRASE_FILE_PATH}"
    s="${s:+${s},}ecryptfs_passthrough=n"
    s="${s:+${s},}ecryptfs_unlink_sigs"
    s="${s:+${s},}no_sig_cache"
    s="${s:+${s} }0"
    s="${s:+${s} }0"
    echo "${s}" >> ${EFS_FSTAB_PATH}

    # everything successfully initialised.
    return ${EFS_SUCCESS_KEY_CREATED}
}


###############################################################################
# FUNCTION: efs_init()
#  This function performs the following system startup initialisation:
#  - start the message dispatcher.
#  - install the FEKEK in the keyring.
#  - mount the cipher directory
###############################################################################
efs_init()
{
    ret=${EFS_ERROR}
    efs_fekek_passphrase=""

    efs_sys_init
    ret=$?
    if [ $ret -lt ${EFS_SUCCESS} ]; then
        return $ret
    elif [ $ret -eq ${EFS_SUCCESS} ]; then
        # Extract the passphrase from the passphrase file which has type=value
        # format.
        efs_fekek_passphrase=$(cat ${EFS_CONFIG_PASSPHRASE_FILE_PATH})
        efs_fekek_passphrase=${efs_fekek_passphrase##passphrase_passwd=}
        echo "${efs_fekek_passphrase}" | ${EFS_INSERT_PASSPH} ${EFS_CONFIG_KEY_FILENAME_PATH} -
    fi

    # Mount the encrypted directory using configuration in /etc/fstab
    mount ${EFS_CONFIG_UPPER_PATH}

    # Start the ecryptfs message dispatcher
    ${EFS_DAEMON} -f
}


###############################################################################
# FUNCTION: efs_deinit()
#  This function performs system startup de-initialisation.
###############################################################################
efs_deinit()
{
    # Un-mount the encrypted directory.
    umount ${EFS_CONFIG_UPPER_PATH}

    # Start the ecryptfs message dispatcher.
    kill "$(pidof ${EFS_DAEMON})"
}

###############################################################################
# FUNCTION: efs_main()
#  Handle the command line arguments and perform initialisation.
###############################################################################
efs_main()
{

    # Process the command line options.
    while [ $# -gt 0 ]
    do
    key="$1"

    case $key in
        -c|--config-dir-path)
            EFS_CONFIG_DIR_PATH="$2"
            shift
            shift
            ;;
        -l|--lower-dir-path)
            EFS_CONFIG_LOWER_PATH="$2"
            shift
            shift
            ;;
        -u|--upper-dir-path)
            EFS_CONFIG_UPPER_PATH="$2"
            shift
            shift
            ;;
        *)
            # Ignore unknown argument.
            shift
            ;;
    esac
    done

    efs_init
}

# Start the script at the main() function.
efs_main "$@"
