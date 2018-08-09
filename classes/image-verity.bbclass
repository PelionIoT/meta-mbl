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

#This task creates a rootfs hash tree and root hash using dm-verity veritysetup tool on the host
do_generate_verity_metadata() {
   
  veritysetup format ${IMGDEPLOYDIR}/mbl-console-image-${MACHINE}.ext4  ${IMGDEPLOYDIR}/mbl-console-image-${MACHINE}_hash_tree.bin\
  > ${IMGDEPLOYDIR}/mbl-console-image-${MACHINE}_verity_header_information.txt
         
  grep "Root hash:" ${IMGDEPLOYDIR}/mbl-console-image-${MACHINE}_verity_header_information.txt | sed -e 's/.*:[[:blank:]]*//'\
  > ${IMGDEPLOYDIR}/mbl-console-image-${MACHINE}_root_hash.txt
}

addtask generate_verity_metadata after do_image_ext4 before do_image_wic

