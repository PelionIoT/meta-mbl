#!/bin/bash
# SPDX-License-Identifier:      GPL-2.0
#
# Update a disk image with unsigned images

script_name=$0
mapper=/dev/mapper
optee_dir=lib/firmware/

deps=(
    kpartx
    mktemp
    mount
    umount
    dd
)

default_boot_part_num=1
default_rootfs1_part_num=3
default_rootfs2_part_num=5
default_staging_dir="temp"
default_disk_image="mbl-console-image-imx7s-warp-mbl.wic.gz"
default_unsigned_uboot="u-boot.bin"
default_uboot_cfg="u-boot.cfg"
default_imx_cfg="imximage.cfg.cfgtmp"
default_unsigned_bootscr="boot.scr"
default_unsigned_kernel="zImage"
default_unsigned_dtb="imx7s-warp.dtb"
default_unsigned_optee="uTee.optee"

boot_part_num=$default_boot_part_num
rootfs1_part_num=$default_rootfs1_part_num
rootfs2_part_num=$default_rootfs2_part_num
disk_image=$default_disk_image
unsigned_uboot=$default_unsigned_uboot
uboot_cfg=$default_uboot_cfg
imx_cfg=$default_imx_cfg
unsigned_bootscr=$default_unsigned_bootscr
unsigned_kernel=$default_unsigned_kernel
unsigned_dtb=$default_unsigned_dtb
unsigned_optee=$default_unsigned_optee
staging_dir=$default_staging_dir

# usage
# Give list of input parameters and their meaning
usage()
{
    echo "usage: $script_name"
    echo "    -i <disk image file>"
    echo "       A raw disk image to extract the files from"
    echo "       default: $default_disk_image"
    echo "    -u <unsigned u-boot file>"
    echo "       default: $default_unsigned_uboot"
    echo "    -b <unsigned boot script file>"
    echo "       default: $default_unsigned_bootscr"
    echo "    -k <unsigned kernel file>"
    echo "       default: $default_unsigned_kernel"
    echo "    -d <unsigned dtb file>"
    echo "       default: $default_unsigned_dtb"
    echo "    -o <unsigned optee file>"
    echo "       default: $default_unsigned_optee"
    echo "    -c <boot.cfg>"
    echo "       default: $default_uboot_cfg"
    echo "    -m <imximage.cfg.cfgtmp>"
    echo "       default: $imx_cfg"
    echo "    -p <boot partition number>"
    echo "       Disk partition where the kernel/dtb/u-boot.bin/u-boot.cfg and imximage.cfg.cfgtmp live"
    echo "       default: $default_boot_part_num"
    echo "    -r1 <rootfs1 partition number>"
    echo "       Disk partition where the first rootfs is and OP-TEE lives"
    echo "       default: $default_rootfs1_part_num"
    echo "    -r2 <rootfs2 partition number>"
    echo "       Disk partition where the first rootfs is and OP-TEE lives"
    echo "       default: $default_rootfs2_part_num"
    echo "    -s <staging directory>"
    echo "       Directory to copy unsigned files into"
    echo "       default: $default_staging_dir"
    echo "    -v"
    echo "       extra output is shown"
    echo "       default: off"
    echo ""
    echo "This script must be run as root."
}

# verbose_echo
# Do an optional printout if-and-only-if verbose is true
verbose_echo()
{
    if [ "$verbose" == "1" ]; then
        echo "$*"
    fi
}

# Read params
while [ "$1" != "" ]; do
    case $1 in
        "-h" | "-?" | "-help" | "--help" | "--h" | "help" )
            usage
            exit
            ;;
        "-i" )
            shift
            disk_image=$1
            ;;
        "-u" )
            shift
            unsigned_uboot=$1
            ;;
        "-b" )
            shift
            unsigned_bootscr=$1
            ;;
        "-k" )
            shift
            unsigned_kernel=$1
            ;;
        "-d" )
            shift
            unsigned_dtb=$1
            ;;
        "-o" )
            shift
            unsigned_optee=$1
            ;;
        "-c" )
            shift
            uboot_cfg=$1
            ;;
        "-m" )
            shift
            imx_cfg=$1
            ;;
        "-p" )
            shift
            boot_part_num=$1
            ;;
        "-r1" )
            shift
            rootfs1_part_num=$1
            ;;
        "-r2" )
            shift
            rootfs2_part_num=$1
            ;;
        "-s" )
            shift
            staging_dir=$1
            ;;
        "-v" )
            verbose=1
            ;;
        *)
            ;;
    esac
    shift
done

