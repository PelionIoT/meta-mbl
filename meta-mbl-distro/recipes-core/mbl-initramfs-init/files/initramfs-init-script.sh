#!/bin/sh

# Based on: meta-initramfs/recipes-bsp/initrdscripts/files/init-debug.sh
# In open-source project: http://git.openembedded.org/meta-openembedded
#
# Original file: No copyright notice was included
# Modifications: Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

LOG_PARTITION_LABEL="__REPLACE_ME_WITH_MBL_LOG_LABEL__"
LOG_MOUNT_OPTS="__REPLACE_ME_WITH_MBL_LOG_MOUNT_OPTS__"
LOG_MOUNT_POINT="__REPLACE_ME_WITH_MBL_LOG_MOUNT_POINT__"
BOOTFLAGS_DIR="__REPLACE_ME_WITH_MBL_BOOTFLAGS_DIR__"
ROOTFS_LABEL_BASE="__REPLACE_ME_WITH_MBL_ROOT_LABEL__"

PATH=/sbin:/bin:/usr/sbin:/usr/bin

mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# We need to check whether we have an active console to call the exec with the stdout, stdin and stderr redirections.
# For production images, u-boot sets the kernel console command line to "console=", hence there is no active console.
if [ $(cat /sys/class/tty/console/active | wc -c) -gt 0 ]
then
    exec </dev/console >/dev/console 2>/dev/console
fi

echo "Booting from init script in initramfs"

# Workaround findfs failure on Raspberry Pi 3: unable to resolve 'LABEL=xxxx'
# We need to wait until the kernel mmc driver is up and all storage partitions populated.
while ! findfs LABEL=${LOG_PARTITION_LABEL}>/dev/null 2>&1 ; do
    sleep 0.01
done

# The boot flags (which indicate which rootfs bank to use) are temporarily stored
# in the log partition. Mount the log partition so we can check them.

LOG_PARTITION="$(findfs "LABEL=${LOG_PARTITION_LABEL}")"
mkdir -p "$LOG_MOUNT_POINT"
mount -o "$LOG_MOUNT_OPTS" "$LOG_PARTITION" "$LOG_MOUNT_POINT"

# Check for the existence of a flag file indicating that we should use the
# second rootfs bank rather than the first.
ROOTFS_LABEL="${ROOTFS_LABEL_BASE}2"
if [ ! -f "${BOOTFLAGS_DIR}/${ROOTFS_LABEL}" ]
then
    ROOTFS_LABEL="${ROOTFS_LABEL_BASE}1"
fi


ROOTFS_PARTITION="$(findfs LABEL=$ROOTFS_LABEL)"

#Switch from initramfs to rootfs:

mkdir -p /mnt/rootfs
mount $ROOTFS_PARTITION /mnt/rootfs

mount --move /dev /mnt/rootfs/dev
mount --move /proc /mnt/rootfs/proc
mount --move /sys /mnt/rootfs/sys
mount --move "$LOG_MOUNT_POINT" "/mnt/rootfs${LOG_MOUNT_POINT}"
cd /mnt/rootfs

echo "Switching to $ROOTFS_PARTITION"

#Switch to the new filesystem, and run /sbin/init out of it
exec switch_root -c /dev/console /mnt/rootfs /sbin/init

