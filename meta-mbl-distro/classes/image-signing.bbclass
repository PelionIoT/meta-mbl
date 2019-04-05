# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# This class will sign image using OpenSSL.


DEPENDS += "openssl-native"


# This task generates OpenSSL key pair and signs root hash
do_sign_root_hash() {

    # * When the do_generate_verity_metadata creates the root hash, it calls it 
    #   ${IMAGE_NAME_WITH_SUFFIX}${ROOT_HASH_SUFFIX}. That name contains a
    #   timestamp, but the timestamp used when the root hash is created isn't
    #   necessarily the same as the timestamp currently in ${IMAGE_NAME}.
    #
    # * After the root hash is first created, a symlink is created to the root
    #   hash with a filename that doesn't contain the timestamp (and, for some
    #   reason unknown to me, without the ".rootfs" ${IMAGE_NAME_SUFFIX}).
    #
    # * We use the symlink to the root hash here to avoid a problem if the
    #   timestamp in the non-symlink filename is different to the current
    #   timestamp.
    #
    # * To keep consistency with the names of other build artefacts, we write
    #   our new dm-verity data files using a base name of
    #   "${IMAGE_NAME}${IMAGE_NAME_SUFFIX}" (i.e. including a timestamp and a
    #   ".rootfs" bit), but we then create symlinks to them using a basename of
    #   ${IMAGE_LINK_NAME}.
    root_hash_name="${IMAGE_NAME_WITH_SUFFIX}${ROOT_HASH_SUFFIX}"
    root_hash_link_name="${IMAGE_LINK_NAME}${ROOT_HASH_SUFFIX}"
    signed_base64_root_hash_suffix="${ROOT_HASH_SUFFIX}${SIGNED_ROOT_HASH_SUFFIX}${BASE64_SUFFIX}"
    signed_root_hash_name="${root_hash_name}${SIGNED_ROOT_HASH_SUFFIX}"
    signed_root_hash_name_base64="${signed_root_hash_name}${BASE64_SUFFIX}"


    # Sign root hash with the private key
    openssl dgst -sha256 -sign ${VERITY_KEYS_DIR}/${VERITY_ROOTFS_ROOT_HASH_PRIVATE_KEY_NAME} -sigopt rsa_padding_mode:pss -out ${WORKDIR}/${signed_root_hash_name} ${IMGDEPLOYDIR}/${root_hash_link_name}

    # Encode signature as base64, store the result under IMGDEPLOYDIR
    openssl enc -base64 -in ${WORKDIR}/${signed_root_hash_name} -out ${IMGDEPLOYDIR}/${signed_root_hash_name_base64}
    
    (
        # Use relative paths in the symlinks so that they will still work after
        # they're copied/moved from ${IMGDEPLOYDIR} (a deploy dir specific to
        # this build of the mbl-image-production recipe) to ${DEPLOY_DIR_IMAGE}
        # (the main deploy dir for the current MACHINE)
        # IMAGE_LINK_NAME example: mbl-image-production-imx7s-warp-mbl   
        cd ${IMGDEPLOYDIR}
        ln -sf ${signed_root_hash_name_base64} ${IMAGE_LINK_NAME}${signed_base64_root_hash_suffix}
    )
}

addtask sign_root_hash after do_generate_verity_metadata before do_prepare_rootfs_verity_hash_content

