# Warp 7: How to sign images

This document describes how to sign Warp7 images, program One-Time Programmable fuses and check whether
the secure boot authentication has been completed successfully. The board can then (optionally) be locked.

In order to sign Warp7 images, the Code Signing Tool is obtained from NXP under license. These instructions refer to the
use of version 2.3.3 of the CST (cst-2.3.3.tar.gz)

## Terminology

This section defines the terminology used throughout the document:

    BSP: Board Support Package
    CA : Certificate Authority
    CSF: Command Sequence File
    CST: Code-Signing Tool
    DCD: Device Configuration Data
    DEK: Data Encryption Key
    DER: File extension for binary DER encoded certificates
    HAB: High Assurance Boot
    IVT: Image Vector Table
    NC : No Comment
    OTP: One-Time Programmable
    PEM: File extension for X509 base64 encoded certificates
    SiP: Silicon Partner
    SRK: Super Root Key (private signing keys)
    TSP: Target (Family) Support Package e.g. the feature support common to the IMx7 family
    TPM: Trusted Platform Module


## Known issues

The known issues with signing a Warp7 image include:

- The output of the `hab_status` u-boot command for a signed image booted on a board with factory settings for OTP fuses (all 0x00000000)
  is currently not understood. The NXP documentation doesn't clarify this point.
- The recovery process is currently not documented.


# The developer workflow for booting a signed image

The developer work-flow steps for booting a signed image includes the following steps:

- Step 1: Prerequisites.
    - Acquire the NXP CST and install required packages.
- Step 2: Generate signing keys.
    - Use the CST tool `hab4_pki_tree.sh` to generate signing keys and certificates.
- Step 3: Generate the Fuse and Table Binaries.
    - Use the CST srktool to generate the fuse and table binary files for programming OTP fuses.
- Step 4: Build an unsigned mbl-console-image-test image.
    - The test image is used first as it contains Python3 which is required to run the OTP programming tool.
- Step 5. Sign the image.
    - Sign the mbl-console-image-test image using the signing makefile tool.
- Step 6: Flash/boot the signed image.
    - Inspect the `hab_status` report.
- Step 7: Program the OTP fuses.
    - Use the imx7-efuse-util.py tool to program the OTP fuses.
- Step 8: Reboot and verify a successful secure boot.
    - Reboot and check the `hab_status` reports secure boot successful authentication.
- Step 9: OPTIONAL: Close and lock device.

Each step is described in more detail below.

# Step 1: Prerequisites

This section describes the preparatory steps necessary for creating a signed image.


## Install required packages for signing

