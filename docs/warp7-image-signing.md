# Warp 7: How to Sign Images

# Introduction

The purpose of this document is to describe how is to signed the mbl-console-image for Warp7 images.
Outstanding Issues with this Document 

The outstanding issues are documented in the sections with titles beginning "Outstanding Questions" throughout this document.

Some sections are incomplete as indicated by the "todo" comments.
Terminology

This section outlines the terminology used throughout the document:

    BSP: Board Support Package
    CA: Certificate Authority
    CSF: Command Sequence File
    CST: Code-Signing Tool
    DCD: Device Configuration Data
    DEK: Data Encryption Key
    DER: File extension for binary DER encoded certificates
    HAB: High Assurance Boot
    IVT: Image Vector Table
    NC: No Comment.
    OTP: One-Time Programmable
    PEM: File extension for X509 base64 encoded certificates
    SiP: Silicon Partner
    SRK: Super Root Key. These are the keys that will be used how ? TODO: answer this questions.
    TSP: Target (Family) Support Package e.g. the feature support common to the IMx7 family.
    TPM: Trusted Platform Module


# Warp7: How To Configure a Board To Boot a Signed Image

## Overview 

This section describes how to perform a secure boot using a signed image on warp7.
Overview of Steps

The following summarizes the steps for booting a signed image.

    Step 1: Prerequisites.
    Step 2: Generate PKI Tree using hab4_pki_tree.sh
    Step 3: Generate xxx_fuse.bin and xxx_table.bin using srktool.
    Step 4: Program OTP fuses with SRK hashes using fuse_util.py.
    Step 5: Build unsigned image mbl-console-image-test.
    Step 6. Manually sign image with xxx script.
    Step 7: Flash and boot signed image.
    Step 8: OPTIONAL: Close and lock device.

The following section describe in detail each of the steps.

## Warp7 : Step 1: Prerequisites

### Acquire the NXP CST

In order to run the commands, the NXP CST must be acquired by NXP approving an OEM Developer request.

The top level of the workspace is called TOP_DIR. Once the cst-2.3.2.tar.gz CST tarball has been 
received, store it in the following location of your workspace:

    TOP_DIR/layers/meta-mbl/pki/nxp/boards
    
### Install Required Packages for Signing

These are the pre-requisite Ubuntu 16.04 packages that need to be installed for the signing scripts to work:

    make
    bash
    kpartx
    mktemp
    awk
    grep


## Warp7 : Step 2: Generate PKI Tree using hab4_pki_tree.sh

This section describes the creation of the keying material. The keying material is composed of the following:

- A top level private key called the CA private key. This is used to sign certificates in the next layer down from the CA root in the PKI key hierarchy (tree).
- Super Root Keys. These are used to sign images. The private keys are stored in key files, the public keys are stored in certificates signed by the private key. A hash of 1-4 SRK public keys are stored in the OTP fuses. The certificates are embedded in signed images so the secure boot process can recover the public key, check the signature on the certificate, hash the key and check it agrees with the hash in the relevant OTP fuse.
- CSF keys and certificates. These are used to sign CSF files.
- IMG keys and certificates. These are used to sign product binary files.

Here is some useful orientation information:

    When generating the keying material, the development machine used to generate the keys and certificates is acting as a Certificate Authority.
    The process described here is for a developer generating keying material so that he/she may build signed images and perform development tasks. They keys need to be managed i.e. stored privately and not leave the development organization. However, the private keys do not need to be kept on a TPM for example, as for production keys. It is recommended that one person in the development organization be responsible generating and storing securely the developer private keys.

Then do the following:

    computer:TOP_DIR/$ pushd TOP_DIR/layers/meta-mbl/pki/nxp/boards
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/$ mkdir 000000-0000-000000-0000
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/$ tar -C 000000-0000-000000-0000 -xvzf cst-2.3.2-tar.gz --strip 1
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/$ cp serial 000000-0000-000000-0000/keys
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/$ cp key_pass.txt 000000-0000-000000-0000/keys
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/$ pushd 000000-0000-000000-0000/keys
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/000000-0000-000000-0000/keys/$ ./hab4_pki_tree.sh
    
When the hab4_pki_tree.sh tool is run, the tools asks a series of questions:

Do you want to use an existing CA key

    Do you want to use an existing CA key (y/n)?: n. This development machine will be a CA and have a top level root key.
    Do you want to use Elliptic Curve Cryptography (y/n)?: n. This results in the use of RSA cryptography.
    Enter key length in bIt's for PKI tree: 4096. This is the longest supported key length (strongest).
    Enter PKI tree duration (years): 10. This specifies when the generated certificates will expire.
    How many Super Root Keys should be generated? 4. The warp7 has sufficient space for 4 SRK hashes, so we generate 4 keys and proceed on the basis that we're going to program all 4 OTP hash fuses at the same time,
    Do you want the SRK certificates to have the CA flag set? (y/n)?: y. 


