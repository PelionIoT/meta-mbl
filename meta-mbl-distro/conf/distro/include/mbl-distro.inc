# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

require conf/distro/mbl-directories.conf
require conf/distro/mbl-linked-repositories.conf

# We don't want to append the libc type into TMPDIR
TCLIBCAPPEND = ""

INHERIT += "mbl-partitions"

DISTRO_NAME = "Mbed Linux OS"
DISTRO_VERSION = "0.0"
DISTRO_FEATURES_append = " virtualization"

# Set systemd as the init manager
DISTRO_FEATURES_append = " systemd"
VIRTUAL-RUNTIME_init_manager = "systemd" 
VIRTUAL-RUNTIME_initscripts = "systemd-compat-units"
DISTRO_FEATURES_BACKFILL_CONSIDERED = "sysvinit"

# We don't want to install avahi-daemon to deal with mDNS.
# We are using systemd-resolved instead
DISTRO_FEATURES_DEFAULT_remove = "zeroconf"

# Enable build history with installed package size information and image info.
INHERIT += "buildhistory"
INHERIT += "image-buildinfo"
BUILDHISTORY_COMMIT = "1"

IMAGE_FSTYPES = "ext4 wic.gz wic.bmap tar.xz"

# Prevent OE from messing around too much with /var/log - we have a separate
# partition for it
VOLATILE_LOG_DIR = "no"

# Remove x11 related packages for distro images.
DISTRO_FEATURES_DEFAULT_remove = "x11"

# dosfstools is in RRECOMMENDS for packagegroup-base-vfat but it's GPLv3 so we
# don't want it
BAD_RECOMMENDATIONS += "dosfstools"

# docker and lxc is in RRECOMMENDS for runc-opencontainers package - we do not need it
# We would like to have the minimal runc functionality
BAD_RECOMMENDATIONS += "docker lxc"

# readline is GPLv3 so don't include the command line tools for bluez5 that
# depend on readline
PACKAGECONFIG_remove_pn-bluez5 = "readline"

# By default wpa-supplicant uses gnutls as its TLS library, but gnutls depends
# on libunistring which is GPLv3, so tell wpa-supplicant to use openssl instead
# of gnutls.
PACKAGECONFIG_pn-wpa-supplicant = "openssl"

# Set runc preferred provider to Open Container Initiative (OCI) runc (default is runc-docker)
PREFERRED_PROVIDER_virtual/runc = "runc-opencontainers"

INITRAMFS_IMAGE = "mbl-image-initramfs"

WKS_FILE = "mbl.wks.in"
