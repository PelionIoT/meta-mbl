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
# runc-docker_git.bbappend
#   This file modifies the behaviour of the runc-docker_git recipe so the 
#   packages are built. runc-docker_git.bb incorrectly defines the 
#   git source revision to download by defining SRCREV_runc-docker rather 
#   than SRCREV_pn-runc-docker (the correct form). However, here the 
#   problem is resolved by defining SRCREV, which is simpler and more 
#   commonly used.
###############################################################################
SRCREV := "${SRCREV_runc-docker}"