The following shows what happens when you run the hab4_pki_tree.sh script:

     +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     This script is a part of the Code signing tools for Freescale's
     High Assurance Boot. It generates a basic PKI tree. The PKI
     tree consists of one or more Super Root Keys (SRK), with each
     SRK having two subordinate keys: 
     + a Command Sequence File (CSF) key 
     + Image key. 
     Additional keys can be added to the PKI tree but a separate 
     script is available for this. This this script assumes openssl
     is installed on your system and is included in your search 
     path. Finally, the private keys generated are password 
     protectedwith the password provided by the file key_pass.txt.
     The format of the file is the password repeated twice:
     my_password
     my_password
     All private keys in the PKI tree are in PKCS #8 format will be
     protected by the same password.
    
    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Do you want to use an existing CA key (y/n)?: n
    Do you want to use Elliptic Curve Cryptography (y/n)?: n
    Enter key length in bIt's for PKI tree: 4096
    Enter PKI tree duration (years): 10
    How many Super Root Keys should be generated? 4
    Do you want the SRK certificates to have the CA flag set? (y/n)?: y
    
    +++++++++++++++++++++++++++++++++++++
    + Generating CA key and certificate +
    
    +++++++++++++++++++++++++++++++++++++

    ... much output deleted.

Make sure the output from the script while generating the keying material doesn't contain any errors.

For example in the keys subdirectory, the following files have been generated:

    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/000000-0000-000000-0000/keys/$ ls -la
    -rw-rw-r-- 1 simhug01 simhug01  7133 Feb 21 14:24 10000000.pem
    -rw-rw-r-- 1 simhug01 simhug01  7004 Feb 21 14:24 10000001.pem
    -rw-rw-r-- 1 simhug01 simhug01  7004 Feb 21 14:24 10000002.pem
    -rw-rw-r-- 1 simhug01 simhug01  7133 Feb 21 14:24 10000003.pem
    -rw-rw-r-- 1 simhug01 simhug01  7004 Feb 21 14:24 10000004.pem
    -rw-rw-r-- 1 simhug01 simhug01  7004 Feb 21 14:24 10000005.pem
    -rw-rw-r-- 1 simhug01 simhug01  7133 Feb 21 14:24 10000006.pem
    -rw-rw-r-- 1 simhug01 simhug01  7004 Feb 21 14:24 10000007.pem
    -rw-rw-r-- 1 simhug01 simhug01  7004 Feb 21 14:24 10000008.pem
    -rw-rw-r-- 1 simhug01 simhug01  7133 Feb 21 14:24 10000009.pem
    -rw-rw-r-- 1 simhug01 simhug01  7004 Feb 21 14:24 1000000A.pem
    -rw-rw-r-- 1 simhug01 simhug01  7004 Feb 21 14:24 1000000B.pem
    -rw-rw-r-- 1 simhug01 simhug01  2450 Feb 21 14:24 CA1_sha256_2048_65537_v3_ca_key.der
    -rw-rw-r-- 1 simhug01 simhug01  3394 Feb 21 14:24 CA1_sha256_2048_65537_v3_ca_key.pem
    -rw-rw-r-- 1 simhug01 simhug01  2450 Feb 21 14:24 CSF1_1_sha256_2048_65537_v3_usr_key.der
    -rw-rw-r-- 1 simhug01 simhug01  3394 Feb 21 14:24 CSF1_1_sha256_2048_65537_v3_usr_key.pem
    -rw-rw-r-- 1 simhug01 simhug01  2450 Feb 21 14:24 CSF2_1_sha256_2048_65537_v3_usr_key.der
    -rw-rw-r-- 1 simhug01 simhug01  3394 Feb 21 14:24 CSF2_1_sha256_2048_65537_v3_usr_key.pem
    -rw-rw-r-- 1 simhug01 simhug01  2450 Feb 21 14:24 CSF3_1_sha256_2048_65537_v3_usr_key.der
    -rw-rw-r-- 1 simhug01 simhug01  3394 Feb 21 14:24 CSF3_1_sha256_2048_65537_v3_usr_key.pem
    -rw-rw-r-- 1 simhug01 simhug01  2450 Feb 21 14:24 CSF4_1_sha256_2048_65537_v3_usr_key.der
    -rw-rw-r-- 1 simhug01 simhug01  3394 Feb 21 14:24 CSF4_1_sha256_2048_65537_v3_usr_key.pem
    -rw-rw-r-- 1 simhug01 simhug01  2450 Feb 21 14:24 IMG1_1_sha256_2048_65537_v3_usr_key.der
    -rw-rw-r-- 1 simhug01 simhug01  3394 Feb 21 14:24 IMG1_1_sha256_2048_65537_v3_usr_key.pem
    -rw-rw-r-- 1 simhug01 simhug01  2450 Feb 21 14:24 IMG2_1_sha256_2048_65537_v3_usr_key.der
    -rw-rw-r-- 1 simhug01 simhug01  3394 Feb 21 14:24 IMG2_1_sha256_2048_65537_v3_usr_key.pem
    -rw-rw-r-- 1 simhug01 simhug01  2450 Feb 21 14:24 IMG3_1_sha256_2048_65537_v3_usr_key.der
    -rw-rw-r-- 1 simhug01 simhug01  3394 Feb 21 14:24 IMG3_1_sha256_2048_65537_v3_usr_key.pem
    -rw-rw-r-- 1 simhug01 simhug01  2450 Feb 21 14:24 IMG4_1_sha256_2048_65537_v3_usr_key.der
    -rw-rw-r-- 1 simhug01 simhug01  3394 Feb 21 14:24 IMG4_1_sha256_2048_65537_v3_usr_key.pem
    -rw-rw-r-- 1 simhug01 simhug01   828 Feb 21 14:24 index.txt
    -rw-rw-r-- 1 simhug01 simhug01    20 Feb 21 14:24 index.txt.attr
    -rw-rw-r-- 1 simhug01 simhug01    20 Feb 21 14:24 index.txt.attr.old
    -rw-rw-r-- 1 simhug01 simhug01   758 Feb 21 14:24 index.txt.old
    -rw-rw-r-- 1 simhug01 simhug01     9 Feb 21 14:24 serial
    -rw-rw-r-- 1 simhug01 simhug01     9 Feb 21 14:24 serial.old
    -rw-rw-r-- 1 simhug01 simhug01  2450 Feb 21 14:24 SRK1_sha256_2048_65537_v3_ca_key.der
    -rw-rw-r-- 1 simhug01 simhug01  3394 Feb 21 14:24 SRK1_sha256_2048_65537_v3_ca_key.pem
    -rw-rw-r-- 1 simhug01 simhug01  2450 Feb 21 14:24 SRK2_sha256_2048_65537_v3_ca_key.der
    -rw-rw-r-- 1 simhug01 simhug01  3394 Feb 21 14:24 SRK2_sha256_2048_65537_v3_ca_key.pem
    -rw-rw-r-- 1 simhug01 simhug01  2450 Feb 21 14:24 SRK3_sha256_2048_65537_v3_ca_key.der
    -rw-rw-r-- 1 simhug01 simhug01  3394 Feb 21 14:24 SRK3_sha256_2048_65537_v3_ca_key.pem
    -rw-rw-r-- 1 simhug01 simhug01  2450 Feb 21 14:24 SRK4_sha256_2048_65537_v3_ca_key.der
    -rw-rw-r-- 1 simhug01 simhug01  3394 Feb 21 14:24 SRK4_sha256_2048_65537_v3_ca_key.pem

