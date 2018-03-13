#!/bin/bash
# SPDX-License-Identifier:      GPL-2.0

# Takes:
# $1 = Input image name
# $2 = Output image name "-signed will be appended to this name"
# $3 = u-boot CONFIG address to find to populate HAB file
#   Config define: Name of u-boot CONFIG item indicatign load address of binary
# $4 = {UBOOT_CFG}
#   Config file: Name of the uboot config file containing defines - typically u-boot.cfg
# $5 = ${UBOOT_WARP_CFG}
#   U-boot board .cfg.tmp: Required for the mkimage tool to function properly
# $6 = ${WORKDIR}/temp
# $7 = u-boot mkimage binary
# Outputs:
#   A file with an IVT/HAB/DCD header prefixed
#   A log of the image genration - required to extract the correct HAB address
image_sign_mbl_generate_ivt () {

    # Assign variable names
    local input_image=$1
    local output_image=$2
    local uboot_config_addr=$3
    local uboot_cfg=$4
    local uboot_cfg_tmp=$5
    local temp=$6
    local mkimage_bin=$7

    # Extract load address used by u-boot for the given binary
    local LOAD_ADDR
    LOAD_ADDR=$(grep "#define $uboot_config_addr" "$temp/$uboot_cfg" | awk '{print $3}')

    # Validate extracted value
    if [ -z "$LOAD_ADDR" ]; then
        echo "Unable to parse $uboot_config_addr in $temp/$uboot_cfg"
        exit 1
    fi
    # Generate the IVT image capture the output in a temp variable
    "$mkimage_bin" -n "$temp/$uboot_cfg_tmp" -T imximage -e "$LOAD_ADDR" -d "$temp/$input_image" "$temp/$output_image" > "$temp/$output_image.log"
}

# Replace an image name placeholder with a passed image name
# $1 = Path to file to manipulate
# $2 = String to replace
# $3 = Text to replace string with
image_sign_mbl_replace_name () {

    # Assign variable names
    local file_path=$1
    local replace_string=$2
    local replace_text=$3

    # Replace image name place holder with passed parameter
    sed -i "s|$replace_string|$replace_text|g" "$file_path"
    grep "$replace_text" "$file_path"
}

# Create a "Blocks" directive in a CSF file
# Takes an input CSF file without a "Blocks" directive and parses
# the logfile produced by a "make u-boot imx" command
# U-boot produces a string like this
#   "HAB Blocks:   877ff400 00000000 0005ec00"
# This function parses that string to produce the CSF required format
#   "Blocks = 0x877ff400 0x00000000 0x0005ec00 "u-boot-ivt.img""
# Inputs
#   $1 = ${WORKDIR}/temp Absolute work path
#   $2 = CSF file - which needs to be populated with "HAB" entries
#   $3 = Output image name "-signed will be appended to this name"
# Outputs
#   Populates a csf-header "Blocks" directive to a CSF file specified in $2
image_sign_mbl_populate_csf_hab () {
    # Assign variable names
    local temp=$1
    local csf=$2
    local output_image=$3

    # Translate HAB output from u-boot build to format for CST
    local tmp
    local words
    local str
    tmp=$(grep "HAB Blocks" < "$temp"/"$output_image".log)
    words=$(echo "$tmp" | cut -d':' -f 2)
    str=""

    rm -f "$temp"/"$output_image".hab.txt
    for word in $words
    do
        printf "0x%s\ " "$word" >> "$temp/$output_image.hab.txt"
    done

    # read in string
    str=$(cat < "$temp"/"$output_image".hab.txt)

    # Replace HAB_BLOCKS_REPLACE with formatted 0xValue 0xValue 0xValue triad
    sed -i "s/HAB_BLOCKS_REPLACE/$str/g" "$temp"/"$csf"
    local gs
    gs=$(echo "$str" | tr -d '\\')
    grep "$gs" "$temp"/"$csf"

    # Finally replace name placeholder with indicated image name
    if [ $? -eq 0 ]; then
        image_sign_mbl_replace_name "$temp"/"$csf" "IMAGE_IMX_HAB_NAME_REPLACE" "$output_image"
    fi
}

