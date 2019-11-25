#!/bin/sh

# Based on: meta-initramfs/recipes-bsp/initrdscripts/files/init-debug.sh
# In open-source project: http://git.openembedded.org/meta-openembedded
#
# Original file: No copyright notice was included
# Modifications: Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FACTORY_CONFIG_LABEL="__REPLACE_ME_WITH_MBL_FACTORY_CONFIG_LABEL__"
FACTORY_CONFIG_MOUNT_OPTS="__REPLACE_ME_WITH_MBL_FACTORY_CONFIG_MOUNT_OPTS__"
FACTORY_CONFIG_MOUNT_POINT="__REPLACE_ME_WITH_MBL_FACTORY_CONFIG_MOUNT_POINT__"
PART_INFO_DIR="__REPLACE_ME_WITH_MBL_PART_INFO_DIR__"
LOG_MOUNT_OPTS="__REPLACE_ME_WITH_MBL_LOG_MOUNT_OPTS__"
LOG_MOUNT_POINT="__REPLACE_ME_WITH_MBL_LOG_MOUNT_POINT__"
BOOTFLAGS_DIR="__REPLACE_ME_WITH_MBL_BOOTFLAGS_DIR__"
MBL_WATCHDOG_TIMEOUT_SECS="__REPLACE_ME_WITH_MBL_WATCHDOG_TIMEOUT_SECS__"
MBL_WATCHDOG_DEVICE_FILENAME="__REPLACE_ME_WITH_MBL_WATCHDOG_DEVICE_FILENAME__"


PATH=/sbin:/bin:/usr/sbin:/usr/bin

# Mount a filesystem at a directory, creating the directory if necessary. If
# the "mount" command fails, run fsck and then try again.
#
# $1: device file
# $2: mount point
# $3-N: other arguments for "mount"
mount_or_fsck() {
    mof_device_file="$1"
    shift
    mof_mount_point="$1"
    shift

    mkdir -p "$mof_mount_point"
    if ! mount "$@" "$mof_device_file" "$mof_mount_point"; then
        # if we fail to mount, try to fix the partition and mount it again
        e2fsck -p -c -f "$mof_device_file"
        mount "$@" "$mof_device_file" "$mof_mount_point"
    fi
}

# Get the "number" of a partition from the name that we call it in
# mbl-partitions.bbclass.
#
# $1: Name of the partition (e.g. "ROOT", "LOG")
# $2: Bank of the partition (either "1" or "2")
get_part_no_for_part() {
    gdfp_part_name="$1"
    gdfp_bank="$2"

    cat "${PART_INFO_DIR}/MBL_${gdfp_part_name}_FS_PART_NUMBER_BANK${gdfp_bank}"
}


mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# We need to check whether we have an active console to call the exec with
# the stdout, stdin and stderr redirections.
# For production images, u-boot sets the kernel console command line to
# "console=", hence there is no active console.
if [ "$(wc -c < /sys/class/tty/console/active)" -gt 0 ]; then
    exec </dev/console >/dev/console 2>/dev/console
fi

# Initialise the hardware watchdog and set the timeout. We need to do this
# in the initramfs, as the watchdog needs to be started before switching to
# the rootfs.
printf "Setting hardware watchdog with device filename %s to timeout of %s seconds\n" \
    "${MBL_WATCHDOG_DEVICE_FILENAME}" "${MBL_WATCHDOG_TIMEOUT_SECS}"
mbl-watchdog-init --timeout ${MBL_WATCHDOG_TIMEOUT_SECS} --device ${MBL_WATCHDOG_DEVICE_FILENAME}

# Enforce that errors after setting up the watchdog will cause a kernel panic
# Note: In production images we may not have a console so 'echo' commands
# may fail, so make sure we ignore these failures using '|| true'
set -e
echo "Booting from init script in initramfs" || true

# We'll mount the factory config partition first because that contains
# information about the partition numbers of the other partitions. That will
# allow us to mount other partitions without relying on their labels. This is
# important in the case of the rootfs because we won't be able to distinguish
# between the two banks of rootfs based on their labels.

# Workaround findfs failure on Raspberry Pi 3: unable to resolve 'LABEL=xxxx'
# We need to wait until the kernel mmc driver is up and all storage partitions
# populated.
while ! findfs LABEL=${FACTORY_CONFIG_LABEL}>/dev/null 2>&1 ; do
    sleep 0.01
done

FACTORY_CONFIG_DEVICE_PATH="$(findfs "LABEL=${FACTORY_CONFIG_LABEL}")"
mount_or_fsck "$FACTORY_CONFIG_DEVICE_PATH" "$FACTORY_CONFIG_MOUNT_POINT" -o "$FACTORY_CONFIG_MOUNT_OPTS"


# The boot flags (which indicate which rootfs bank to use) are temporarily
# stored in the log partition. Mount the log partition so we can check them.

STORAGE_DEVICE_PATH="${FACTORY_CONFIG_DEVICE_PATH%p[0-9]*}"
LOG_PART_NUMBER=$(get_part_no_for_part LOG 1)
LOG_DEVICE_PATH="${STORAGE_DEVICE_PATH}p${LOG_PART_NUMBER}"
mount_or_fsck "$LOG_DEVICE_PATH" "$LOG_MOUNT_POINT" -o "$LOG_MOUNT_OPTS"

# Check for the existence of a flag file indicating that we should use the
# second rootfs bank rather than the first.
ROOTFS_BANK=1
if [ -f "${BOOTFLAGS_DIR}/rootfs2" ]; then
    ROOTFS_BANK=2
fi
ROOTFS_PART_NUMBER="$(get_part_no_for_part ROOT "$ROOTFS_BANK")"
ROOTFS_DEVICE_PATH="${STORAGE_DEVICE_PATH}p${ROOTFS_PART_NUMBER}"

# Switch from initramfs to rootfs
mount_or_fsck "$ROOTFS_DEVICE_PATH" /mnt/rootfs

mount --move /dev /mnt/rootfs/dev
mount --move /proc /mnt/rootfs/proc
mount --move /sys /mnt/rootfs/sys
mount --move "$LOG_MOUNT_POINT" "/mnt/rootfs${LOG_MOUNT_POINT}"
mount --move "$FACTORY_CONFIG_MOUNT_POINT" "/mnt/rootfs${FACTORY_CONFIG_MOUNT_POINT}"
cd /mnt/rootfs

echo "Switching to $ROOTFS_DEVICE_PATH" || true

# Switch to the new filesystem, and run /sbin/init out of it
exec switch_root -c /dev/console /mnt/rootfs /sbin/init