Note the following:

    The files 10000000.pem to 1000000B.pem are the 4096 bit private key files and have the yyy purpose. TODO explain this yyy.

    The CA1_sha256_2048_65537_v3_ca_key.{pem, der} are the CA root level 4096 bit private keys in plain text and binary encodings.
    The SRKx_sha256_2048_65537_v3_ca_key.{pem, der} are the SRK (second level) 4096 bit private keys in plain text and binary encodings:
        A hash of 1 or more of these keys are stored in the warp7 OTP fuses to form the root of trust.
        These keys are used to sign certificates (containing a public key) at the next level down in the PKI tree hierarchy i.e. at the third level..
    The CSFx_1_sha256_2048_65537_v3_usr_key.{pem, der} are the (third level) 4096 bit private keys in plain text and binary encodings:
        These keys are subordiate to the corresponding SRKx key at the next level up in the PKI tree hierarchy.
        These keys are used to verify signautres across CSF commands.
    The IMGx_1_sha256_2048_65537_v3_usr_key.{pem, der} are the (third level) 4096 bit private keys in plain text and binary encodings:
        These keys are subordiate to the corresponding SRKx key at the next level up in the PKI tree hierarchy.
        These keys are used to verify signautres across product software. TODO: explain what this means.
    All the private keys are in PKCS#8 format.


