# Define which key to use when signing the ARM Trusted Applications (TA)
# If no key is defined the default OP-TEE key will be used.
#
# This file lets you use one of the keys used to sign images authenitcated via
# the BootROM HAB to also sign OP-TEE TAs.
#
# Note any .pem file can be used but the OP-TEE recipes have been engineered to
# look for .pem files on the same path as the CST keys
#
# This file assumes the private key is encrypted and that it can be decrypted by
# a key_pass.txt file provided on the command line
#
# If you have a decrypted private key just set WARP7_KEY_NAME_DECRYPTED on its
# own without setting WARP7_KEY_NAME_ENCRYPTED or WARP7_KEY_PASS_FILE

WARP7_KEY_NAME_ENCRYPTED="${WORKDIR}/recipe-sysroot-native/etc/cst/warp7/keys/IMG1_1_sha256_2048_65537_v3_usr_key.pem"
WARP7_KEY_NAME_DECRYPTED="${WORKDIR}/recipe-sysroot-native/etc/cst/warp7/keys/IMG1_1_sha256_2048_65537_v3_usr_key-decrypted.pem"
WARP7_KEY_PASS_FILE="${WORKDIR}/recipe-sysroot-native/etc/cst/warp7/keys/key_pass.txt"

warp7_decrypt_private_key() {
	# decrypt the file if it exists to the specified decrypted file name
	if [ -n ${WARP7_KEY_NAME_ENCRYPTED} ]; then
		${WORKDIR}/recipe-sysroot-native/usr/bin/openssl rsa -in ${WARP7_KEY_NAME_ENCRYPTED} -out ${WARP7_KEY_NAME_DECRYPTED} -passin file:${WARP7_KEY_PASS_FILE}
	fi
}