# Create a "DCD" directive in a CSF file
# Takes an input CSF file without a "DCD" directive and parses
# the logfile produced by a "make u-boot imx" command
# U-boot produces a string like this
#
# DCD Blocks:   00910000 0000002c 000001d4
# This function parses that string to produce the CSF required format
#   "Blocks =  0x00910000 0x0000002c 0x000001d4 "u-boot-recovery.imx""
# Inputs
#   $1 = ${WORKDIR}/temp Absolute work path
#   $2 = CSF file - which needs to be populated with "HAB" entries
#   $3 = Output image name "-signed will be appended to this name"
# Outputs
#   Populates a DCD specific "Blocks" directive to a CSF file specified in $2
image_sign_mbl_populate_csf_dcd () {
    # Assign variable names
    local temp=$1
    local csf=$2
    local output_image=$3

    # Translate HAB output from u-boot build to format for CST
    local tmp
    local words
    local str
    tmp=$(grep "DCD Blocks" < "$temp"/"$output_image".log)
    words=$(echo "$tmp" | cut -d':' -f 2)
    str=""

    rm -f "$temp"/"$output_image".hab.txt
    for word in $words
    do
        printf "0x%s\ " "$word" >> "$temp/$output_image.hab.txt"
    done

    # read in string
    local str
    str=$(cat < "$temp"/"$output_image".hab.txt)

    # Replace DCD_BLOCKS_REPLACE with formatted 0xValue 0xValue 0xValue triad
    sed -i "s/DCD_BLOCKS_REPLACE/$str/g" "$temp"/"$csf"
    local gs
    gs=$(echo "$str" | tr -d '\\')
    grep "$gs" "$temp"/"$csf"

    # Finally replace name placeholder with indicated image name
    if [ $? -eq 0 ]; then
        image_sign_mbl_replace_name "$temp"/"$csf" "IMAGE_IMX_DCD_NAME_REPLACE" "$output_image"
    fi

    # Gives a 0 if DCD triad in place - else returns non-zero indicating fail
    grep "$gs" "$temp"/"$csf"
}

# Zeroizes the DCD - required to make a recovery image
#
# Inputs
#   $1 = ${WORKDIR}/temp Absolute work path
#   $2 = Output image name "-signed will be appended to this name"
# Outputs
#   An original image with the DCD field set to zero
#   A temporary copy of the DCD data to be dd'd back at a later phase
image_sign_mbl_clear_dcd () {

    # Assign variable names
    local temp=$1
    local output_image=$2

    # store the DCD address
    dd if="$temp"/"$output_image" of="$temp"/"$output_image".dcd_addr.bin bs=1 count=4 skip=12

    # generate a NULL address for the DCD
    dd if=/dev/zero of="$temp"/"$output_image".zero.bin bs=1 count=4

    # replace the DCD address with the NULL address
    dd if="$temp"/"$output_image".zero.bin of="$temp"/"$output_image" seek=12 bs=1 conv=notrunc

    rm "$temp"/"$output_image".zero.bin
}

# Restore the previous DCD address
#
# Inputs
#   $1 = ${WORKDIR}/temp Absolute work path
#   $2 = Output image name "-signed will be appended to this name"
# Outputs
#   A file with the DCD field restored from the saved value
image_sign_mbl_restore_dcd() {
    # Assign variable names
    local temp=$1
    local output_image=$2

    # restore the DCD address with the original address
    dd if="$temp"/"$output_image".dcd_addr.bin of="$temp"/"$output_image" seek=12 bs=1 conv=notrunc

    rm "$temp"/"$output_image".dcd_addr.bin
}

# Sign a binary image with a CSF header from a binary/CSF pair
# Inputs
#   $1 = ${WORKDIR}/temp
#   $2 = CSF file - which needs to be populated with "HAB" entries
#   $3 = Output image name "-signed will be appended to this name"
#   $4 = Name of the board (required to resolve CSF path)
# Outputs
#   A cryptographically signed file in the format "$2-signed"
image_sign_mbl_binary () {
    # Assign variable names
    local temp=$1
    local csf=$2
    local output_image=$3
    local cst_bin=$4

    #flag to indicate if DCD processing is required
    local skip_dcd=1

    # Populate with HAB addresses prior to passing to CST
    image_sign_mbl_populate_csf_hab "$temp" "$csf" "$output_image"
    if [ $? -ne 0 ]; then
        echo "Unable to populate HAB Block"
        exit 1
    fi

    # Populate with DCD addresses prior to passing to CST
    image_sign_mbl_populate_csf_dcd "$temp" "$csf" "$output_image"
    skip_dcd=$?

    # Change to the working directory
    # The CST has a hard time dealing with long absolute paths
    # so we change to the working directory and give it local paths in the CSF file only
    cd "$temp"

    # Clear the DCD if DCD block present
    if [ $skip_dcd -eq 0 ]; then
        image_sign_mbl_clear_dcd "$temp" "$output_image"
    fi

    # Sign image
    # --o indicates the output file name - the binary CSF header
    # --i indicates the input CSF descriptor
    # the .csf file contains the name of the image to sign
    #./${CSTTOOL} --i $1/$2 --o $1/$2-csf-header
    "$cst_bin" --i "$csf" --o "$csf"-csf-header
    local ret=$?
    if [ $ret -ne 0 ]; then
        echo "CST signing failed ->" cst --i "$temp"/"$csf" --o "$temp"/"$csf"-csf-header
        exit $ret
    fi

    # Restore the DCD if DCD block present
    if [ $skip_dcd -eq 0 ]; then
       image_sign_mbl_restore_dcd "$temp" "$output_image"
    fi

    # Concatonate header with IVT prefixed binary - generating bootrom parsable binary
    cat "$output_image" "$csf"-csf-header > "$output_image"-signed
}

# Execute specified function
"$@"
