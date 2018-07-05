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

# initramfs image. 
# Based on meta-initramfs/recipes-bsp/images/initramfs-debug-image.bb from the 
# meta-openembedded repo (https://github.com/openembedded/meta-openembedded)

DESCRIPTION = "Small image capable of booting a device. The kernel includes \
the Minimal RAM-based Initial Root Filesystem (initramfs). This image includes \
initramfs script for switching to rootfs. Later on we will use this script to \
verify signatures and activating dm-verity."

PACKAGE_INSTALL = "mbl-initramfs-init util-linux-findfs busybox"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""

export IMAGE_BASENAME = "mbl-console-image-initramfs"
IMAGE_LINGUAS = ""

LICENSE = "MIT"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
inherit core-image

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

NO_RECOMMENDATIONS = "1"

# EXTRA_IMAGEDEPENDS may be set to include atf-* in the <MACIHNE>.conf file
#  which is required for mbl-console-image. However, in the case of
#  mbl-console-image-initramfs for atf-warp7 it creates an unwanted circular
#  dependency. There EXTRA_IMAGEDEPENDS is therefore cleared in mbl-console-image-initramfs
#  to stop this circular dependency being formed.
EXTRA_IMAGEDEPENDS = ""
