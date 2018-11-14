# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

###############################################################################
# runc-docker_git.bbappend
#   This file:
#    - modifies the behaviour of the runc-docker_git recipe so the 
#      packages are built. runc-docker_git.bb incorrectly defines the 
#      git source revision to download by defining SRCREV_runc-docker rather 
#      than SRCREV_pn-runc-docker (the correct form). However, here the 
#      problem is resolved by defining SRCREV, which is simpler and more 
#      commonly used.
#    - Removes the unnecessary RRECOMMENDS lxc directive.  
#    - Restore the default build behaviour of stripping binaries.
###############################################################################
SRCREV := "${SRCREV_runc-docker}"

RRECOMMENDS_${PN}_remove = "lxc"
INHIBIT_PACKAGE_STRIP = "0"