For example, in the crts directory the following files have been created:

    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/000000-0000-000000-0000/keys/$ ls -la ../crts/
    total 160
    drwxrwxr-x 2 simhug01 simhug01 4096 Feb 21 14:24 .
    drwxrwxr-x 9 simhug01 simhug01 4096 Apr  2  2016 ..
    -rw-rw-r-- 1 simhug01 simhug01 1388 Feb 21 14:24 CA1_sha256_2048_65537_v3_ca_crt.der
    -rw-rw-r-- 1 simhug01 simhug01 1935 Feb 21 14:24 CA1_sha256_2048_65537_v3_ca_crt.pem
    -rw-rw-r-- 1 simhug01 simhug01 1358 Feb 21 14:24 CSF1_1_sha256_2048_65537_v3_usr_crt.der
    -rw-rw-r-- 1 simhug01 simhug01 7004 Feb 21 14:24 CSF1_1_sha256_2048_65537_v3_usr_crt.pem
    -rw-rw-r-- 1 simhug01 simhug01 1358 Feb 21 14:24 CSF2_1_sha256_2048_65537_v3_usr_crt.der
    -rw-rw-r-- 1 simhug01 simhug01 7004 Feb 21 14:24 CSF2_1_sha256_2048_65537_v3_usr_crt.pem
    -rw-rw-r-- 1 simhug01 simhug01 1358 Feb 21 14:24 CSF3_1_sha256_2048_65537_v3_usr_crt.der
    -rw-rw-r-- 1 simhug01 simhug01 7004 Feb 21 14:24 CSF3_1_sha256_2048_65537_v3_usr_crt.pem
    -rw-rw-r-- 1 simhug01 simhug01 1358 Feb 21 14:24 CSF4_1_sha256_2048_65537_v3_usr_crt.der
    -rw-rw-r-- 1 simhug01 simhug01 7004 Feb 21 14:24 CSF4_1_sha256_2048_65537_v3_usr_crt.pem
    -rw-rw-r-- 1 simhug01 simhug01 1358 Feb 21 14:24 IMG1_1_sha256_2048_65537_v3_usr_crt.der
    -rw-rw-r-- 1 simhug01 simhug01 7004 Feb 21 14:24 IMG1_1_sha256_2048_65537_v3_usr_crt.pem
    -rw-rw-r-- 1 simhug01 simhug01 1358 Feb 21 14:24 IMG2_1_sha256_2048_65537_v3_usr_crt.der
    -rw-rw-r-- 1 simhug01 simhug01 7004 Feb 21 14:24 IMG2_1_sha256_2048_65537_v3_usr_crt.pem
    -rw-rw-r-- 1 simhug01 simhug01 1358 Feb 21 14:24 IMG3_1_sha256_2048_65537_v3_usr_crt.der
    -rw-rw-r-- 1 simhug01 simhug01 7004 Feb 21 14:24 IMG3_1_sha256_2048_65537_v3_usr_crt.pem
    -rw-rw-r-- 1 simhug01 simhug01 1358 Feb 21 14:24 IMG4_1_sha256_2048_65537_v3_usr_crt.der
    -rw-rw-r-- 1 simhug01 simhug01 7004 Feb 21 14:24 IMG4_1_sha256_2048_65537_v3_usr_crt.pem
    -rw-rw-r-- 1 simhug01 simhug01 1384 Feb 21 14:24 SRK1_sha256_2048_65537_v3_ca_crt.der
    -rw-rw-r-- 1 simhug01 simhug01 7133 Feb 21 14:24 SRK1_sha256_2048_65537_v3_ca_crt.pem
    -rw-rw-r-- 1 simhug01 simhug01 1384 Feb 21 14:24 SRK2_sha256_2048_65537_v3_ca_crt.der
    -rw-rw-r-- 1 simhug01 simhug01 7133 Feb 21 14:24 SRK2_sha256_2048_65537_v3_ca_crt.pem
    -rw-rw-r-- 1 simhug01 simhug01 1384 Feb 21 14:24 SRK3_sha256_2048_65537_v3_ca_crt.der
    -rw-rw-r-- 1 simhug01 simhug01 7133 Feb 21 14:24 SRK3_sha256_2048_65537_v3_ca_crt.pem
    -rw-rw-r-- 1 simhug01 simhug01 1384 Feb 21 14:24 SRK4_sha256_2048_65537_v3_ca_crt.der
    -rw-rw-r-- 1 simhug01 simhug01 7133 Feb 21 14:24 SRK4_sha256_2048_65537_v3_ca_crt.pem
    simhug01@e113506-lin:/data/2284/test/to_delete/20180220/warp7-pki/cst-2.3.2/keys$

Note the following:

    The CA1_sha256_2048_65537_v3_ca_crt.{pem, der} are the CA root level certificate in plain text and binary encodings.
    The SRKx_sha256_2048_65537_v3_ca_crt.{pem, der} are the SRK (second level) public key certificate in plain text and binary encodings:
        The certificate contains the public key of the associated SRKx_sha256_2048_65537_v3_ca_key.{pem, der}.
    The CSFx_1_sha256_2048_65537_v3_usr_crt.{pem, der} are the (third level) public key certificate in plain text and binary encodings:
        The certificate contains the public key of the associated CSFx_sha256_2048_65537_v3_ca_key.{pem, der}.
    The IMGx_1_sha256_2048_65537_v3_usr_crt.{pem, der} are the (third level) public key certificate in plain text and binary encodings:
        The certificate contains the public key of the associated IMGx_sha256_2048_65537_v3_ca_key.{pem, der}.
    All the certificates are in X509 format.

In order to program the warp7 OTP, the srktool is used to generate 2 files:

- SRK_1_2_3_4_table.bin e.g. SRK_1_2_3_4_table.bin. This file contains a table of the SRK public keys found in the specified input SRKx_sha256_2048_65537_v3_ca_crt.pem files.
- SRK_1_2_3_4_fuse.bin e.g. SRK_1_2_3_4_fuse.bin. This file contains a hash of the SRK public keys found in the specified input SRKx_sha256_2048_65537_v3_ca_crt.pem files. xxx_fuse.bin can be used to program the OTP fuses.

For example, the following line shows how these files are generated:

    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/000000-0000-000000-0000/keys/$ pushd ../crts
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/000000-0000-000000-0000/crts/$ ../linux64/srktool -h 4 -t SRK_1_2_3_4_2048_table.bin -e SRK_1_2_3_4_2048_fuse.bin -d sha256 -c ./SRK1_sha256_2048_65537_v3_ca_crt.pem,./SRK2_sha256_2048_65537_v3_ca_crt.pem,./SRK3_sha256_2048_65537_v3_ca_crt.pem,./SRK4_sha256_2048_65537_v3_ca_crt.pem -f 1

where:

    -h (--hab-ver) <version> specifies the version of the HAB, which we set to 4 for HAB4.
    -t (--table) <table_file_name> specifies the name of the output table file, which we set to SRK_1_2_3_4_table.bin because its generated from 4 certificated files containing the SRK public keys (specified later).
    -e (–efuses) <fuse_file_name> specifies the name of the output fuse file, which we set to SRK_1_2_3_4_fuse.bin because its generated from 4 certificated files containing the SRK public keys (specified later).
    -c (--certs) <cert1,cert2,...,certN> specifies a comma separated list of certificate file names which contain the SRK public keys.
    -f (--fuse-format) <format> specifies the data format of the SRK efuse binary file. We specify 1 for the default format of 32 fuses (bits) per word.

The full use of srktool is documented in REF4.