verbose_echo "boot_part_num=$boot_part_num"
verbose_echo "rootfs1_part_num=$rootfs1_part_num"
verbose_echo "rootfs2_part_num=$rootfs2_part_num"
verbose_echo "disk_image=$disk_image"
verbose_echo "unsigned_uboot=$unsigned_uboot"
verbose_echo "unsigned_bootscr=$unsigned_bootscr"
verbose_echo "unsigned_kernel=$unsigned_kernel"
verbose_echo "unsigned_dtb=$unsigned_dtb"
verbose_echo "unsigned_optee=$unsigned_optee"
verbose_echo "uboot_cfg=$uboot_cfg"
verbose_echo "imx_cfg=$imx_cfg"
verbose_echo "staging_dir=$staging_dir"

# Verify root
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: this script must be run as root"
    exit 1
fi

# Verify destination
if [ ! -d "$staging_dir" ]; then
    echo "Please run 'make dirs' before running this script"
    exit 1
fi

for cmd in "${deps[@]}"; do
    command -v "${cmd}" > /dev/null 2>&1
    cmd_installed=$?
    if [[ $cmd_installed -ne 0 ]]; then
        echo "ERROR: $cmd must be installed"
        exit 1
    fi
done

# unzip disk image
filetype=$(file -L "$disk_image")
tmp_img=$(mktemp)
case $filetype in
    *"gzip compressed"* )
        verbose_echo "gunzip $disk_image to $tmp_img"
        gunzip -c "$disk_image" > "$tmp_img"
        ;;
    *"XZ compressed"* )
        verbose_echo "xz --decompress $disk_image to $tmp_img"
        xzcat "$disk_image" > "$tmp_img"
        ;;
    * )
        verbose_echo "copy $disk_image to $tmp_img"
        cp "$disk_image" "$tmp_img"
        ;;
esac

# map the disk image using kpartx, saving the output for parsing
kpout="$(kpartx -vas "$tmp_img")"
mapped=$?

if [ "$mapped" == "0" ]; then
    # work out where kpartx mapped the disk image
    tmp=$(head -1 <<<"$kpout" | awk '{print $3}')
    read loop_device loop_num <<<${tmp//[^0-9]/ }

    verbose_echo "loop_num: $loop_num"
    verbose_echo "loop_device: $loop_device"

    # Copy files from the boot partition
    boot_part=${mapper}/loop${loop_device}p${boot_part_num}
    if [ -e "${boot_part}" ]; then

        tmp_mnt=$(mktemp -d)
        mount "${boot_part}" "$tmp_mnt"
        echo "mount ${boot_part} $tmp_mnt"

        # Verify files exist
        prereq_files=(
            $tmp_mnt/$unsigned_bootscr
            $tmp_mnt/$unsigned_kernel
            $tmp_mnt/$unsigned_dtb
            $tmp_mnt/$unsigned_uboot
            $tmp_mnt/$uboot_cfg
            $tmp_mnt/$imx_cfg
        )

        for file in "${prereq_files[@]}";
        do
            if [ ! -e "$file" ]; then
                echo "ERROR: $file does not exist"
            fi
        done

        # Copy files
        cp "$tmp_mnt/$unsigned_bootscr" "$staging_dir"
        cp "$tmp_mnt/$unsigned_kernel" "$staging_dir"
        cp "$tmp_mnt/$unsigned_dtb" "$staging_dir"
        cp "$tmp_mnt/$unsigned_uboot" "$staging_dir"
        cp "$tmp_mnt/$uboot_cfg" "$staging_dir"
        cp "$tmp_mnt/$imx_cfg" "$staging_dir"

        if [ "$verbose" == "1" ]; then
            ls -alF "$tmp_mnt"/
        fi

        umount "$tmp_mnt"
        rmdir "$tmp_mnt"
    else
        echo "ERROR: $boot_part does not exist"
    fi

    # Copy files from the rootfs partitions
    for rootfs_part_num in $rootfs1_part_num $rootfs2_part_num;
    do
        rootfs_part=${mapper}/loop${loop_device}p${rootfs_part_num}
        if [ -e "${rootfs_part}" ]; then

            tmp_mnt=$(mktemp -d)
            mount "${rootfs_part}" "$tmp_mnt"

            mkdir -p "$staging_dir"/rootfs"${rootfs_part_num}"
            chmod --reference="$staging_dir" "$staging_dir"/rootfs"${rootfs_part_num}"
            chown --reference="$staging_dir" "$staging_dir"/rootfs"${rootfs_part_num}"
            cp "${tmp_mnt}"/"${optee_dir}"/"${unsigned_optee}" "$staging_dir"/rootfs"${rootfs_part_num}"

            if [ "$verbose" == "1" ]; then
                ls -alF "$staging_dir"
            fi

            umount "$tmp_mnt"
            rmdir "$tmp_mnt"
        else
            echo "ERROR: $rootfs_part does not exist"
        fi
    done

    # We've finished manipulating the disk image, so unmap it
    kpartx -d "$tmp_img" > /dev/null 2>&1
else
    echo "ERROR: kpartx was unable to map disk image"
fi
rm "$tmp_img"
