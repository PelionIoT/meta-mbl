# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "mbed linux additional packages for development distribution"
DESCRIPTION = "mbed linux additional packages to those of the minimal console default setup for test and development."

inherit packagegroup


###############################################################################
# Packages added irrespective of the MACHINE
#     - dropbear. To support ssh during development and test.
#     - optee-test. Include the optee test suite.
#     - systemd-net-conf-dbg-iface. Systemd related network service for the
#       debug interface (e.g. usbgadget). This package should only be installed
#       if usbgadget is in the COMBINED_FEATURES.
###############################################################################
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append = " dropbear"
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append = " python3 python3-pip"
# glib-2.0, python3-pygobject and gobject-introspection are included because
# pydbus requires them.
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append = " glib-2.0"
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append = " python3-pygobject"
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append = " gobject-introspection"
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append = " e2fsprogs"
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append = " mbed-crypto-test"
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append = " memtester"
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append = " strace"
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append = " optee-test"
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append = " openssh-sftp-server"
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append = " ${@bb.utils.contains('COMBINED_FEATURES', 'usbgadget', 'systemd-net-conf-dbg-iface', '', d)}"
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append = " systemd-analyze"
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append = " psa-trusted-storage-linux-test"

###############################################################################
# Packages that can optionally be added (irrespective of MACHINE)
# Uncomment the relevant line to include the package:
#     - kernel-devsrc. Include kernel development sources.
###############################################################################
#PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append_imx7s-warp = " kernel-devsrc"


###############################################################################
# Packages added for MACHINE=imx7s-warp
#     - v4l-utils. MACHINE has video4linux camera driver so includ utils.
###############################################################################
PACKAGEGROUP_MBL_DEVELOPMENT_PKGS_append_imx7s-warp = " v4l-utils"


###############################################################################
# Packages added for MACHINE=raspberrypi3
#     - add packages only added to raspberrypi3 images below here.
###############################################################################


RDEPENDS_packagegroup-mbl-development += "${PACKAGEGROUP_MBL_DEVELOPMENT_PKGS}"



