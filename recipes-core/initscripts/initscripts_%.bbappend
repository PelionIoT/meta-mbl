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
# initscripts_%.bbappend
#   This file modifies the behaviour of the initscripts_1.0.bb recipe to
#   patch the initialisation script bootmisc.init to start to set the system
#   date time correctly.   
###############################################################################
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += "file://0001-IOTMBL58-bootmisc.sh-fix-issue-with-setting-system-d.patch;striplevel=5;patchdir=${WORKDIR}"

# make sure the local appending config file will be chosen by prepending and extra local path
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = "  file://hostname.sh"
