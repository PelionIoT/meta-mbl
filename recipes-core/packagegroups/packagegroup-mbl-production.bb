# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "mbed linux additional packages"
DESCRIPTION = "mbed linux additional packages to those of the minimal console default setup."
inherit packagegroup

###############################################################################
# Packages added irrespective of the MACHINE
#     - runc-opencontainers. Open Container Initiative (oci) containerised 
#       environment for secure application execution.
#     - kernel-modules. Required by iptables related modules (e.g. netfilter
#       connection tracking.
#     - optee-os. If the machine supports optee include the os.
#     - optee-client. If the machine supports optee include the client.
###############################################################################
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " avahi-autoipd"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " ca-certificates"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " runc-opencontainers"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " iptables"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " kernel-modules"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " rng-tools"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " opkg"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " mbl-app-manager"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " mbl-app-lifecycle-manager"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " mbl-app-update-manager"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " mbl-firmware-update-manager"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " python3-core"
# pyhton3-debugger and python3-doctest are included because Pytest is
# dependent on them.
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " python3-debugger"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " python3-doctest"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " python3-logging"
# See meta-mbl/recipes-devtools/python/python3_%.bbappend for information
# on why python3-ntpath is included in the package group.
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " python3-ntpath"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " python3-pip"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " python3-runpy"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " python3-shell"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " python3-venv"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " mbl-cloud-client"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " optee-os"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " optee-client"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " connman"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " connman-client"

###############################################################################
# Packages added when the MACHINE and DISTRO have specific features
#     - usbinit - bring up the usb0 network interface during boot
###############################################################################
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " ${@bb.utils.contains('COMBINED_FEATURES', 'usbgadget', 'usbinit', '', d)}"

RDEPENDS_packagegroup-mbl-production += "${PACKAGEGROUP_MBL_PRODUCTION_PKGS}"
