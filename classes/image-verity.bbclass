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


# This class will generate dm-verity data from the rootfs image using the cryptsetup tool.


# Add cryptsetup tool for integrity checking
# This will compile cryptsetup tool in the host architecture
DEPENDS += "cryptsetup-native"


# e.g. mbl-console-image-imx7s-warp-mbl-20180810101241.rootfs
IMAGE_NAME_WITH_SUFFIX = "${IMAGE_NAME}${IMAGE_NAME_SUFFIX}"

#This task creates a rootfs hash tree and root hash using dm-verity veritysetup tool on the host
do_generate_verity_metadata() {
    hash_tree_suffix=.hash_tree.bin
    header_info_suffix=.verity_header_information.txt
    rootfs_ext=.ext4
    image_link_name="${IMAGE_LINK_NAME}" # e.g. mbl-console-image-imx7s-warp-mbl

    # * When the .ext4 image is first created it is written to
    #   ${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.ext4. That name contains a timestamp,
    #   but the timestamp used when the .ext4 image is created isn't
    #   necessarily the same as the timestamp currently in ${IMAGE_NAME}.
    #
    # * After the .ext4 image is first created, a symlink is created to the
    #   .ext4 image with a filename that doesn't contain the timestamp (and,
    #   for some reason unknown to me, without the ".rootfs"
    #   ${IMAGE_NAME_SUFFIX}).
    #
    # * We use the symlink to the .ext4 image here to avoid a problem if the
    #   timestamp in the non-symlink filename is different to the current
    #   timestamp.
    #
    # * To keep consistency with the names of other build artefacts, we write
    #   our new dm-verity data files using a base name of
    #   "${IMAGE_NAME}${IMAGE_NAME_SUFFIX}" (i.e. including a timestamp and a
    #   ".rootfs" bit), but we then create symlinks to them using a basename of
    #   ${IMAGE_LINK_NAME}.

    veritysetup format ${IMGDEPLOYDIR}/${image_link_name}${rootfs_ext} ${IMGDEPLOYDIR}/${IMAGE_NAME_WITH_SUFFIX}${hash_tree_suffix}\
    > ${IMGDEPLOYDIR}/${IMAGE_NAME_WITH_SUFFIX}${header_info_suffix}

    grep "Root hash:" ${IMGDEPLOYDIR}/${IMAGE_NAME_WITH_SUFFIX}${header_info_suffix} | sed -e 's/.*:[[:blank:]]*//'\
    > ${IMGDEPLOYDIR}/${IMAGE_NAME_WITH_SUFFIX}${ROOT_HASH_SUFFIX}

    (
        # Use relative paths in the symlinks so that they will still work after
        # they're copied/moved from ${IMGDEPLOYDIR} (a deploy dir specific to
        # this build of the mbl-console-image recipe) to ${DEPLOY_DIR_IMAGE}
        # (the main deploy dir for the current MACHINE)
        cd ${IMGDEPLOYDIR}
        ln -sf ${IMAGE_NAME_WITH_SUFFIX}${hash_tree_suffix} ${image_link_name}${hash_tree_suffix}
        ln -sf ${IMAGE_NAME_WITH_SUFFIX}${header_info_suffix} ${image_link_name}${header_info_suffix}
        ln -sf ${IMAGE_NAME_WITH_SUFFIX}${ROOT_HASH_SUFFIX} ${image_link_name}${ROOT_HASH_SUFFIX}
    )
}

addtask generate_verity_metadata after do_image_ext4 before do_sign_root_hash



# This task prepare the content of rootfs1_verity_hash partition under the VERITY_HASH directiry. 
# The rootfs1_verity_hash partition will contain a rootfs hash tree, root hash and signature.
do_prepare_rootfs_verity_hash_content() {

    hash_tree_suffix=.hash_tree.bin
    signed_base64_root_hash_suffix="${ROOT_HASH_SUFFIX}${SIGNED_ROOT_HASH_SUFFIX}${BASE64_SUFFIX}"
    verity_hash_dir_name="${IMGDEPLOYDIR}/verity_hash"

    # remove an old verity_hash directory and create a new one
    rm -rf ${verity_hash_dir_name}
    install -d ${verity_hash_dir_name} 

    # install content for the rootfs1_verity_hash partition
    install -m 0644 ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}${hash_tree_suffix} ${verity_hash_dir_name}/
    install -m 0644 ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}${ROOT_HASH_SUFFIX} ${verity_hash_dir_name}/
    install -m 0644 ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}${signed_base64_root_hash_suffix} ${verity_hash_dir_name}/
}

addtask prepare_rootfs_verity_hash_content after do_sign_root_hash before do_image_wic

