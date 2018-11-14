# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

###############################################################################
# runc-opencontainers_git.bbappend
#   This file modifies the behaviour of the docker_git recipe to:
#       - Removes the unnecessary RRECOMMENDS lxc directive.  
#       - Restore the default build behaviour of stripping binaries.
###############################################################################
RRECOMMENDS_${PN}_remove = "lxc"
INHIBIT_PACKAGE_STRIP = "0"
