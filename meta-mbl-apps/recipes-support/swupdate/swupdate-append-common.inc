# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Building swupdate together with MBL's custom handlers is a bit convoluted.
# See the comment in swupdate_%.bbappend for details.

# We don't want any swupdate systemd service installed
SYSTEMD_PACKAGES = ""

# Change the location of the software versions file to our user config partition.
do_configure_prepend() {
    printf 'CONFIG_SW_VERSIONS_FILE="%s"' "${MBL_CONFIG_DIR}/sw-versions" >> "${WORKDIR}/defconfig"
}

# Patch swupdate to tell it to link our handlers. We also add a menuconfig item so they
# can be disabled if desired.
SRC_URI += "\
file://0001-Add-config-for-arm-handler-common-and-rootfs-handler.patch \
file://0001-Link-arm-swupdate-handlers-with-handler-module.patch \
"
