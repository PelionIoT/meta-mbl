# Current Mbed Linux partition layout

## General information

The partition layout for every board includes at least the following partitions

| Label     | ro/rw | Type | Mount point | Size     | Contains |
|-----------|-------|------|-------------|----------|----------|
| boot      | rw    | vfat | /boot       | 16-20MiB | Kernel, device tree, U-boot script |
| bootflags | rw    | ext4 | /mnt/flags  | 20MiB    | Flags to determine which rootfs is active |
| rootfs1   | rw    | ext4 | /           | 500MiB   | Root filesystem for installation 1 |
| rootfs2   | rw    | ext4 | /           | 500MiB   | Root filesystem for installation 2 |
| config    | rw    | ext4 | /config     | 40MiB    | Wifi config, Mbed Cloud Client config |
| cache     | rw    | ext4 | /mnt/cache  | 500MiB   | Firmware downloads |

## Board specific information

### Raspberry Pi 3

Full partition layout:

| Label     | Offset         | Size   | U-Boot iface dev:part | Linux device file | Notes    |
|-----------|----------------|--------|-----------------------|-------------------|----------|
| boot      | 4MiB           | 20MiB  | mmc 0:1               | mmcblk0p1         | Primary  |
| bootflags | 24MiB          | 20MiB  | mmc 0:2               | mmcblk0p2         | Primary  |
| rootfs1   | 44MiB          | 500MiB | mmc 0:3               | mmcblk0p3         | Primary  |
| -         | 544MiB         | -      | mmc 0:4               | mmcblk0p4         | Extended |
| rootfs2   | 544MiB+0.5KiB  | 500MiB | mmc 0:5               | mmcblk0p5         | Logical  |
| config    | 1044MiB+1KiB   | 40MiB  | mmc 0:6               | mmcblk0p6         | Logical  |
| cache     | 1084MiB+1.5KiB | 500MiB | mmc 0:7               | mmcblk0p7         | Logical  |


### Warp7

On Warp7 there is an area of the disk used for a raw U-Boot image. It is the
first "partition" although it is not in the disk's partition table.

Full partition layout:

| Label     | Offset         | Size    | U-Boot iface dev:part | Linux device file | Notes    |
|-----------|----------------|---------|-----------------------|-------------------|----------|
| -         | 1MiB           | <= 3MiB | -                     | -                 | U-Boot   |
| boot      | 4MiB           | 16MiB   | mmc 0:1               | mmcblk1p1         | Primary  |
| bootflags | 20MiB          | 20MiB   | mmc 0:2               | mmcblk1p2         | Primary  |
| rootfs1   | 40MiB          | 500MiB  | mmc 0:3               | mmcblk1p3         | Primary  |
| -         | 540MiB         | -       | mmc 0:4               | mmcblk1p4         | Extended |
| rootfs2   | 540MiB+0.5KiB  | 500MiB  | mmc 0:5               | mmcblk1p5         | Logical  |
| config    | 1040MiB+1KiB   | 40MiB   | mmc 0:6               | mmcblk1p6         | Logical  |
| cache     | 1080MiB+1.5KiB | 500MiB  | mmc 0:7               | mmcblk1p7         | Logical  |


## Notes on firmware update
A flag file in the bootflags partition is used to indicate which root partition
is currently active. If there is a file called "rootfs2" in the bootflags
partition then U-boot will use rootfs2 as the root partition, otherwise it will
use rootfs1.

During a firmware update the non-active root partition is formatted and
populated with the contents of the firmware update payload. The boot flag files
are updated appropriately so that the root partition with the new firmware will
be used on the next boot.

The config partition is not changed during a firmware update, so configuration
on that partition is preserved across updates.

# Future plan

To support firmware updates, mbed Linux systems will have storage for two
separate firmware installations and a mechanism to select which installation to
boot into after reboots. Ideally, each installation would have separate storage
for all code and configuration; in the case of the bootloader, however, this is
not possible since it is the bootloader (with the help of a boot script and
flag files) that will determine which installation should be booted.

To enable each firmware installation to provide its own boot configuration, two
boot scripts will be used during the boot process: the "stage 1" boot script
(stored on the "shared" partition which is shared between both firmware
installations) will read the boot flag files, choose which firmware
installation to use, then run the "stage 2" boot script from the root file
system of the chosen firmware installation.

Platforms may mandate that the bootloader and possibly other platform dependent
files exist at a particular storage location. For that reason, the location of
U-Boot itself is not included in mbed Linux's partition specification.

Each firmware installation itself will be separated into several partitions: a
read only root partition, a configuration partition and a user application
partition. Using a separate partition for the user application will ease the
support of updates of just the user application.

In the case of configuration that should persist across firmware updates, we
will actually store three versions: a configuration for each firmware
installation (stored on the installation's "config" partition) and the initial
configuration installed at build time and/or at the factory (stored on the
"shared" partition). During firmware updates, the configuration for the newly
installed firmware will be created based on the configuration for the currently
running installation, rules contained in a "configuration update" script in
attached to the new firmware and, possibly, the initial factory configuration.

Additionally, there will be a partition for temporary storage of firmware
downloaded during the update process. This partition will be shared between the
firmware installations.

In summary, an mbed Linux system must contain the partitions described in the
following table. It will probably also contain a partition for U-Boot, and may
contain other partitions.

| Label | ro/rw | Description |
|-------|-------|-------------|
| shared  | rw  | Files shared between both root filesystems, including: stage 1 boot script, boot flags, factory configuration, logs |
| rootfs1 | ro  | Root filesystem for installation 1, including: stage 2 boot script, Linux kernel, OPTEE, mbed Linux distribution |
| config1 | rw  | Configuration data for installation 1 |
| user1   | rw  | User application data for installation 1 |
| rootfs2 | ro  | Root filesystem installation 2 (see rootfs1 description) |
| config2 | rw  | Configuration data for installation 2 |
| user2   | rw  | User application data for installation 2 |
| cache   | rw  | Firmware downloads |
