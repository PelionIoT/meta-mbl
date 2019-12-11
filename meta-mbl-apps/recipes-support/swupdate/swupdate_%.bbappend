# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Building swupdate together with MBL's custom handlers is, unfortunately, a
# bit convoluted. We do it in three steps:
#
# 1. Use the swupdate-headers recipe to configure and install header files from
# swupdate that are used by MBL's custom handlers. The swupdate-headers-dev
# package, produced by the swupdate-headers recipe, is sort-of
# like an unnoficial swupdate-dev package, but it's not called swupdate-dev to
# avoid clashes with the swupdate recipe itself.
#
# 2. Use the swupdate-handlers recipe to build MBL's custom handlers into a
# library.
#
# 3. Use the swupdate recipe (modified by this bbappend) to do a build of
# swupdate that includes the custom handlers. We include our handlers by
# linking in the library created by swupdate-handlers, but they still need to
# be registered by swupdate. To do that we add "arm-handlers.c" to the swupdate
# source.

require swupdate-append-common.inc

# Add our swupdate config, which disables CONFIG_UBOOT and sets CONFIG_BOOTLOADER_NONE.
# We also disable the remote handler and webserver features.
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

DEPENDS += "swupdate-handlers"
SRC_URI += "file://arm-handlers.c;subdir=git/handlers"
# Override to remove the installation of all systemd.service files. We need this as swupdate's systemd
# integration is baked in to swupdate.inc in meta-swupdate.
do_install() {
    oe_runmake install
}

