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


# This class will sign image using OpenSSL.


DEPENDS += "openssl-native"


# This task generates OpenSSL key pair and signs root hash
do_sign_root_hash() {

    signed_base64_root_hash_suffix="${ROOT_HASH_SUFFIX}${SIGNED_ROOT_HASH_SUFFIX}${BASE64_SUFFIX}"
    root_hash_name="${IMAGE_NAME_WITH_SUFFIX}${ROOT_HASH_SUFFIX}"
    signed_root_hash_name="${root_hash_name}${SIGNED_ROOT_HASH_SUFFIX}"
    signed_root_hash_name_base64="${signed_root_hash_name}${BASE64_SUFFIX}"

    # Sign root hash with the private key
    openssl dgst -sha256 -sign ${VERITY_KEYS_DIR}/${VERITY_ROOTFS_ROOT_HASH_PRIVATE_KEY_NAME} -sigopt rsa_padding_mode:pss -out ${WORKDIR}/${signed_root_hash_name} ${IMGDEPLOYDIR}/${root_hash_name}

    # Encode signature as base64, store the result under IMGDEPLOYDIR
    openssl enc -base64 -in ${WORKDIR}/${signed_root_hash_name} -out ${IMGDEPLOYDIR}/${signed_root_hash_name_base64}
    
    (
        # Use relative paths in the symlinks so that they will still work after
        # they're copied/moved from ${IMGDEPLOYDIR} (a deploy dir specific to
        # this build of the mbl-console-image recipe) to ${DEPLOY_DIR_IMAGE}
        # (the main deploy dir for the current MACHINE)
        # IMAGE_LINK_NAME example: mbl-console-image-imx7s-warp-mbl   
        cd ${IMGDEPLOYDIR}
        ln -sf ${signed_root_hash_name_base64} ${IMAGE_LINK_NAME}${signed_base64_root_hash_suffix}
    )
}
 
addtask sign_root_hash after do_generate_verity_metadata before do_image_wic

