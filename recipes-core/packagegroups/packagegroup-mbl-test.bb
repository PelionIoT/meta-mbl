# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "mbed linux additional packages for test distribution"
DESCRIPTION = "mbed linux additional packages to those of the minimal console default setup for test and development."

inherit packagegroup


###############################################################################
# Packages added irrespective of the MACHINE
#     - dropbear. To support ssh during development and test.
#     - optee-test. Include the optee test suite.
###############################################################################
PACKAGEGROUP_MBL_TEST_PKGS_append = " dropbear"
PACKAGEGROUP_MBL_TEST_PKGS_append = " dropbear-ssh-dns-sd"
PACKAGEGROUP_MBL_TEST_PKGS_append = " python3 python3-pip"
PACKAGEGROUP_MBL_TEST_PKGS_append = " e2fsprogs"
PACKAGEGROUP_MBL_TEST_PKGS_append = " memtester"
PACKAGEGROUP_MBL_TEST_PKGS_append = " strace"
PACKAGEGROUP_MBL_TEST_PKGS_append = " optee-test"
PACKAGEGROUP_MBL_TEST_PKGS_append = " openssh-sftp-server"


###############################################################################
# Packages that can optionally be added (irrespective of MACHINE)
# Uncomment the relevant line to include the package:
#     - kernel-devsrc. Include kernel development sources.
###############################################################################
#PACKAGEGROUP_MBL_TEST_PKGS_append_imx7s-warp = " kernel-devsrc"


###############################################################################
# Packages added for MACHINE=imx7s-warp
#     - v4l-utils. MACHINE has video4linux camera driver so includ utils.
###############################################################################
PACKAGEGROUP_MBL_TEST_PKGS_append_imx7s-warp = " v4l-utils"


###############################################################################
# Packages added for MACHINE=raspberrypi3
#     - add packages only added to raspberrypi3 images below here.
###############################################################################


RDEPENDS_packagegroup-mbl-test += "${PACKAGEGROUP_MBL_TEST_PKGS}"



