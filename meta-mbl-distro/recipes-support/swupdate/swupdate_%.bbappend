# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# We need to configure swupdate to unset CONFIG_UBOOT and set CONFIG_BOOTLOADER_NONE.
# We also remove its remote handler and webserver features.
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# Tell swupdate to not try and install systemd.service files which don't exist, as we're
# overriding do_install to remove them.
SYSTEMD_SERVICE_${PN} = ""

# Change the location of the software versions file to our user config partition.
do_configure_prepend() {
    printf 'CONFIG_SW_VERSIONS_FILE="%s"' "${MBL_CONFIG_DIR}/sw-versions" >> "${WORKDIR}/defconfig"
}

# Override to remove the installation of all systemd.service files. We need this as swupdate's systemd
# integration is baked in to swupdate.inc in meta-swupdate.
do_install() {
    oe_runmake install
}
