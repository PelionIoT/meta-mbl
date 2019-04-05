# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# This class will generate OpenSSL public and private keys and save them under VERITY_KEYS_DIR directory.
# Keys will be used by the Verity mechanism for root hash signing and verity.


DEPENDS += "openssl-native"


# This task generates OpenSSL key pair used by verity to sign root hash of rootfs partition. 
# This task should not be dependant on other tusks, it should be run manually on its own.
do_generate_verity_rootfs_keys() {

    # remove VERITY_KEYS_DIR directory containing old keys
    rm -rf ${VERITY_KEYS_DIR}
    install -d ${VERITY_KEYS_DIR}

    # Generate RSA key-pair (store as ${VERITY_ROOTFS_ROOT_HASH_PRIVATE_KEY_NAME} at VERITY_KEYS_DIR.
    openssl genrsa -out ${VERITY_KEYS_DIR}/${VERITY_ROOTFS_ROOT_HASH_PRIVATE_KEY_NAME} 4096
    
    # Extract public key from private-key file
    openssl rsa -pubout -in ${VERITY_KEYS_DIR}/${VERITY_ROOTFS_ROOT_HASH_PRIVATE_KEY_NAME} -out ${VERITY_KEYS_DIR}/${VERITY_ROOTFS_ROOT_HASH_PUBLIC_KEY_NAME}
}

addtask generate_verity_rootfs_keys

