###############################################################################
# mbed Linux 
# Copyright (c) 2017 ARM Limited
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

###############################################################################
# mbl-console-image.bb
#   This file is the mbed linux OpenEmbedded recipe for building a minimal 
#   uboot/kernel/filesystem image 
###############################################################################
SUMMARY = "Mbed Linux Basic Minimal Image"

###############################################################################
# IMAGE_INSTALL: 
#   Specify the packages installed in the distribution images prior to
#   inheriting from core-image to override the default behaviour. 
#   
#     packagegroup-core-boot        Essential packages to boot minimal sysmtem.
#     packagegroup-mbl              mbed linux packages added for this image.
#     CORE_IMAGE_EXTRA_INSTALL      Symbol conventionally defined in local.conf 
#                                   to add extra packages.
#
# IMAGE_FEATURES: specify additional packages
#   debug-tweaks                  
#       Included in image so root has empty password.The extrausers class 
#       in also used so EXTRA_USERS_PARAMS can specify the empty password. 
###############################################################################
IMAGE_INSTALL = "\
	packagegroup-core-boot \
	packagegroup-base \
	packagegroup-mbl \
	${CORE_IMAGE_EXTRA_INSTALL}"

IMAGE_LINGUAS = " "
IMAGE_FEATURES += "debug-tweaks"

LICENSE = "MIT"
HOMEPAGE = "https://github.com/ARMmbed/meta-mbl"

inherit core-image extrausers

IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "" ,d)}"

# Add a root account with empty password
EXTRA_USERS_PARAMS = "useradd -p '' root;"

# No GPLv3 allowed in this image
IMAGE_LICENSE_CHECKER_BLACKLIST = "GPL-3.0 LGPL-3.0 AGPL-3.0"
inherit image-license-checker image-signing image-verity key-generation