Please consult the [Prerequisites](https://github.com/ARMmbed/meta-mbl/blob/master/docs/walkthrough.md#-1-prepare-your-development-environment) section of the
MBL [Instructions for Building Images](https://github.com/ARMmbed/meta-mbl/blob/master/docs/walkthrough.md) to ensure these packages are installed
on your development host.

In addition, the following packages should be installed for signing:
```
    computer:$ sudo apt-get install make bash kpartx mktemp
```

## Create a workspace for building images

Create an Mbed Linux workspace by following the instructions in the
[Instructions for Building Images](https://github.com/ARMmbed/meta-mbl/blob/master/docs/walkthrough.md) document.

Throughout this document the `mbl-alpha` directory created in the [Instructions for Building Images](https://github.com/ARMmbed/meta-mbl/blob/master/docs/walkthrough.md) guide is referred to as TOP_DIR.

## Acquire the NXP Code Signing Tool (CST)
To sign Warp7 images, download the NXP Code Signing Tool (CST) from the NXP site. This will require you to accept the NXP Software License Agreement (See the [NXP License Page][NXP-Webpage-for-accepting-CST-Licence-agreement-and-downloading-the-tool] for details).

Having downloaded the CST (e.g. cst-2.3.3.tar.gz), copy the tarball to the following location in the workspace:
```
    TOP_DIR/layers/meta-mbl/pki/nxp/boards
```

# Step 2: Generate signing keys

This section describes how to create the public/private keys and certificates used to sign boot chain component(s).
The secure boot process checks that each boot chain component(s) has been signed by the party trusted to issue valid software images (the signing authority). The secure boot process does not currently implement confidentiality (encryption of images).  

When generating the keying material, the development machine used to create the keys and certificates is acting as a Certificate Authority.

The keying material is composed of the following:

- **A top level private key called the CA private key**. This is used to sign certificates in the next layer down from the CA root in the PKI key hierarchy (tree).
- **Super Root Keys (SRK)**. These private keys are used to sign certificates (containing a public key) at the next level down (second level) in the PKI tree hierarchy.
  The private keys are stored in key files and the public keys are stored in certificates signed by the private key. A hash of 1-4 SRK public keys will be programmed into the OTP fuses. The certificates are embedded in signed images so the secure boot process can:
    - Recover the public key,
    - Check the signature on the certificate,
    - Hash the key and
    - Check the hash agrees with the hash in the relevant OTP fuse.
- **CSF keys and certificates (at the third level of the PKI tree hierarchy)**.
    - These keys are subordinate to the corresponding SRKx key at the next level up in the PKI tree hierarchy.
    - These are used to sign binary components in the boot chain e.g. u-boot, Linux kernel and OPTEE.
    - These keys are used to verify signatures across CSF commands. See [4] for more information on CSF commands.
- **IMG keys and certificates (at the third level of the PKI tree hierarchy)**.
    - These keys are subordinate to the corresponding SRKx key at the next level up in the PKI tree hierarchy.
    - These keys are used to verify signatures across product software.

**Storing your development keys**

The process described here is for use by a developer generating keying material to sign images and perform development tasks. These keys need to be stored securely and privately so they can not leave the organization, as they could be used in the future to compromise production devices. Developer private keys may need to be kept on a Trusted Platform Module (TPM) for example, as for production keys, but this depends on the security policy of your organization. It is recommended that one person in the development organization is responsible for generating and securely storing the developer private keys.

**Generating keying material**

To generate the keying material, perform the following steps:

1. Make the boards directory the current working directory.
```
    computer:TOP_DIR/$ cd TOP_DIR/layers/meta-mbl/pki/nxp/boards
```
2. Create a sub-directory with the ID of a board (which can be determined from the QR code sticker attached to the board). In this example the board ID 000000-0000-000000-0000 is used, but the actual board ID should be used:
```
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/$ mkdir 000000-0000-000000-0000
```
3. Unroll the CST tarball into the board sub-directory stripping off the top level directory from the tarball paths.
```
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/$ tar -C 000000-0000-000000-0000 -xvzf cst-2.3.3.tar.gz --strip 1
```
4. Copy the serial file into the 000000-0000-000000-0000/keys directory. This file contains the base serial index number to enumerate (some) HAB tool generated files.
```
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/$ cp serial 000000-0000-000000-0000/keys
```
5. Create the (private) key pass phrase file key_pass.txt in the 000000-0000-000000-0000/keys directory. The private key files are protected using the pass phrase (repeated twice) in this file.
```
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards$ cat key_pass.txt
    Replace-this-text-with-your-private-pass-phrase
    Replace-this-text-with-your-private-pass-phrase
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards$
```
This file should be stored securely with the other private keying material.

6. Make the current working directory the 000000-0000-000000-0000/keys directory.
```
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/$ cd 000000-0000-000000-0000/keys
```
7. Run the HAB4 tool to generate the keying material:
```
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/000000-0000-000000-0000/keys/$ ./hab4_pki_tree.sh
```
When the `hab4_pki_tree.sh` tool is run, the tool asks a series of questions. The questions and responses are shown
in the following sample of the console log (with line numbers inserted for reference):
```
    1. Do you want to use an existing CA key (y/n)?: n
    2. Do you want to use Elliptic Curve Cryptography (y/n)?: n
    3. Enter key length in bIt's for PKI tree: 2048
    4. Enter PKI tree duration (years): 10
    5. How many Super Root Keys should be generated? 4
    6. Do you want the SRK certificates to have the CA flag set? (y/n)?: y
```

where:
1. No specifies this development machine will be a CA and have a top level root key.
2. No specifies RSA cryptography will be used to generate the keying material.
3. 2048 specifies the key length (other alternatives are 1024 (shortest/weakest) and 4096 (longest/strongest).
4. 10 specifies that the generated certificates will expire in 10 years time.
5. 4 specifies that 4 SRKs will be generated. The warp7 has sufficient space for 4 SRK hashes, so 4 keys are generated. All 4 SRK key hashes will be programmed into the OTP fuses in one operation, rather than 4 separate operations.
6. Yes specifies that the CA flag will be included in certificates.

The following shows what happens when all the questions have been answered and the `hab4_pki_tree.sh` script generates the keying
material:
```
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
```

Please ensure the script output does not contain any errors. On success, the following files will have been
generated in the keys sub-directory:
```
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
```
The following provides information as to the purpose of these files:

- The `CA1_sha256_2048_65537_v3_ca_key.{pem, der}` are the CA root level 2048 bit private keys in plain text and binary encodings. These are the first level keys in the PKI tree hierarchy.
- The `SRKx_sha256_2048_65537_v3_ca_key.{pem, der} (x={1,2, 3,4})` are the SRK (second level) 2048 bit private keys in plain text and binary encodings:
    - The private keys are used to sign the certificates (containing a public key) at the next level down in the PKI tree hierarchy i.e. at the third level.
- The `CSFx_1_sha256_2048_65537_v3_usr_key.{pem, der} (x={1,2, 3,4})` are the (third level) 2048 bit private keys in plain text and binary encodings:
- The `IMGx_1_sha256_2048_65537_v3_usr_key.{pem, der} (x={1,2, 3,4})` are the (third level) 2048 bit private keys in plain text and binary encodings:
- The `10000000.pem` to 1`000000B.pem` are public keys for the SRK, CSF and IMG private keys mentioned above.
    - There are 12 files in total, 4 public keys each for the SRK, CSF and IMG private keys.  
    - The hashes of the 4 SRKx public keys are stored in the Warp7 OTP fuses to form the Root of Trust.

On success, the following files will have been generated in the `crts` sub-directory:
```
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/000000-0000-000000-0000/keys/$ ls -la ../crts/
    total 160
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
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/000000-0000-000000-0000/keys/$
```
The following provides information as to the purpose of these files:

- The `CA1_sha256_2048_65537_v3_ca_crt.{pem, der}` are the CA root level certificate in plain text and binary encodings.
- The `SRKx_sha256_2048_65537_v3_ca_crt.{pem, der} (x={1,2, 3,4})` are the SRK (second level) public key certificates in plain text and binary encodings:
    - The certificate contains the public key of the associated S`RKx_sha256_2048_65537_v3_ca_key.{pem, der}` private key.
- The `CSFx_1_sha256_2048_65537_v3_usr_crt.{pem, der} (x={1,2, 3,4})` are the (third level) public key certificates in plain text and binary encodings:
    - The certificate contains the public key of the associated `CSFx_sha256_2048_65537_v3_ca_key.{pem, der}` private key.
- The `IMGx_1_sha256_2048_65537_v3_usr_crt.{pem, der} (x={1,2, 3,4})` are the (third level) public key certificates in plain text and binary encodings:
    - The certificate contains the public key of the associated `IMGx_sha256_2048_65537_v3_ca_key.{pem, der}` private key.
- All the certificates are in X509 format.


# Step 3: Generate the fuse and table binaries

To programme the warp7 OTP fuses, use the CST srktool to generate 2 files:

- `SRK_1_2_3_4_2048_table.bin`. This file contains a table of the SRK public keys found in the specified input SRKx_sha256_2048_65537_v3_ca_crt.pem files.
- `SRK_1_2_3_4_2048_fuse.bin`. This file contains a hash of the SRK public keys found in the specified input SRKx_sha256_2048_65537_v3_ca_crt.pem files.
  SRK_1_2_3_4_2048_fuse.bin is used to program the OTP fuses.

For example, the following line shows how these files are generated:
```
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/000000-0000-000000-0000/keys/$ cd ../crts
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/boards/000000-0000-000000-0000/crts/$ ../linux64/bin/srktool -h 4 -t SRK_1_2_3_4_2048_table.bin -e SRK_1_2_3_4_2048_fuse.bin -d sha256 -c ./SRK1_sha256_2048_65537_v3_ca_crt.pem,./SRK2_sha256_2048_65537_v3_ca_crt.pem,./SRK3_sha256_2048_65537_v3_ca_crt.pem,./SRK4_sha256_2048_65537_v3_ca_crt.pem -f 1
```
where:

    `-h` (--hab-ver) <version> specifies the version of the HAB, which we set to 4 for HAB4.
    `-t` (--table) <table_file_name> specifies the name of the output table file, which is set to SRK_1_2_3_4_2048_table.bin because its generated from 4 certificate files containing the SRK public keys.
    `-e` (–efuses) <fuse_file_name> specifies the name of the output fuse file, which we set to SRK_1_2_3_4_2048_fuse.bin because its generated from 4 certificate files containing the SRK public keys.
    `-c` (--certs) <cert1,cert2,...,certN> specifies a comma separated list of certificate file names which contain the SRK public keys.
    `-d`, --digest <digestalg>: Message Digest algorithm. Either sha1 or sha256    
    `-f` (--fuse-format) <format> specifies the data format of the SRK efuse binary file.
       We specify 1 for the default format of 32 fuses (bits) per word.

The full use of srktool is documented in [4].


# Step 4: Build an unsigned mbl-console-image-test image

To build an image, use the MBL [Instructions for Building Images](https://github.com/ARMmbed/meta-mbl/blob/master/docs/walkthrough.md). The test image is created by using the mbl-console-image-test bitbake target, as shown in the following command:
```
    computer:TOP_DIR/build-mbl/$ bitbake mbl-console-image-test
```

# Step 6. Manually sign the image

After a build, use the following command to sign the image:
```
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/sign/$ make IMAGE_NAME=<image-name> CST_BOARD_ID=<board-id>
```
where:

* `image-name` is the name of the image in the TOP_DIR/build-mbl/tmp-mbl-glibc/deploy/images/imx7s-warp-mbl directory to sign. This can be:
    - mbl-console-image-imx7s-warp-mbl.wic.gz
    - mbl-console-image-test-imx7s-warp-mbl.wic.gz
    - `image-name` defaults to mbl-console-image-imx7s-warp-mbl.wic.gz.
* `board-id` is the subdirectory in the TOP_DIR/layers/meta-mbl/pki/nxp/boards containing the keying material for the board. The `board-id` defaults to 000000-0000-000000-0000.

For example, to sign the test image with the keying material stored in boards/000000-0000-000000-0000 use the following command:
```
    computer:TOP_DIR/$ cd TOP_DIR/layers/meta-mbl/pki/nxp/sign
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/sign/$ make IMAGE_NAME=mbl-console-image-test-imx7s-warp-mbl.wic.gz
```
Excerpts from the generated sample output are shown in the following console output listing:
```
    mkdir -p `pwd`/temp
    mkdir -p `pwd`/signed-binaries
    cp `pwd`/../../../../build-mbl/tmp-mbl-glibc/deploy/images/imx7s-warp-mbl/mbl-console-image-imx7s-warp-mbl.wic.gz .
    cp `pwd`/../boards/000000-0000-000000-0000/keys/* `pwd`/temp
    <<<... much output deleted >>>
    CSF Processed successfully and signed data available in 2048-u-boot_sign.csf-csf-header
    <<<... much output deleted >>>
    CSF Processed successfully and signed data available in 2048-u-boot-recover_sign.csf-csf-header
    <<<... much output deleted >>>
    CSF Processed successfully and signed data available in 2048-boot_scr_sign.csf-csf-header
    <<<... much output deleted >>>
    CSF Processed successfully and signed data available in 2048-zimage_sign.csf-csf-header
    <<<... much output deleted >>>
    CSF Processed successfully and signed data available in 2048-dtb_sign.csf-csf-header
    <<<... much output deleted >>>
    CSF Processed successfully and signed data available in 2048-optee_sign.csf-csf-header
    <<<... much output deleted >>>
    CSF Processed successfully and signed data available in 2048-optee_sign.csf-csf-header
    <<<... much output deleted >>>
    sudo /data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign/./scripts/add-signed-images.sh -i mbl-console-image-imx7s-warp-mbl.wic.gz
    make[1]: Leaving directory '/data/2284/test/to_delete/20180313/layers/meta-mbl/pki/sign'
```
Part of the make file operations need to run with sudo privileges (in order to mount the loop back device used for
creating the signed image). Enter your account password when prompted.

On success, a signed image (`signed-mbl-console-image-imx7s-warp-mbl.wic.gz`) file will have been created in the current directory:
```
    drwxrwxr-x 2 simhug01 simhug01      4096 Mar 13 16:07 csf-templates
    -rw-rw-r-- 1 simhug01 simhug01      8041 Mar 13 17:21 Makefile
    -rw-r--r-- 1 simhug01 simhug01 135265804 Mar 13 17:24 mbl-console-image-test-imx7s-warp-mbl.wic.gz
    drwxrwxr-x 2 simhug01 simhug01      4096 Mar 13 17:23 scripts
    drwxrwxr-x 4 simhug01 simhug01      4096 Mar 13 17:24 signed-binaries
    -rw-r--r-- 1 simhug01 simhug01 144713770 Mar 13 17:25 signed-mbl-console-image-test-imx7s-warp-mbl.wic.gz
    drwxrwxr-x 5 simhug01 simhug01     12288 Mar 13 17:24 temp
```

To clean the working directory, use the following command:
```
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/sign/$ make clean
```


# Step 6: Flash/boot the signed image

Follow the instructions in the [Write the disk image to your device and boot Mbed Linux](https://github.com/ARMmbed/meta-mbl/blob/master/docs/walkthrough.md#-8-write-the-disk-image-to-your-device-and-boot-mbed-linux)
section of the MBL [Instructions for Building Images](https://github.com/ARMmbed/meta-mbl/blob/master/docs/walkthrough.md).

When the board is booted press a key at the u-boot prompt.
Type `hab_status` to see if any events have been generated, as illustrated in the console output below:

```
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
```
As the board currently has the OTP fuse settings that were programmed in the factory (0x00000000 for each fuse), the HAB events are indeterminate (the NXP documentation is silent on the system behaviour in this case).

# Step 7: Program the OTP fuses

At the present time, the OTP fuse programming tool imx7-efuse-util.py is not included in the mbl-console-image-test distribution
and therefore has to be copied to the board. The imx7-efuse-util.py script is available at the following location:
```
    computer:TOP_DIR/layers/meta-mbl/pki/nxp/sign/scripts/$ ls -al

    total 72
    drwxrwxr-x 2 simhug01 simhug01  4096 Mar 15 11:54 ./
    drwxrwxr-x 6 simhug01 simhug01  4096 Mar 15 12:01 ../
    -rwxrwxr-x 1 simhug01 simhug01  8836 Mar 13 16:07 add-signed-images.sh*
    -rwxrwxr-x 1 simhug01 simhug01   322 Mar 13 16:07 build_uboot_tools.sh*
    -rwxrwxr-x 1 simhug01 simhug01  8217 Mar 13 16:07 extract-unsigned-images.sh*
    -rwxrwxr-x 1 simhug01 simhug01   396 Mar 13 16:07 fetch_uboot.sh*
    -rwxrwxr-x 1 simhug01 simhug01  8746 Mar 13 17:23 image_sign.sh*
    -rwxrwxr-x 1 simhug01 simhug01 14626 Mar 15 11:54 imx7-efuse-util.py*
    -rwxrwxr-x 1 simhug01 simhug01   448 Mar 13 16:07 mkimage_ver_check.sh*
```

Follow the [instructions for configuring wifi]( https://github.com/ARMmbed/meta-mbl/blob/master/docs/wifi.md) and then
scp the imx7-efuse-util.py script onto your board, for example, into `/home/root`.

Move to the `/boot` directory on the target board and check that the `SRK_1_2_3_4_2048_fuse.bin` file is present:
```
    root@imx7s-warp-mbl:~# cd /boot
    root@imx7s-warp-mbl:/boot# ls -al
    total 17985
    drwxr-xr-x    2 root     root         16384 Jan  1  1970 .
    drwxr-xr-x   19 root     root          1024 Mar 13 03:57 ..
    -rwxr-xr-x    1 root     root            32 Mar  6 17:13 SRK_1_2_3_4_2048_fuse.bin
    -rwxr-xr-x    1 root     root          1452 Feb 26 18:22 boot.scr
    -rwxr-xr-x    1 root     root         11072 Mar  6 17:13 boot.scr.imx-signed
    -rwxr-xr-x    1 root     root         27470 Feb 26 18:22 imx7s-warp.dtb
    -rwxr-xr-x    1 root     root         35648 Mar  6 17:13 imx7s-warp.dtb.imx-signed
    -rwxr-xr-x    1 root     root       9153752 Feb 26 18:22 zImage
    -rwxr-xr-x    1 root     root       9161536 Mar  6 17:13 zImage.imx-signed
    root@imx7s-warp-mbl:/boot#
```
The `SRK_1_2_3_4_2048_fuse.bin` contains the hashes of the public keys that will be programmed into the OTP fuses. The boot chain components have been
signed with the corresponding private keys.   

To get the usage message, on the board, run the script as follows:
```
    root@imx7s-warp-mbl:~# python3 ~/imx7-efuse-util.py -h

    usage: imx7-efuse-util.py [-h] [-k KEYFILE] [-p KEYFILE_PATH] [-l] [-y] [-s]
                              [-d]

    optional arguments:
      -h, --help       show this help message and exit
      -k KEYFILE       keyfile containing data to write to fuses
      -p KEYFILE_PATH  path to write keyfile to
      -l               Lock part to secure mode - irrevocable
      -y               Yes to all prompts
      -s               Print fuse status
      -d               Dump entire fuse contents
    root@imx7s-warp-mbl:/boot#
```

Before programming the OTP fuses, use the imx7-efuse-util.py -s option to inspect the status of the fuses. The output of the script should look similar to the output below:
```
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
```

Observe the following details about the output:
- The `FORCE_COLD_BOOT` setting is 0.
- The `BT_FUSE_SEL` setting is 1.
- The `DIR_BT_DIS` setting is 0.
- The `SEC_CONFIG` setting is 0.
- The Boot Mode setting is MMC/eMMC.
- See [2] Chapter 6 for the definition of the above settings.
- The Warp7 has 2 banks of 4 x 32bit OTP fuses, denoted Bank 6 and Bank 7 in the output. Hence there are 8 x 32 bit OTP fuse bits in total. This suggests the SRK public key hashes are each 64bits in size.
- Notice that all the OTP fuses are reported as 0x00000000 as this board has been received from the factory and not programmed before.

You can program the OTP fuses in the following way:
```
    root@imx7s-warp-mbl:/boot# python3 ~/imx7-efuse-util.py -k SRK_1_2_3_4_2048_fuse.bin
    Write key values in SRK_1_2_3_4_2048_fuse.bin to SRK fuses => /sys/bus/nvmem/devices/imx-ocotp0/nvmem y/n y
    Key 0 0xbfeddd04
    Key 1 0xbb0a8ec7
    Key 2 0xd4d51226
    Key 3 0xba3980c2
    Key 4 0x9e99ae87
    Key 5 0x0eb3b21c
    Key 6 0x475c08e3
    Key 7 0xa55adc2c
    root@imx7s-warp-mbl:/boot#
```

After the OTP fuses have been programmed, this is the sample output of the imx7-efuse-util.py script:
```
    root@imx7s-warp-mbl:/boot# python3 ~/imx7-efuse-util.py -s
    Path: /sys/bus/nvmem/devices/imx-ocotp0/nvmem
    Boot Fuse settings
    OCOTP_BOOT_CFG0 = 0x10002820
            FORCE_COLD_BOOT = 0
            BT_FUSE_SEL     = 1
            DIR_BT_DIS      = 0
            SEC_CONFIG      = 0
            Boot Mode       = MMC/eMMC
    Secure fuse keys
    Bank 6
            0xbfeddd04
            0xbb0a8ec7
            0xd4d51226
            0xba3980c2
    Bank 7
            0x9e99ae87
            0x0eb3b21c
            0x475c08e3
            0xa55adc2c
```
Observe the following details about the output:
- The Bank 6 and 7 OTP fuses now have non-zero settings as they've been programmed with the hashes of SRKs.        


# Step 8: Reboot and verify the successful secure boot

Having programmed the OTP fuses with the correct hashes, the board can be rebooted and the `hab_status` event log inspected. The following is the console log of the u-boot initialisation and the output of the `hab_status` command:

```
    - U-Boot 2018.03-rc2+fslc+g224318f (Feb 26 2018 - 18:04:12 +0000)

    CPU:   Freescale i.MX7S rev1.2 800 MHz (running at 792 MHz)
    CPU:   Extended Commercial temperature grade (-20C to 105C) at 44C
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
    No HAB Events Found!

    =>
```
Observe the following from the above output:
- The `hab_status` command reports `No HAB Events Found!` which indicates u-boot has successfully authenticated all of the components in the boot chain. If  you do not see this message then something has gone wrong with the signing and/or authentication process. Ensure that this message is reported before locking the device.

# Step 9: OPTIONAL: Close and lock device

<span class="warning"> **WARNING**: Before locking the device, make sure the `hab_status` command reports successful authentication, otherwise, once it is locked, you will not be able to access this device again.</span>

Use the following command to lock the device:
```
    root@imx7s-warp:~# python3 imx7-efuse-util.py -l
```
 An example of the output from imx7-efuse-util.py when locking the board into secure boot mode is shown below:
```
    root@imx7s-warp:~# python3 imx7-efuse-util.py -l
    Secure fuse keys
    Bank 6
            0xbfeddd04
            0xbb0a8ec7
            0xd4d51226
            0xba3980c2
    Bank 7
            0x9e99ae87
            0x0eb3b21c
            0x475c08e3
            0xa55adc2c
    Lock part into secure-boot mode with above keys ?  y/n y
    Are you REALLY sure ? y/n y
    Key 0 0xbfeddd04
    Key 1 0xbb0a8ec7
    Key 2 0xd4d51226
    Key 3 0xba3980c2
    Key 4 0x9e99ae87
    Key 5 0x0eb3b21c
    Key 6 0x475c08e3
    Key 7 0xa55adc2c
    Boot Fuse settings
    OCOTP_BOOT_CFG0 = 0x12002820
            FORCE_COLD_BOOT = 0
            BT_FUSE_SEL     = 1
            DIR_BT_DIS      = 0
            SEC_CONFIG      = 1
            Boot Mode       = MMC/eMMC
```


# References

1. [Boundary Devices NXP HAB for Dummies ][hab-for-dummies]

2. Security Reference Manual for i.MX, 7Dual and 7Solo Applications Processors, IMX7DSSRM-security.pdf.

3. Secure Boot on i.MX50, i.MX53, and i.MX 6 Series using HABv4, AN4581_HAB_USB_appnote.pdf.

4. HAB Code-Signing Tool, User’s Guide, HABCST_UG.pdf.

5. [mbed Linux storage partition specification][mbed-Linux-storage-partition-specification]

6. Trusted Board Boot Requirements Client (TBBR-Client), ARM Confidential document.

7. Trusted Base System Architecture Client (TBSA-Client), ARM Confidential document.

8. [How to setup your own CA with OpenSSL][How-to-setup-your-own-CA-with-OpenSSL]

9. [NXP Webpage for accepting CST Licence agreement and downloading the tool][NXP-Webpage-for-accepting-CST-Licence-agreement-and-downloading-the-tool]

10. [Variwiki Page on NXP High Assurance Boot](http://www.variwiki.com/index.php?title=High_Assurance_Boot)



[hab-for-dummies]: https://boundarydevices.com/high-assurance-boot-hab-dummies/ (see attachment  https___boundarydevices.pdf to this page)
[mbed-Linux-storage-partition-specification]: https://github.com/ARMmbed/meta-mbl/blob/master/docs/partitions.md
[How-to-setup-your-own-CA-with-OpenSSL]: https://gist.github.com/Soarez/9688998
[NXP-Webpage-for-accepting-CST-Licence-agreement-and-downloading-the-tool]: https://www.nxp.com/webapp/sps/download/license.jsp?colCode=IMX_CST_TOOL
