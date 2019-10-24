# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "mbed linux additional packages"
DESCRIPTION = "mbed linux additional packages to those of the minimal console default setup."
inherit packagegroup

# These packages are all dependencies of pytest. We only install pytest on a
# board at runtime when we want to do testing, so we can't rely on RDEPENDS to
# install them all for us. Additionally, we can't rely on pip's dependency
# mechanism to install them for us when we install pytest because outside of
# Yocto, all of these packages are just part of the python3 base installation -
# Yocto splits up the python3 base installation into smaller packages, but pip
# doesn't know about those smaller packages.
PYTEST_DEPENDENCIES = " \
    python3-debugger \
    python3-doctest \
    python3-pathlib \
"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " ${PYTEST_DEPENDENCIES}"


###############################################################################
# Packages added irrespective of the MACHINE
#     - runc-opencontainers. Open Container Initiative (oci) containerised
#       environment for secure application execution.
#     - kernel-modules. Required by iptables related modules (e.g. netfilter
#       connection tracking.
#     - optee-client. If the machine supports optee include the client.
#     - systemd-net-conf. Systemd related network configuration files (e.g.
#       hostname setup).
###############################################################################
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
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " python3-logging"
# python3-pickle is required for "python3 -m pip install -U pytest"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " python3-pickle"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " python3-pip"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " python3-shell"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " python3-venv"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " mbl-cloud-client"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " optee-client"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " connman"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " connman-client"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " systemd-net-conf"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " systemd-watchdog-conf"
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " swupdate"
# Packages to be installed when 'production-dbg' PACKAGECONFIG is set
PACKAGEGROUP_MBL_PRODUCTION_PKGS_append = " \
    ${@ bb.utils.contains('COMBINED_FEATURES', 'usbgadget', 'systemd-net-conf-dbg-iface', '', d) if bb.utils.contains('PACKAGECONFIG', 'production-eth-dbg', 'True', '', d) else ''} \
    ${@ bb.utils.contains('PACKAGECONFIG', 'production-eth-dbg', 'dropbear', '', d)} \
    "

RDEPENDS_packagegroup-mbl-production += "${PACKAGEGROUP_MBL_PRODUCTION_PKGS}"