Return to the TOPDIR directory by doing the following:

    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/000000-0000-000000-0000/certs/$ popd 
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/000000-0000-000000-0000/keys/$ popd
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/$ popd 
    computer:TOP_DIR/$  


## Warp7: Step 4: Program OTP fuses with SRK hashes using fuse_util.py

TODO: describe how to do this.


## Warp7: Step 5: Build image mbl-console-image(-test)

See the instructions at the following links for details on how to build images:

    meta-mbl README
    meta-mbl-private walkthrough


## Warp7: Step 6. Manually Sign image


Do the following:

    computer:TOP_DIR/$ pushd TOP_DIR/layers/meta-mbl/pki/nxp/sign
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/$ make


This is a sample of the output generated:

    mkdir -p `pwd`/temp
    mkdir -p `pwd`/signed-binaries
    cp `pwd`/../../../../build-mbl/tmp-mbl-glibc/deploy/images/imx7s-warp-mbl/mbl-console-image-imx7s-warp-mbl.wic.gz .
    cp `pwd`/../boards/000000-0000-000000-0000/keys/* `pwd`/temp
    cp `pwd`/../boards/000000-0000-000000-0000/crts/* `pwd`/temp
    cp `pwd`/temp/SRK_1_2_3_4_2048_fuse.bin `pwd`/signed-binaries
    cp -f /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign//csf-templates/* `pwd`/temp
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/fetch_uboot.sh git `pwd`/temp/u-boot https://git.linaro.org/landing-teams/working/mbl/u-boot.git 224318f95f9e41f916579a20f3275ff3773f9c94
    Cloning into '/data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/temp/u-boot'...
    warning: remote HEAD refers to nonexistent ref, unable to checkout.
    
    Switched to a new branch 'mbl-uboot'
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/build_uboot_tools.sh `pwd`/temp/u-boot warp7_secure_config
    make[1]: Entering directory '/data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/temp/u-boot'
    make[1]: Leaving directory '/data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/temp/u-boot'
    make[1]: Entering directory '/data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/temp/u-boot'
      HOSTCC  scripts/basic/fixdep
      HOSTCC  scripts/kconfig/conf.o
      
      ... much output deleted.
      
      HOSTCC  tools/gpimage-common.o
      HOSTCC  tools/dumpimage.o
      HOSTLD  tools/dumpimage
      HOSTCC  tools/mkimage.o
      HOSTLD  tools/mkimage
      HOSTCC  tools/proftool
      HOSTCC  tools/fdtgrep.o
      HOSTLD  tools/fdtgrep
    make[1]: Leaving directory '/data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/temp/u-boot'
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/mkimage_ver_check.sh `pwd`/temp/u-boot/tools/mkimage
    sudo /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/extract-unsigned-images.sh -i mbl-console-image-imx7s-warp-mbl.wic.gz
    mount /dev/mapper/loop6p1 /tmp/tmp.hg5Mo0WcKS
    # Append IVT header to u-boot bin
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/image_sign.sh image_sign_mbl_generate_ivt u-boot.bin u-boot.imx CONFIG_SYS_TEXT_BASE u-boot.cfg imximage.cfg.cfgtmp `pwd`/temp `pwd`/temp/u-boot/tools/mkimage
    # u-boot appends an IVT header so we can sign the .imx binary directly
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/image_sign.sh image_sign_mbl_binary `pwd`/temp 2048-u-boot_sign.csf u-boot.imx `pwd`/../boards/000000-0000-000000-0000/linux64/cst
    Blocks = 0x877ff400 0x00000000 0x00061c00  "IMAGE_IMX_HAB_NAME_REPLACE"
    Blocks = 0x877ff400 0x00000000 0x00061c00  "u-boot.imx"
    CSF Processed successfully and signed data available in 2048-u-boot_sign.csf-csf-header
    # Copy to output directory
    cp `pwd`/temp/u-boot.imx-signed `pwd`/signed-binaries
    cp `pwd`/temp/u-boot.imx `pwd`/temp/u-boot-recover.imx
    cp `pwd`/temp/u-boot.imx.log `pwd`/temp/u-boot-recover.imx.log
    # u-boot appends an IVT header so we can sign the .imx binary directly
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/image_sign.sh image_sign_mbl_binary `pwd`/temp 2048-u-boot-recover_sign.csf u-boot-recover.imx `pwd`/../boards/000000-0000-000000-0000/linux64/cst
    Blocks = 0x877ff400 0x00000000 0x00061c00  "IMAGE_IMX_HAB_NAME_REPLACE"
    Blocks = 0x877ff400 0x00000000 0x00061c00  "u-boot-recover.imx"
    Blocks = 0x00910000 0x0000002c 0x000001d4  "IMAGE_IMX_DCD_NAME_REPLACE"
    Blocks = 0x877ff400 0x00000000 0x00061c00  "u-boot-recover.imx"
    Blocks = 0x00910000 0x0000002c 0x000001d4  "u-boot-recover.imx"
    Blocks = 0x00910000 0x0000002c 0x000001d4  "u-boot-recover.imx"
    4+0 records in
    4+0 records out
    4 bytes copied, 0.00012209 s, 32.8 kB/s
    4+0 records in
    4+0 records out
    4 bytes copied, 0.00014394 s, 27.8 kB/s
    4+0 records in
    4+0 records out
    4 bytes copied, 0.000103629 s, 38.6 kB/s
    CSF Processed successfully and signed data available in 2048-u-boot-recover_sign.csf-csf-header
    4+0 records in
    4+0 records out
    4 bytes copied, 0.000107826 s, 37.1 kB/s
    # Copy to output directory
    cp `pwd`/temp/u-boot-recover.imx-signed `pwd`/signed-binaries
    # Append IVT header to boot script
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/image_sign.sh image_sign_mbl_generate_ivt boot.scr boot.scr.imx CONFIG_LOADADDR u-boot.cfg imximage.cfg.cfgtmp `pwd`/temp `pwd`/temp/u-boot/tools/mkimage
    # Sign boot script
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/image_sign.sh image_sign_mbl_binary `pwd`/temp 2048-boot_scr_sign.csf boot.scr.imx `pwd`/../boards/000000-0000-000000-0000/linux64/cst
    Blocks = 0x807ff400 0x00000000 0x00001c00  "IMAGE_IMX_HAB_NAME_REPLACE"
    Blocks = 0x807ff400 0x00000000 0x00001c00  "boot.scr.imx"
    CSF Processed successfully and signed data available in 2048-boot_scr_sign.csf-csf-header
    # Copy to output dir
    cp `pwd`/temp/boot.scr.imx-signed `pwd`/signed-binaries
    # Append IVT header to boot script
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/image_sign.sh image_sign_mbl_generate_ivt zImage zImage.imx CONFIG_LOADADDR u-boot.cfg imximage.cfg.cfgtmp `pwd`/temp `pwd`/temp/u-boot/tools/mkimage
    # Sign boot script
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/image_sign.sh image_sign_mbl_binary `pwd`/temp 2048-zimage_sign.csf zImage.imx `pwd`/../boards/000000-0000-000000-0000/linux64/cst
    Blocks = 0x807ff400 0x00000000 0x008bbc00  "IMAGE_IMX_HAB_NAME_REPLACE"
    Blocks = 0x807ff400 0x00000000 0x008bbc00  "zImage.imx"
    CSF Processed successfully and signed data available in 2048-zimage_sign.csf-csf-header
    # Copy to output dir
    cp `pwd`/temp/zImage.imx-signed `pwd`/signed-binaries
    # Append IVT header to boot script
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/image_sign.sh image_sign_mbl_generate_ivt imx7s-warp.dtb imx7s-warp.dtb.imx CONFIG_SYS_FDT_ADDR u-boot.cfg imximage.cfg.cfgtmp `pwd`/temp `pwd`/temp/u-boot/tools/mkimage
    # Sign boot script
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/image_sign.sh image_sign_mbl_binary `pwd`/temp 2048-dtb_sign.csf imx7s-warp.dtb.imx `pwd`/../boards/000000-0000-000000-0000/linux64/cst
    Blocks = 0x82fff400 0x00000000 0x00007c00  "IMAGE_IMX_HAB_NAME_REPLACE"
    Blocks = 0x82fff400 0x00000000 0x00007c00  "imx7s-warp.dtb.imx"
    CSF Processed successfully and signed data available in 2048-dtb_sign.csf-csf-header
    # Copy to output dir
    cp `pwd`/temp/imx7s-warp.dtb.imx-signed `pwd`/signed-binaries
    make -f /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign//Makefile optee OPTEE_ROOTFS=rootfs3
    make[1]: Entering directory '/data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign'
    mkdir -p `pwd`/temp
    mkdir -p `pwd`/signed-binaries
    cp `pwd`/../../../../build-mbl/tmp-mbl-glibc/deploy/images/imx7s-warp-mbl/mbl-console-image-imx7s-warp-mbl.wic.gz .
    cp `pwd`/../boards/000000-0000-000000-0000/keys/* `pwd`/temp
    cp `pwd`/../boards/000000-0000-000000-0000/crts/* `pwd`/temp
    cp `pwd`/temp/SRK_1_2_3_4_2048_fuse.bin `pwd`/signed-binaries
    cp -f /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign//csf-templates/* `pwd`/temp
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/fetch_uboot.sh git `pwd`/temp/u-boot https://git.linaro.org/landing-teams/working/mbl/u-boot.git 224318f95f9e41f916579a20f3275ff3773f9c94
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/build_uboot_tools.sh `pwd`/temp/u-boot warp7_secure_config
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/mkimage_ver_check.sh `pwd`/temp/u-boot/tools/mkimage
    # Append IVT header to boot script
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/image_sign.sh image_sign_mbl_generate_ivt rootfs3/uTee.optee rootfs3/uTee.optee.imx CONFIG_OPTEE_LOAD_ADDR u-boot.cfg imximage.cfg.cfgtmp `pwd`/temp `pwd`/temp/u-boot/tools/mkimage
    # Sign boot script
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/image_sign.sh image_sign_mbl_binary `pwd`/temp 2048-optee_sign.csf rootfs3/uTee.optee.imx `pwd`/../boards/000000-0000-000000-0000/linux64/cst
    Blocks = 0x83fff400 0x00000000 0x0003ec00  "IMAGE_IMX_HAB_NAME_REPLACE"
    Blocks = 0x83fff400 0x00000000 0x0003ec00  "rootfs3/uTee.optee.imx"
    CSF Processed successfully and signed data available in 2048-optee_sign.csf-csf-header
    # Copy to output dir
    mkdir -p `pwd`/signed-binaries/rootfs3
    cp `pwd`/temp/rootfs3/uTee.optee.imx-signed `pwd`/signed-binaries/rootfs3
    make[1]: Leaving directory '/data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign'
    make -f /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign//Makefile optee OPTEE_ROOTFS=rootfs5
    make[1]: Entering directory '/data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign'
    mkdir -p `pwd`/temp
    mkdir -p `pwd`/signed-binaries
    cp `pwd`/../../../../build-mbl/tmp-mbl-glibc/deploy/images/imx7s-warp-mbl/mbl-console-image-imx7s-warp-mbl.wic.gz .
    cp `pwd`/../boards/000000-0000-000000-0000/keys/* `pwd`/temp
    cp `pwd`/../boards/000000-0000-000000-0000/crts/* `pwd`/temp
    cp `pwd`/temp/SRK_1_2_3_4_2048_fuse.bin `pwd`/signed-binaries
    cp -f /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign//csf-templates/* `pwd`/temp
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/fetch_uboot.sh git `pwd`/temp/u-boot https://git.linaro.org/landing-teams/working/mbl/u-boot.git 224318f95f9e41f916579a20f3275ff3773f9c94
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/build_uboot_tools.sh `pwd`/temp/u-boot warp7_secure_config
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/mkimage_ver_check.sh `pwd`/temp/u-boot/tools/mkimage
    # Append IVT header to boot script
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/image_sign.sh image_sign_mbl_generate_ivt rootfs5/uTee.optee rootfs5/uTee.optee.imx CONFIG_OPTEE_LOAD_ADDR u-boot.cfg imximage.cfg.cfgtmp `pwd`/temp `pwd`/temp/u-boot/tools/mkimage
    # Sign boot script
    /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/image_sign.sh image_sign_mbl_binary `pwd`/temp 2048-optee_sign.csf rootfs5/uTee.optee.imx `pwd`/../boards/000000-0000-000000-0000/linux64/cst
    Blocks = 0x83fff400 0x00000000 0x0003ec00  "IMAGE_IMX_HAB_NAME_REPLACE"
    Blocks = 0x83fff400 0x00000000 0x0003ec00  "rootfs5/uTee.optee.imx"
    CSF Processed successfully and signed data available in 2048-optee_sign.csf-csf-header
    # Copy to output dir
    mkdir -p `pwd`/signed-binaries/rootfs5
    cp `pwd`/temp/rootfs5/uTee.optee.imx-signed `pwd`/signed-binaries/rootfs5
    make[1]: Leaving directory '/data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign'
    make -f /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign//Makefile combine-image
    make[1]: Entering directory '/data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign'
    sudo /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/add-signed-images.sh -i mbl-console-image-imx7s-warp-mbl.wic.gz
    make[1]: Leaving directory '/data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign'


If everything is successful then a signed image signed-mbl-console-image-imx7s-warp-mbl.wic.gz will be seen in the current directory:

    drwxrwxr-x 2 simhug01 simhug01      4096 Mar 13 16:07 csf-templates
    -rw-rw-r-- 1 simhug01 simhug01      8041 Mar 13 17:21 Makefile
    -rw-r--r-- 1 simhug01 simhug01 135265804 Mar 13 17:24 mbl-console-image-imx7s-warp-mbl.wic.gz
    drwxrwxr-x 2 simhug01 simhug01      4096 Mar 13 17:23 scripts
    drwxrwxr-x 4 simhug01 simhug01      4096 Mar 13 17:24 signed-binaries
    -rw-r--r-- 1 simhug01 simhug01 144713770 Mar 13 17:25 signed-mbl-console-image-imx7s-warp-mbl.wic.gz
    drwxrwxr-x 5 simhug01 simhug01     12288 Mar 13 17:24 temp

Flash the board with the signed-mbl-console-image-imx7s-warp-mbl.wic.gz image.


## Step X boot after flashing

This is what you get from hab_status when you boot an unsigned image when the OTP fuses have not been programmed:


    U-Boot 2018.03-rc2+fslc+g224318f (Feb 26 2018 - 18:04:12 +0000)
    
    CPU:   Freescale i.MX7S rev1.2 800 MHz (running at 792 MHz)
    CPU:   Extended Commercial temperature grade (-20C to 105C) at 49C
    Reset cause: POR
    Board: WARP7 in secure mode OPTEE DRAM 0x9d000000-0xa0000000
    I2C:   ready
    DRAM:  464 MiB
    PMIC: PFUZE3000 DEV_ID=0x30 REV_ID=0x11
    MMC:   FSL_SDHC: 0
    Loading Environment from MMC... *** Warning - bad CRC, using default environment
    Failed (-5)
    In:    serial
    Out:   serial
    Err:   serial
    SEC0: RNG instantiated
    Net:   usb_ether
    Error: usb_ether address not set.
    
    Hit any key to stop autoboot:  0
    => hab_status
    Secure boot disabled
    HAB Configuration: 0xf0, HAB State: 0x66
    --------- HAB Event 1 -----------------
    event data:
            0xdb 0x00 0x08 0x42 0x33 0x11 0xcf 0x00
    
    STS = HAB_FAILURE (0x33)
    RSN = HAB_INV_CSF (0x11)
    CTX = HAB_CTX_CSF (0xCF)
    ENG = HAB_ENG_ANY (0x00)

    --------- HAB Event 2 -----------------
    event data:
            0xdb 0x00 0x14 0x42 0x33 0x0c 0xa0 0x00
            0x00 0x00 0x00 0x00 0x87 0x7f 0xf4 0x00
            0x00 0x00 0x00 0x20
    
    STS = HAB_FAILURE (0x33)
    RSN = HAB_INV_ASSERTION (0x0C)
    CTX = HAB_CTX_ASSERT (0xA0)
    ENG = HAB_ENG_ANY (0x00)
    
    --------- HAB Event 3 -----------------
    event data:
            0xdb 0x00 0x14 0x42 0x33 0x0c 0xa0 0x00
            0x00 0x00 0x00 0x00 0x87 0x7f 0xf4 0x2c
            0x00 0x00 0x01 0xd4
    
    STS = HAB_FAILURE (0x33)
    RSN = HAB_INV_ASSERTION (0x0C)
    CTX = HAB_CTX_ASSERT (0xA0)
    ENG = HAB_ENG_ANY (0x00)
    
    --------- HAB Event 4 -----------------
    event data:
            0xdb 0x00 0x14 0x42 0x33 0x0c 0xa0 0x00
            0x00 0x00 0x00 0x00 0x87 0x7f 0xf4 0x20
            0x00 0x00 0x00 0x01
    
    STS = HAB_FAILURE (0x33)
    RSN = HAB_INV_ASSERTION (0x0C)
    CTX = HAB_CTX_ASSERT (0xA0)
    ENG = HAB_ENG_ANY (0x00)
    
    --------- HAB Event 5 -----------------
    event data:
            0xdb 0x00 0x14 0x42 0x33 0x0c 0xa0 0x00
            0x00 0x00 0x00 0x00 0x87 0x80 0x00 0x00
            0x00 0x00 0x00 0x04
    
    STS = HAB_FAILURE (0x33)
    RSN = HAB_INV_ASSERTION (0x0C)
    CTX = HAB_CTX_ASSERT (0xA0)
    ENG = HAB_ENG_ANY (0x00)
    =>


Warp7: Step 7: Flash and boot signed image.

See the instructions at the following links for details on how to flash and reboot the board:

    meta-mbl README
    meta-mbl-private walkthrough

Warp7: Step 8: OPTIONAL: Close and lock device.

TODO

Step 3.4: Verify authentication failure events in log

After rebooting the board and logging in, you can run the following script to check on the OTP fuse settings and the boot_mode (SEC_CONFIG) setting. See below for an example.

    root@imx7s-warp:~# python3 imx7-efuse-util.py -s
    Path : /sys/bus/nvmem/devices/imx-ocotp0/nvmem
    Boot Fuse settings
    OCOTP_BOOT_CFG0 = 0x10002820
            FORCE_COLD_BOOT = 0
            BT_FUSE_SEL = 1
            DIR_BT_DIS = 0
            SEC_CONFIG = 0
            Boot Mode = MMC/eMMC
    Secure fuse keys
    Bank 6
            0x00000000
            0x00000000
            0x00000000
            0x00000000
    Bank 7
            0x00000000
            0x00000000
            0x00000000
            0x00000000

todo: add here how to review HAV event log showing authentication failures
Warp7 Solution 3: Step 4: Program OTP Fuses

TODO:

    the imx7s-efuse-util.py is not on the board by default. Hence, need to build mbl-console-image-test (as has ssh to scp the script onto the board, and has python so can run script)
    would be better if imx7-efuse-util.py was in the w7 test image so it could be used to program the .bin file.
    the program the otp fuses with the following command (written below)
    then remove the fuse.bin and the script, as they'll never be used again (may need to close the device).

On the board:

    imx7-efuse-util.py -k /etc/cst/warp7/crts/SRK_1_2_3_4_fuse.bin


TODO: Actually the fuse.bin is now present in the /boot directory, so the above command should be changed
Warp7 Solution 3: Step 5: Reboot Board
Warp7 Solution 3: Step 6: Verify No Authentication Failure Events


References

REF1: https://boundarydevices.com/high-assurance-boot-hab-dummies/ (see attachment  https___boundarydevices.pdf to this page)

REF2: Security Reference Manual for i.MX, 7Dual and 7Solo Applications Processors, IMX7DSSRM-security.pdf (file attached to this page).

REF3: Secure Boot on i.MX50, i.MX53, and i.MX 6 Series using HABv4, AN4581_HAB_USB_appnote.pdf (file attached to this page).

REF4: HAB Code-Signing Tool, User’s Guide, HABCST_UG.pdf (file attached to this page).

REF5: mbed Linux storage partition specification, https://github.com/ARMmbed/mbl-specs/blob/jh-partitions/PARTITIONS.md

REF6: Trusted Board Boot Requirements Client (TBBR-Client), 

http://teamsites.arm.com/sites/atg/ATGArchitecture/System%20Architecture/PDD/Security/DEN0006_Trusted_Board_Boot_Requirements_CLIENT.pdf

REF7: Trusted Base System Architecture Client (TBSA-Client), 

http://teamsites.arm.com/sites/atg/ATGArchitecture/System%20Architecture/PDD/Security/ARM-DEN-0021C%20Trusted_Base_System_Architecture_Client.pdf

REF8: How to setup your own CA with OpenSSL, https://gist.github.com/Soarez/9688998





