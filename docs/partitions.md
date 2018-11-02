# Current Mbed Linux OS partition layout

## General information

The partition layout for every board includes at least the following partitions

| Label            | ro/rw | Type         | Mount point      | Size     | Contains |
|------------------|-------|--------------|------------------|----------|----------|
| boot             | ro    | vfat or ext4 | /boot            | 30MiB    | Kernel, device tree and U-Boot boot script |
| bootflags        | rw    | ext4         | /mnt/flags       | 20MiB    | Flags to determine which rootfs is active |
| rootfs1          | rw    | ext4         | /                | 500MiB   | Root filesystem for installation 1 |
| rootfs2          | rw    | ext4         | /                | 500MiB   | Root filesystem for installation 2 |
| factory_config   | rw    | ext4         | /config/factory  | 20MiB    | Factory configuration |
| nfactory_config1 | rw    | ext4         | /config/user     | 20MiB    | User data configuration |
| nfactory_config2 | rw    | ext4         | /config/user     | 20MiB    | Unused |
| rootfs1_ver_hash | rw    | ext4         | /mnt/verity_hash | 20MiB    | dm_verity meta-data for rootfs1 |
| rootfs2_ver_hash | rw    | ext4         | /mnt/verity_hash | 20MiB    | dm_verity meta-data for rootfs2 |
| log              | rw    | ext4         | /var/log         | 20MiB    | Log files |
| scratch          | rw    | ext4         | /scratch         | 500MiB   | Temporary files (such as downloaded firmware files) |
| home             | rw    | ext4         | /home            | 450MiB   | User application storage |

## Board specific information

### Raspberry Pi 3

Full partition layout:

| Label            | Size   | U-Boot iface dev:part | Linux device file | Notes    |
|------------------|--------|-----------------------|-------------------|----------|
| boot             | 30MiB  | mmc 0:1               | mmcblk0p1         | Primary  |
| bootflags        | 20MiB  | mmc 0:2               | mmcblk0p2         | Primary  |
| rootfs1          | 500MiB | mmc 0:3               | mmcblk0p3         | Primary  |
| -                | -      | mmc 0:4               | mmcblk0p4         | Extended |
| rootfs2          | 500MiB | mmc 0:5               | mmcblk0p5         | Logical  |
| factory_config   | 20MiB  | mmc 0:6               | mmcblk0p6         | Logical  |
| nfactory_config1 | 20MiB  | mmc 0:7               | mmcblk0p7         | Logical  |
| nfactory_config2 | 20MiB  | mmc 0:8               | mmcblk0p8         | Logical  |
| log              | 20MiB  | mmc 0:9               | mmcblk0p9         | Logical  |
| scratch          | 500MiB | mmc 0:10              | mmcblk0p10        | Logical  |
| rootfs1_ver_hash | 20MiB  | mmc 0:11              | mmcblk0p11        | Logical  |
| rootfs2_ver_hash | 20MiB  | mmc 0:12              | mmcblk0p12        | Logical  |
| home             | 450MiB | mmc 0:13              | mmcblk0p13        | Logical  |

### Warp7

On Warp7 there is an area of the disk used for TF-A (Trusted Firmware-A) and 
BL2 (Second Boot Loader) images. It is the first "partition" although it is not in the 
disk's partition table.

Full partition layout:

| Label            | Size   | U-Boot iface dev:part | Linux device file | Notes       |
|------------------|--------|-----------------------|-------------------|-------------|
| -                | 4MiB   | -                     | -                 | TF-A and BL2 |
| boot             | 32MiB  | mmc 0:1               | mmcblk0p1         | Primary     |
| bootflags        | 20MiB  | mmc 0:2               | mmcblk0p2         | Primary     |
| rootfs1          | 500MiB | mmc 0:3               | mmcblk0p3         | Primary     |
| -                | -      | mmc 0:4               | mmcblk0p4         | Extended    |
| rootfs2          | 500MiB | mmc 0:5               | mmcblk0p5         | Logical     |
| factory_config   | 20MiB  | mmc 0:6               | mmcblk0p6         | Logical     |
| nfactory_config1 | 20MiB  | mmc 0:7               | mmcblk0p7         | Logical     |
| nfactory_config2 | 20MiB  | mmc 0:8               | mmcblk0p8         | Logical     |
| log              | 20MiB  | mmc 0:9               | mmcblk0p9         | Logical     |
| scratch          | 500MiB | mmc 0:10              | mmcblk0p10        | Logical     |
| rootfs1_ver_hash | 20MiB  | mmc 0:11              | mmcblk0p11        | Logical     |
| rootfs2_ver_hash | 20MiB  | mmc 0:12              | mmcblk0p12        | Logical     |
| home             | 450MiB | mmc 0:13              | mmcblk0p13        | Logical     |


## Notes on firmware update

To support firmware updates, Mbed Linux OS system has storage for two
separate firmware installations and a mechanism to select which installation to
boot into after reboots. 

A flag file in the bootflags partition is used to indicate which root partition
is currently active. If there is a file called "rootfs2" in the bootflags
partition then U-boot will use rootfs2 as the root partition, otherwise it will
use rootfs1.

Each firmware installation is separated into several partitions: a
read-write root partition, a configuration partition and a user application
partition. Using a separate partition for the user application eases the
support of updates of just the user application.

In the case of configuration that should persist across firmware updates, 
Mbed Linux OS system actually stores three versions: a configuration for each firmware
installation (stored on the installation's "config" partition) and the initial
configuration installed at build time and/or at the factory (stored on the
"nfactory_config" partition). During firmware updates, the configuration for the newly
installed firmware will be created based on the configuration for the currently
running installation, rules contained in a "configuration update" script in
attached to the new firmware and, possibly, the initial factory configuration.

Additionally, there is the "scratch" partition for temporary storage of firmware
downloaded during the update process. This partition is shared between the 
firmware installations. 

## Future plans

New "BL3 FIP Image" partition should hold versions of the BL31 boot loader and associated 
components contained within a signed FIP image.

"rootfs_ver_hash" partitions should include meta-data for the dm-verity tool 
for the corresponding root filesystem.  

"rootfs_ver_hash", "factory_config" and "rootfs" partitions should be switched to read-only mode
(currently these partitions are read-write). 

The new "BL3 FIP Image" and the existing "boot", "rootfs1_ver_hash" and "nfactory_config1" 
partitions should be banked.
