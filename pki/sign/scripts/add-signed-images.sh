#!/bin/bash
# SPDX-License-Identifier:      GPL-2.0
#
# Update a disk image with signed images

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
default_disk_image="mbl-console-image-imx7s-warp-mbl.wic.gz"
default_signed_uboot="u-boot.imx-signed"
default_signed_bootscr="boot.scr.imx-signed"
default_signed_kernel="zImage.imx-signed"
default_signed_dtb="imx7s-warp.dtb.imx-signed"
default_signed_optee="uTee.optee.imx-signed"
default_srk_fuse="SRK_1_2_3_4_2048_fuse.bin"
default_signed_binaries_dir="signed-binaries"

boot_part_num=$default_boot_part_num
rootfs1_part_num=$default_rootfs1_part_num
rootfs2_part_num=$default_rootfs2_part_num
disk_image=$default_disk_image
signed_uboot=$default_signed_uboot
signed_bootscr=$default_signed_bootscr
signed_kernel=$default_signed_kernel
signed_dtb=$default_signed_dtb
signed_optee=$default_signed_optee
srk_fuse=$default_srk_fuse
signed_binaries_dir=$default_signed_binaries_dir

# usage
# Give list of input parameters and their meaning
usage()
{
    echo "usage: $script_name"
    echo "    -i <disk image file>"
    echo "       A raw disk image to add the files into"
    echo "       default: $default_disk_image"
    echo "    -u <signed u-boot file>"
    echo "       default: $default_signed_uboot"
    echo "    -b <signed boot script file>"
    echo "       default: $default_signed_bootscr"
    echo "    -k <signed kernel file>"
    echo "       default: $default_signed_kernel"
    echo "    -d <signed dtb file>"
    echo "       default: $default_signed_dtb"
    echo "    -o <signed optee file>"
    echo "       default: $default_signed_optee"
    echo "    -f <signed SRK fuse file>"
    echo "       default: $default_srk_fuse"
    echo "    -p <boot partition number>"
    echo "       Disk partition where the kernel/dtb lives"
    echo "       default: $default_boot_part_num"
    echo "    -r1 <rootfs1 partition number>"
    echo "       Disk partition where the first rootfs is and OP-TEE lives"
    echo "       default: $default_rootfs1_part_num"
    echo "    -r2 <rootfs2 partition number>"
    echo "       Disk partition where the first rootfs is and OP-TEE lives"
    echo "       default: $default_rootfs2_part_num"
    echo "    -s <signed binaries directory>"
    echo "       Directory to copy unsigned files into"
    echo "       default: $default_signed_binaries_dir"
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
            signed_uboot=$1
            ;;
        "-b" )
            shift
            signed_bootscr=$1
            ;;
        "-k" )
            shift
            signed_kernel=$1
            ;;
        "-d" )
            shift
            signed_dtb=$1
            ;;
        "-o" )
            shift
            signed_optee=$1
            ;;
        "-f" )
            shift
            srk_fuse=$1
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
            signed_binaries_dir=$1
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
verbose_echo "signed_uboot=$signed_uboot"
verbose_echo "signed_bootscr=$signed_bootscr"
verbose_echo "signed_kernel=$signed_kernel"
verbose_echo "signed_dtb=$signed_dtb"
verbose_echo "signed_optee=$signed_optee"
verbose_echo "srk_fuse=$srk_fuse"
verbose_echo "signed_binaries_dir=$signed_binaries_dir"

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: this script must be run as root"
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

# verify the files exist
prereq_files=(
    $disk_image
    $signed_binaries_dir/$signed_uboot
    $signed_binaries_dir/$signed_bootscr
    $signed_binaries_dir/$signed_kernel
    $signed_binaries_dir/$signed_dtb
    $signed_binaries_dir/$srk_fuse
    $signed_binaries_dir/rootfs$rootfs1_part_num/$signed_optee
    $signed_binaries_dir/rootfs$rootfs2_part_num/$signed_optee
)

for file in "${prereq_files[@]}";
do
    if [ ! -e "$file" ]; then
        echo "ERROR: $file does not exist"
        exit
    fi
done

# boot strip files
strip_files=(
    "u-boot.bin"
    "u-boot.cfg"
    "imximage.cfg.cfgtmp"
)

