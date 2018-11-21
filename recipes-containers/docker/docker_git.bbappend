# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

###############################################################################
# docker_git.bbappend
#   This file modifies the behaviour of the docker_git recipe to:
#       - Set OS_DEFAULT_INITSCRIPT_PARAMS so update-rc.d installs the 
#         script correctly.
#       - Disables the unnecessary RSUGGESTS directive suggesting lxc.  
#       - Restore the default build behaviour of stripping binaries.
###############################################################################
OS_DEFAULT_INITSCRIPT_PARAMS := "defaults" 

RSUGGESTS_${PN} = ""
INHIBIT_PACKAGE_STRIP = "0"

# Add logrotate config
MBL_LOGROTATE_CONFIG_LOG_NAMES = "dockerd"
MBL_LOGROTATE_CONFIG_LOG_PATH[dockerd] = "/var/log/dockerd"
MBL_LOGROTATE_CONFIG_ROTATE[dockerd] = "4"
MBL_LOGROTATE_CONFIG_SIZE[dockerd] = "1M"
inherit mbl-logrotate-config
