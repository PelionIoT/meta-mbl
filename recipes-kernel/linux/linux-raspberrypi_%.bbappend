###############################################################################
# Copyright (c) 2018 ARM Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
###############################################################################

INITRAMFS_IMAGE = "mbl-console-image-initramfs"

FILESEXTRAPATHS_prepend:="${THISDIR}/files:"

SRC_URI += "file://*-mbl.cfg \
"

# LOADADDR is 0x00080000 by default. But we need to put FIP between
# 0x00020000 ~ 0x00200000. Thus we move kernel to another address.
KERNEL_EXTRA_ARGS += " LOADADDR=0x04000000 "

do_configure_prepend() { 
    ${S}/scripts/kconfig/merge_config.sh -m -O ${B} ${B}/.config ${WORKDIR}/*-mbl.cfg    
}
