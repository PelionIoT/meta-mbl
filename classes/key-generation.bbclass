# Copyright (c) 2018 ARM Ltd.
#
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0 (the License); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an AS IS BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


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