# unzip disk image
filetype=$(file -L "$disk_image")
tmp_img=$(mktemp)
zip_prog=""
case $filetype in
    *"gzip compressed"* )
        verbose_echo "gunzip $disk_image to $tmp_img"
        gunzip -c "$disk_image" > "$tmp_img"
        zip_prog="gzip"
        zip_ext="gz"
        ;;
    *"XZ compressed"* )
        verbose_echo "xz --decompress $disk_image to $tmp_img"
        xzcat "$disk_image" > "$tmp_img"
        zip_prog="xz"
        zip_ext="xz"
        ;;
    * )
        verbose_echo "copy $disk_image to $tmp_img"
        cp "$disk_image" "$tmp_img"
        ;;
esac

# dd the signed u-boot image into the disk image
dd if="$signed_binaries_dir"/"$signed_uboot" of="$tmp_img" bs=512 seek=2 conv=notrunc > /dev/null 2>&1

# map the disk image using kpartx, saving the output for parsing
kpout="$(kpartx -vas "$tmp_img")"
mapped=$?

if [ "$mapped" == "0" ]; then
    # work out where kpartx mapped the disk image
    tmp=$(head -1 <<<"$kpout" | awk '{print $3}')
    read loop_device loop_num <<<${tmp//[^0-9]/ }

    verbose_echo "loop_num: $loop_num"
    verbose_echo "loop_device: $loop_device"

    # Copy files into the boot partition
    boot_part=${mapper}/loop${loop_device}p${boot_part_num}
    if [ -e "${boot_part}" ]; then

        tmp_mnt=$(mktemp -d)
        mount "${boot_part}" "$tmp_mnt"

        # Copy signed binaries into output
        cp "$signed_binaries_dir"/"$signed_bootscr" "$tmp_mnt"
        cp "$signed_binaries_dir"/"$signed_kernel" "$tmp_mnt"
        cp "$signed_binaries_dir"/"$signed_dtb" "$tmp_mnt"

        # Copy SRK fuse file
        cp "$signed_binaries_dir"/"$srk_fuse" "$tmp_mnt"

        if [ "$verbose" == "1" ]; then
            ls -alF "$tmp_mnt"/
            df -h "$tmp_mnt"
        fi

        # Remove signing meta-data from input
        for file in "${strip_files[@]}";
        do
            rm "$tmp_mnt"/"$file"
        done

        if [ "$verbose" == "1" ]; then
            ls -alF "$tmp_mnt"/
            df -h "$tmp_mnt"
        fi

        umount "$tmp_mnt"
        rmdir "$tmp_mnt"
    else
        echo "ERROR: $boot_part does not exist"
    fi

    # Copy files into the rootfs partitions
    for rootfs_part_num in $rootfs1_part_num $rootfs2_part_num;
    do
        rootfs_part=${mapper}/loop${loop_device}p${rootfs_part_num}
        if [ -e "${rootfs_part}" ]; then

            tmp_mnt=$(mktemp -d)
            mount "${rootfs_part}" "$tmp_mnt"

            cp "$signed_binaries_dir"/rootfs"$rootfs_part_num"/"$signed_optee" "${tmp_mnt}"/"${optee_dir}"

            if [ "$verbose" == "1" ]; then
                ls -alF "$tmp_mnt"/
                ls -alF "$tmp_mnt"/"${optee_dir}"
                df -h "$tmp_mnt"
            fi

            umount "$tmp_mnt"
            rmdir "$tmp_mnt"
        else
            echo "ERROR: $rootfs_part does not exist"
        fi
    done

    # We've finished manipulating the disk image, so unmap it
    kpartx -d "$tmp_img" > /dev/null 2>&1

    # If we started with a compressed image, recompress our new image
    if [ "${zip_prog}" != "" ]; then
        verbose_echo "Compressing new disk image"
        "${zip_prog}" "$tmp_img"
        tmp_img="${tmp_img}.${zip_ext}"
    fi

    # Write a new disk image with "signed-" prepended
    verbose_echo "Copying to new signed disk image"
    cp "$tmp_img" signed-"$disk_image"
    chmod --reference="$disk_image" signed-"$disk_image"
    chown --reference="$disk_image" signed-"$disk_image"
else
    echo "ERROR: kpartx was unable to map disk image"
fi
rm "$tmp_img"
