# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

###############################################################################
# runc-opencontainers_git.bbappend
#   This file modifies the behaviour of the docker_git recipe to:
#       - Removes the unnecessary RRECOMMENDS lxc and docker directives.  
#       - Restore the default build behaviour of stripping binaries.
#       - Remove docker-run -> runc soft link
###############################################################################
INHIBIT_PACKAGE_STRIP = "0"

# This soft link was added on original recipe to link docker-runc -> runc
do_install_append() {
	rm ${D}/${bindir}/docker-runc
}

# Add cgroup-lite package to set up cgroups at system boot. This is only recommended since
# runc can runc without this added package.
# If not added, before starting a container, container invoker will have to manually mount the cgroups.
RRECOMMENDS_${PN} += "cgroup-lite"
