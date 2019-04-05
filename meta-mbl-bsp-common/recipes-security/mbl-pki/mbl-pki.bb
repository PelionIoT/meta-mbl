##############################################################################
# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT
#
#
# mbl-pki.bb
#
# This recipe manages the keying material for signing MBL components.
# Currently, this specifically relates to the use of the FIT image
# signing key.
#
##############################################################################
SUMMARY = "Manage PKI keying material for signing secure boot arttefacts"
HOMEPAGE = "https://github.com/ARMmbed/meta-mbl"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
DEPENDS = " openssl-native"

inherit deploy
inherit mbl-artifact-names


##############################################################################
# FUNCTION: do_compile()
# This function does the following:
# - if present, uses a pre-existing FIT image signing key.
#     - If specified for the build by the developer, this will be present
#       in MBL_KEYSTORE_DIR and called ${MBL_FIT_ROT_KEY_FILENAME}.
#     - If previously generate by the build, the key
#       ${MBL_FIT_ROT_KEY_FILENAME} will be present in ${DEPLOY_DIR_IMAGE}
# - Otherwise, generate a new key.
# - Generate an associated key certificate ${MBL_FIT_ROT_KEY_FILENAME}.crt.
##############################################################################
do_compile() {

    # Manage the FIT image signing key
    if [ ! -e "${MBL_KEYSTORE_DIR}/${MBL_FIT_ROT_KEY_FILENAME}" ]; then
        # Key has not been provided by developer in key store directory.
        if [ ! -e "${DEPLOY_DIR_IMAGE}/${MBL_FIT_ROT_KEY_FILENAME}" ]; then
            # Key has not previously been generated.
            # Generate the key.
            openssl genrsa -out ${B}/${MBL_FIT_ROT_KEY_FILENAME} 2048
        else
            # Key has been previously generated.
            # Copy it to the build directory for use.
            cp ${DEPLOY_DIR_IMAGE}/${MBL_FIT_ROT_KEY_FILENAME} ${B}
        fi
    else
        # Key exists in key store but not in DEPLOY_DIR_IMAGE directory.
        # Copy it to the build directory for use.
        cp ${MBL_KEYSTORE_DIR}/${MBL_FIT_ROT_KEY_FILENAME} ${B}
    fi

    # Manage the FIT image key certificate
    if [ ! -e "${MBL_KEYSTORE_DIR}/${MBL_FIT_ROT_KEY_CERT_FILENAME}" ]; then
        # Certificate has not been provided by developer in key store directory.
        if [  ! -e "${DEPLOY_DIR_IMAGE}/${MBL_FIT_ROT_KEY_CERT_FILENAME}" ]; then
            # Certificate has not previously been generated.
            # Generate the certificate.
            openssl req -batch -new -x509 -key ${B}/${MBL_FIT_ROT_KEY_FILENAME} -out ${B}/${MBL_FIT_ROT_KEY_CERT_FILENAME}
        else
            # Certificate has been previously generated.
            # Copy it to the build directory for use.
            cp ${DEPLOY_DIR_IMAGE}/${MBL_FIT_ROT_KEY_CERT_FILENAME} ${B}
        fi
    else
        # Certificate exists in key store but not in DEPLOY_DIR_IMAGE directory.
        # Copy it to the build directory for use.
        cp ${MBL_KEYSTORE_DIR}/${MBL_FIT_ROT_KEY_CERT_FILENAME} ${B}
    fi

}


##############################################################################
# FUNCTION: do_deploy()
# The keys are deployed to the DEPLOYDIR using do_deploy(), taking
# advantage of the standard mechanism of sharing the output one recipe
# so it can be the input to other recipes.
##############################################################################
do_deploy() {
    install -m 0644 ${B}/${MBL_FIT_ROT_KEY_FILENAME} ${DEPLOYDIR}
    install -m 0644 ${B}/${MBL_FIT_ROT_KEY_CERT_FILENAME} ${DEPLOYDIR}
}

addtask do_deploy after do_compile before do_build

# Inheriting from noinstall.bbclass appears at the end of the recipe so that
# noinstall behaviour that is overriden will be clear (i.e. will appear after
# this directive).
inherit noinstall
