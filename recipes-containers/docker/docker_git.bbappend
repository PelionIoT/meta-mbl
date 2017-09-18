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
# docker_git.bbappend
#   This file modifies the behaviour of the docker_git recipe to:
#       - Patch the sysvinit script docker.init to start the daemon dockerd.
#         See the patch header for more details.
#       - Set OS_DEFAULT_INITSCRIPT_PARAMS so update-rc.d installs the 
#         script correctly.
#       - Disables the unnecessary RSUGGESTS directive suggesting lxc.  
#       - Restore the default build behaviour of stripping binaries.
###############################################################################
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += "file://0001-IOTMBL-7-docker.init-commit-to-create-patch-for-dock.patch;striplevel=4;patchdir=${WORKDIR}"
OS_DEFAULT_INITSCRIPT_PARAMS := "defaults" 

RSUGGESTS_${PN} = ""
INHIBIT_PACKAGE_STRIP = "0"
