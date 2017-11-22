UBOOT_SHARED_DATA = "${TMPDIR}/work-shared/${MACHINE}/uboot-build-artifacts"
UBOOT_CFG = "u-boot.cfg"
UBOOT_BIN="u-boot.bin"
UBOOT_IMX="u-boot.imx"

# Place and IVT header on a given binary
# Takes:
# $1 = Path to binary being signed as it exists in the root filesystem
# $2 = Input image name
# $3 = Output image name "-signed will be appended to this name"
# $4 = u-boot CONFIG address to find to populate HAB file
#	Config define: Name of u-boot CONFIG item indicatign load address of binary
# $5 = ${UBOOT_SHARED_DATA}/${UBOOT_CFG}
#	Config file: Name of the uboot config file containing defines - typically u-boot.cf
# $6 = ${UBOOT_SHARED_DATA}/${UBOOT_WARP_CFG}
#	U-boot board .cfg.tmp: Required for the mkimage tool to function properly
# $7 = ${WORKDIR}/temp
# Outputs:
#	A file with an IVT/HAB/DCD header prefixed
#	A log of the image genration - required to extract the correct HAB address
image_sign_mbl_generate_ivt () {
	# Extract load address used by u-boot for the given binary
	LOAD_ADDR=`grep "#define $4" $5 | awk '{print $3}' `

	# Validate extracted value
	if [ -z $LOAD_ADDR ]; then
		echo "Unable to parse " $4 " in " $5
		exit 1
	fi

	# Generate the IVT image capture the output in a temp variable
	uboot-mkimage -n $6 -T imximage -e $LOAD_ADDR -d $1/$2 $7/$3 > $7/$3.ivt.log
}

# Replace CRTS_PATH_REPLACE with absolute path prefix
# Inputs
#	$1 = ${WORKDIR}/temp Absolute work path
# 	$2 = CSF file - which needs to be populated with "HAB" entries
# Outputs
#	Replaces CRTS_PATH_REPLACE with path to CRTS data in native staging area
image_sign_mbl_populate_csf_path() {

	# Replace the path to the CRTS data in the CSF file
	SED_STR=` printf "s/CRTS_PATH_REPLACE/./g"`
	sed -i $SED_STR $1/$2
}

# Create a "Blocks" directive in a CSF file
# Takes an input CSF file without a "Blocks" directive and parses
# the logfile produced by a "make u-boot imx" command
# U-boot produces a string like this
#	"HAB Blocks:   877ff400 00000000 0005ec00"
# This function parses that string to produce the CSF required format
#	"Blocks = 0x877ff400 0x00000000 0x0005ec00 "u-boot-ivt.img""
# Inputs
#	$1 = ${WORKDIR}/temp Absolute work path
# 	$2 = CSF file - which needs to be populated with "HAB" entries
#	$3 = Output image name "-signed will be appended to this name"
#	$4 = Path to binary being signed as it exists in the root filesystem
# Outputs
#	Appends a "Blocks" directive to a CSF file in ${BINDIR}
image_sign_mbl_populate_csf_hab () {

	# Translate HAB output from u-boot build to format for CST
	echo -n "Blocks = " > $1/$3.hab.txt

	for word in `grep "HAB Blocks" $1/$3.ivt.log | cut -d':' -f 2`
	do
		printf "0x%s " $word >> $1/$3.hab.txt
	done

	# Cat constructed file to .csf file
	cat $1/$3.hab.txt >> $1/$2

	# Need to append the filesystem/binary path to the HAB string
	echo '"'$3'"' >> $1/$2
}

# Sign a binary image with a CSF header from a binary/CSF pair
# Inputs
#	$1 = ${WORKDIR}/temp
# 	$2 = CSF file - which needs to be populated with "HAB" entries
#	$3 = Output image name "-signed will be appended to this name"
#	$4 = Name of the board (required to resolve CSF path)
#	$5 = Path to binary being signed as it exists in the root filesystem
# Outputs
#	A cryptographically signed file in the format "$2-signed"
image_sign_mbl_gen_csf_sign_binary (){

	# Copy CSF and public keys etc to temporary directory under ${WORKDIR}/temp
	cp ${WORKDIR}/recipe-sysroot-native/etc/cst/$4/csf/$2 $1

	# Copy pem, der and SRK has data to temporary directory under ${WORKDIR}/temp
	cp ${WORKDIR}/recipe-sysroot-native/etc/cst/$4/keys/* $1
	cp ${WORKDIR}/recipe-sysroot-native/etc/cst/$4/crts/* $1

	# Populate various paths in CSF file
	image_sign_mbl_populate_csf_path $1 $2

	# Populate with HAB addresses prior to passing to CST
	image_sign_mbl_populate_csf_hab $1 $2 $3 $5

	# Change to the working directory
	# The CST has a hard time dealing with long absolute paths
	# so we change to the working directory and give it local paths in the CSF file only
	cd $1

	# Sign image
	# --o indicates the output file name - the binary CSF header
	# --i indicates the input CSF descriptor
	# the .csf file contains the name of the image to sign
	#./${CSTTOOL} --i $1/$2 --o $1/$2-csf-header
	${WORKDIR}/recipe-sysroot-native/usr/bin/cst --i $1/$2 --o $1/$2-csf-header
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "CST signing failed ->" cst --i $1/$2 --o $1/$2-csf-header
		exit $ret
	fi

	# Concatonate header with IVT prefixed binary - generating bootrom parsable binary
	#cd $execdir
	cat $1/$3 $1/$2-csf-header > $1/$3-signed
}

# Do the complete MBL/imx7 image signing circus
# $1 = Path to binary being signed as it exists in the root filesystem
# $2 = Name of the board (required to resolve CSF path)
# $3 = Input image name
# $4 = Output image name "-signed will be appended to this name"
# $5 = u-boot CONFIG address to find to populate HAB file
# $6 = CSF file - which needs to be populated with "HAB" entries
# $7 = name of u-boot board config
image_sign_mbl_binary (){

	# Now sign the indicated binary
	image_sign_mbl_generate_ivt $1 $3 $4 $5 ${UBOOT_SHARED_DATA}/${UBOOT_CFG} ${UBOOT_SHARED_DATA}/$7 ${WORKDIR}/temp
	image_sign_mbl_gen_csf_sign_binary ${WORKDIR}/temp $6 $4 $2 $1

	# Copy signed image back to filesystem staging area
	cp ${WORKDIR}/temp/$4-signed $1
}
