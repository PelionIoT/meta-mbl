SUMMARY = "mbed linux additional packages"
DESCRIPTION = "mbed linux additional packages to those of the minimal console default setup."
inherit packagegroup

###############################################################################
# Packages added irrespective of the MACHINE
#     - ca-certificates. Required by docker when performing pull from dockerhub
#     - docker. Containerised environment for secure application execution.
#     - iptables. Required by docker for building iptables DOCKER-ISOLATION 
#       and DOCKER chains for the FORWARD table.
#     - kernel-modules. Required by iptables related modules (e.g. netfilter
#       connection tracking.
#     - optee-os. If the machine supports optee include the os.
#     - optee-client. If the machine supports optee include the client.
###############################################################################
PACKAGEGROUP_MBL_PKGS_append = " avahi-autoipd"
PACKAGEGROUP_MBL_PKGS_append = " ca-certificates"
PACKAGEGROUP_MBL_PKGS_append = " docker"
PACKAGEGROUP_MBL_PKGS_append = " iptables"
PACKAGEGROUP_MBL_PKGS_append = " kernel-modules"
PACKAGEGROUP_MBL_PKGS_append = " rng-tools"
PACKAGEGROUP_MBL_PKGS_append = " opkg"
PACKAGEGROUP_MBL_PKGS_append = " mbl-app-manager"
PACKAGEGROUP_MBL_PKGS_append = " mbl-app-lifecycle-manager"
PACKAGEGROUP_MBL_PKGS_append = " mbl-app-update-manager"
PACKAGEGROUP_MBL_PKGS_append = " mbl-firmware-update-manager"
PACKAGEGROUP_MBL_PKGS_append = " python3-core"
PACKAGEGROUP_MBL_PKGS_append = " python3-logging"
PACKAGEGROUP_MBL_PKGS_append = " python3-pip"
PACKAGEGROUP_MBL_PKGS_append = " python3-pyvenv"
PACKAGEGROUP_MBL_PKGS_append = " python3-runpy"
PACKAGEGROUP_MBL_PKGS_append = " python3-shell"
PACKAGEGROUP_MBL_PKGS_append = " mbl-cloud-client"
PACKAGEGROUP_MBL_PKGS_append = " optee-os"
PACKAGEGROUP_MBL_PKGS_append = " optee-client"
PACKAGEGROUP_MBL_PKGS_append = " connman"
PACKAGEGROUP_MBL_PKGS_append = " connman-client"

###############################################################################
# Packages added when the MACHINE and DISTRO have specific features
#     - usbinit - bring up the usb0 network interface during boot
###############################################################################
PACKAGEGROUP_MBL_PKGS_append = " ${@bb.utils.contains('COMBINED_FEATURES', 'usbgadget', 'usbinit', '', d)}"

RDEPENDS_packagegroup-mbl += "${PACKAGEGROUP_MBL_PKGS}"
