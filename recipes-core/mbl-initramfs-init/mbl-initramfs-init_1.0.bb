# SPDX-License-Identifier: MIT
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal 
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
# THE SOFTWARE.

# Based on meta-initramfs/recipes-bsp/initrdscripts/initramfs-debug_1.0.bb
# meta-openembedded repo (https://github.com/openembedded/meta-openembedded)

SUMMARY = "mbl initramfs image init script"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
SRC_URI = "file://initramfs-init-script.sh"

S = "${WORKDIR}"

do_install() {
        install -m 0755 ${WORKDIR}/initramfs-init-script.sh ${D}/init

        # Fetch verity rootfs root hash public key
        install -m 0644 ${VERITY_KEYS_DIR}/${VERITY_ROOTFS_ROOT_HASH_PUBLIC_KEY_NAME} ${D}/${VERITY_ROOTFS_ROOT_HASH_PUBLIC_KEY_NAME}
}

inherit allarch

FILES_${PN} += " /init /${VERITY_ROOTFS_ROOT_HASH_PUBLIC_KEY_NAME} "

