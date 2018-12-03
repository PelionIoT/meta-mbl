# <a name="section-1"></a> 1. Mbed Linux OS Basic Signing Flow

## <a name="section-1-1"></a> 1.1 Overview

The MBL secure boot process is responsible for bringing the system into a secure computing state after power-on, which includes 
only authorized versions of software components are permitted to run in the system. To do this the secure boot 
implements the following processing:

* FOR EACH COMPONENT in a list of boot chain components DO:
    * Load the COMPONENT into memory.
    * Compute a HASH (signature) of the COMPONENT binary image.
    * IF the HASH matches the hash in the authority's 'COMPONENT content' certificate then the image has been authenticated and will run.
    * ELSE stop booting, and possibly enter a recovery mode depending on configuration.

For example, the processing logic iterates over the following boot chain components and associated content certificates:
* TF-A BL2 has the [TRUSTED-BOOT-FW-CERT](#TRUSTED-BOOT-FW-CERT) content certificate.
* TF-A BL31 (Secure Monitor) has the [SOC-FW-CONTENT-CERT](#SOC-FW-CONTENT-CERT) content certificate.
* TF-A BL32 (OPTEE) has the [TRUSTED-OS-FW-CONTENT-CERT](#TRUSTED-OS-FW-CONTENT-CERT) content certificate.
* TF-A BL33 (u-boot) has the [NON-TRUSTED-FW-CONTENT-CERT](#NON-TRUSTED-FW-CONTENT-CERT) content certificate.

The "signing" process of generating the content certificates is performed as part of the MBL build, and has the following generic procedure:

* When TF-A first builds, TF-A generates a set of "dummy" PKI keying material including ROTPK/ROTPrvK and TBBR certificate chains. 
  This is required so as to reserve space in BL1/BL2 for ROTPK hashes, for example.
* TF-A artifacts are packaged into a FIP image which includes the BL3x boot chain components and associated certificates
  i.e. BL31, BL32, BL33, [TRUSTED-BOOT-FW-CERT](#TRUSTED-BOOT-FW-CERT), [SOC-FW-CONTENT-CERT](#SOC-FW-CONTENT-CERT),  
  [TRUSTED-OS-FW-CONTENT-CERT](#TRUSTED-OS-FW-CONTENT-CERT) and [NON-TRUSTED-FW-CONTENT-CERT](#NON-TRUSTED-FW-CONTENT-CERT). 
    * Boot chain build artifacts are stored in the DEPLOY_IMAGE_DIR directory in the build workspace.
      This includes the FIP image. They are used again later in the signing process.
* A new set of develop keying material is generated for the "Developer Security Domain".
    * The developer security domain has its own ROTPK/ROTPrvK.
    * Some developer keying material will be generated once and used for many different builds e.g. the ROTPK/ROTPrvK 
      will be used for all developer builds. 
    * Developer content certificates will change each time the hash of the associated binary image changes.    
* The auto-generated "dummy" keying material is replaced by the developer keying material.
    * On signing for the first time, the FIP image is updated by deleting the dummy content certificates and adding
      the new developer content certificates. 
* If any of the COMPONENTS change such that the hash of the binary image changes then new contents certificates are generated using 
  the developer ROTPK/ROTPrvK.
    * If BL2 changes then a new [TRUSTED-BOOT-FW-CERT](#TRUSTED-BOOT-FW-CERT) content certificate is generated and updated into the FIP image.
    * If BL31 changes then a new [SOC-FW-CONTENT-CERT](#SOC-FW-CONTENT-CERT) content certificate is generated and updated into the FIP image.
    * If BL32 changes then a new [TRUSTED-OS-FW-CONTENT-CERT](#TRUSTED-OS-FW-CONTENT-CERT) content certificate is generated and updated into the FIP image.
    * If BL33 changes then a new [NON-TRUSTED-FW-CONTENT-CERT](#NON-TRUSTED-FW-CONTENT-CERT) content certificate is generated and updated into the FIP image.

This document describes the process for re-signing binary artifacts with a new set of developer generated keying material.


## <a name="section-1-2"></a> 1.2 Prerequisites

The development machine should have ```openssl``` pre-installed on the machine. This is used to generate new developer keys, for example.


## <a name="section-1-3"></a> 1.3 Terminology

This section defines terminology used throughout this document.

    Acronym             Definition

    AP                  Application Processor
    BL                  Bootloader
    BL1                 1st Stage Boot Loader
    BL2                 2nd Stage Boot Loader
    BL31                3rd Stage Boot Loader - Part 1.
                          - e.g. Secure Monitor running in EL1-SW.
    BL32                3rd Stage Boot Loader - Part 2. 
                          - e.g. OPTEE, the secure world OS.
    BL33                3rd Stage Boot Loader - Part 3.
                          - e.g. u-boot, the Normal World boot loader.
                          - Also referred to as Non-Trusted World Firmware (NT-FW).
    COT                 Chain of Trust
    DEPLOY_DIR          Yocto symbol for the MBL build deploy directory: 
                        <src_root>/build-mbl/tmp-mbl-glibc/deploy
    DEPLOY_DIR_IMAGE    Yocto symbol for the MACHINE specific deploy directory 
                        ${DEPLOY_DIR}/images/${MACHINE}/
    DTB                 Device Tree Binary
    EL0-NW              Execution Level 0 - Normal World. 
                          - Lowest privilege level, non-secure, e.g. for Linux applications.
    EL0-SW              Execution Level 0 - Secure World. 
                          - Lowest privilege level, secure, e.g. for trusted applications.
    EL1-NW              Execution Level 1 - Normal World. 
    EL1-SW              Execution Level 1 - Secure World. 
    EL2-NW              Execution Level 2 - Normal World
    EL2-SW              Execution Level 2 - Secure World
    EL3-NW              Execution Level 3 - Normal World. Highest privilege
    EL3-SW              Execution Level 3 - Secure World. 
                          - Highest privilege level, secure, e.g. for BL1 bootROM, Secure Monitor.
    FIP                 Firmware Image Package. This is a "simple filesystem" for 
                        managing signed bootchain components.
    FIT                 Flat Image Tree. This is a Linux Kernel image container for 
                        holding the kernel, kernel DTB abd initramfs.
    MBL                 mbed Linux OS
    NT                  Non-Trusted
    NT-FW               Non-Trusted Firmware Binary (TF-A fiptool) 
                          - e.g. BL33 u-boot. Runs at EL2-NW
    NT-FW-CERT          Non-Trusted Firmware Certificate (TF-A fiptool) 
                          - e.g. u-boot content certificate.
    NT-FW-KEY-CERT      Non-Trusted Firmware Certificate (TF-A fiptool)
    NW                  Normal World (TrustZone)
    SW                  Secure World (TrustZone)
    SOC-FW              System-On-Chip Firmware Binary (TF-A fiptool)
    SOC-FW-CERT         System-On-Chip Firmware Certificate (TF-A fiptool)
    SOC-FW-KEY-CERT     System-On-Chip Firmware Key Certificate (TF-A fiptool)
    
    ROTPK               Root of Trust Public Key
    ROTPrvK             Root of Trust Private Key
    TBBR                Trusted Board Boot Requirements
    TBBR-CLIENT         TBBR Specification document
    TB-FW               Trusted Board Firmware Binary (TF-A fiptool)
    TB-FW-CERT          Trusted Board Firmware Certificate (TF-A fiptool)
    TB-FW-KEY-CERT      Trusted Board Firmware Key Certificate (TF-A fiptool)
    TF-A                Trusted Firmware for Cortex-A
    TOS-FW              Trusted OS Firmware Binary (TF-A fiptool)
    TOS-FW-CERT         Trusted OS Firmware Certificate (TF-A fiptool)
    TOS-FW-EXTRA1       Trusted OS Firmware Extra-1 Binary (TF-A fiptool)
    TOS-FW-EXTRA2       Trusted OS Firmware Extra-2 Binary (TF-A fiptool)
    TOS-FW-KEY-CERT     Trusted OS Firmware Key Certificate (TF-A fiptool)
    TRUSTED-KEY-CERT    Trusted Key Certificate.
                          - Contains the trusted world public key.
                          - Contains the non-trusted world public key.
    
**Table 1: Acronyms.**
    
      


## <a name="section-2-0"></a> 2.0 The Secure Boot Chain and Signing Components

This section describes the secure boot chain.


## <a name="section-2-1"></a> 2.1 The Generic TF-A Secure Boot Chain

    BLx     Definition              TBBR-Client Term          MBL           `fiptool` option
    ----------------------------------------------------------------------------------------

    BL1     1st Stage Bootloader    BootROM                       
    BL2     2nd Stage Bootloader    Trusted Boot Firmware                   `--tb-fw`ss
    BL31    3rd Stage Part 1 BL     SoC AP Firmware         Secure Monitor  `--soc-fw`
    BL32    3rd Stage Part 2 BL     Secure Payload          OPTEE           `--tos-fw`
    BL33    3rd Stage Part 3 BL     Normal World Firmware   u-boot          `--nt-fw`

<a name="table1"></a>
**Table 1: Terminology Normalisation.**


Logically, a secure boot chain consists of N Boot-Loaders (BL) where (in general terms) the chain is formed by the 
boot-loaders running in order i.e. BL1, BL2, BL3, ... BLN-1. [Table 1](#table1) introduces these terms and how they
map to the TBBR-Client secure boot reference specification (see TBBR-Client in the [References section](#section-4-0)).

In [Table 1](#table1):

* Column 1 is the BLx acronym for the boot-loader stage. These 
  acronyms are used throughout this document to introduce the logical structure of the bootchain functionality
  because it's easy to remember that BL1 comes before BL2 etc., and BL1 is the first component that runs after
  power is reset.
* Column 2 provides a definition of the BLx acronym.
* Column 3 gives the equivalent term used in the TBBR-Client specification.
* Column 4 gives the mbed Linux OS selected software component to fulfill the BLx role at runtime (i.e. after the bootchain has brought up the system, some of the authenticated components continue running in the system).
* Column 5 provides the `fiptool/cert_create` TF-A tool option for referencing the particular bootchain component in the FIP image or certificate creation process. These tools will be discussed in more detail later.

<a name="fig1"></a>
![fig1](assets/LAS16-402_slide_15.png "Figure 1")
**Figure 1: Linaro Connect 2016 Presentation LAS16-402 [slide 15][linaro-connect-las16-402-slides] showing AArch64 secure boot process.**

        
[Figure 1](#fig1) shows the Cortex-v8A AArch64 generic secure boot process which is the starting point for discussing the RPI3 secure boot.

* The first column shows the software components that execute from secure ROM.
* The second column shows the software components that execute from secure on-chip RAM.
* The third column shows the software components that execute from secure RAM, which may be on or off the SoC.
* The forth column shows the software components that execute from insecure DRAM, which is off-chip.
* After power on reset, the first component to run is the AP bootROM, also known as the first stage boot loader BL1 (shown as AP\_BL1 figure).
    * BL1 executes at the EL3-SW execution level and is known as the BootROM in the TBBR-Client specification (see [Table 1](#table1) row 1).
    * BL1 loads the second stage bootloader BL2 into secure on-chip RAM (wide arrow, BL2 is denoted AP\_BL2 in the figure).
    * BL1 authenticates BL2.
    * If BL2 is successfully authenticated then BL1 runs BL2 (thin black arrow).
* BL2 orchestrates the loading and running of the third stage bootloader components:
    * BL2 executes at the EL1-SW execution level and is known as the Trusted Boot Firmware in the TBBR-Client specification (see [Table 1](#table1) row 2).
    * BL2 loads the third stage bootloader BL31 into secure on-chip RAM. BL31 is known as "SoC AP Firmware" in the TBBR-CLIENT specification. In MBL this is the TF-A Secure Monitor. 
    * BL2 authenticates BL31. If BL31 fails authentications then the secure boot stops (recovery mode may be entered).
    * BL2 loads the third stage bootloader BL32 into secure on-chip RAM. BL32 is known as the "Secure Payload" in the TBBR-CLIENT specification. In MBL this is OPTEE.
    * BL2 authenticates BL32. If BL32 fails authentications then the secure boot stops (recovery mode may be entered).
    * BL2 loads the third stage bootloader BL33 into secure on-chip RAM. BL33 is known as the "Normal World Firmware" in the TBBR-CLIENT specification. In MBL this is u-boot.
    * BL2 authenticates BL33. If BL33 fails authentications then the secure boot stops (recovery mode may be entered).
    * BL2 runs BL31.
* BL31 runs BL32 and then blocks waiting for BL32 to complete initialisation. 
    * BL31 executes at the EL3-SW execution level and is known as the Soc AP Firmware in the TBBR-Client specification (see [Table 1](#table1) row 3).
    * BL31 is also known as the Secure Monitor.
* BL32 (Secure Payload, OPTEE) runs and initialises. 
    * BL32 executes at the EL1-SW execution level and is known as the Secure Payload in the TBBR-Client specification (see [Table 1](#table1) row 4).
    * When initialisation is complete, it makes an "External Hand-Off API call" so BL31 (Secure Monitor) will to continue with secure boot chain processing. 
      BL32 continues to run in the system.
* BL31 (SoC AP Firmware, Secure Monitor) resumes and runs BL33 (Normal World Firmware, u-boot). BL31 continues to run in the system.
* BL33 orchestrates the loading and running of the Rich OS.
    * BL33 executes at the EL2-NW execution level and is known as the Normal World Firmware in the TBBR-Client specification (see [Table 1](#table1) row 5).
    * BL33 in MBL is u-boot.
    * BL33 loads the Linux kernel kernel into memory. 
    * BL33 authenticates the Linux kernel. If authentication fails then the secure boot stops (recovery mode may be entered).
    * BL33 loads the Linux kernel initramfs into memory. 
    * BL33 authenticates the Linux initramfs. If authentication fails then the secure boot stops (recovery mode may be entered).
    * BL33 loads the Linux kernel DTB into memory. 
    * BL33 authenticates the Linux DTB. If authentication fails then the secure boot stops (recovery mode may be entered).
    * BL33 runs the Linux kernel kernel. 
* The secure boot chain process has now completed.


## <a name="section-2-2"></a> 2.2 The RPI3 boot chain

The RPI3 boot chain differs from the generic TF-A secure boot chain in the following ways:

* The RPI3+ uses a Broadcom BCM2837B0 SoC with a 1.4 GHz 64-bit quad-core ARM Cortex-A53 processor and a VideoCore IV GPU. 
* A bootROM (BL0) runs on the GPU but does not use the TF-A BL1 code. BL0 implements RPI3 specific processing logic which loads `armstub8.bin` into memory if `armstub8.bin` 
  is present on the SDCard boot partition.
* The RPI3 is not secure. 
    * The BCM2837B0 SoC fabric has not wired up the ARM Trustzone Secure-World/Non-Secure-World address line, and therefore it's always
      possible for a DMA engine to read RAM configured as secure memory.
    * The GPU sets the A53 into ELx-NW before running `armstub8.bin` i.e. the system is not in a secure state when the first programmable boot chain component runs.
* `armstub8.bin` includes a "normalisation" version of BL1 which authenticate BL2. BL1 therefore contains a ROTPK hash which is used as part of the authentication process. The benefit of including BL1
   is that the RPI3 bootchain is thereby identical to the generic TF-A bootchain from BL2 onwards.


## <a name="section-2-3"></a> 2.3 The TBBR chain of trust

<a name="fig2"></a>
![fig2](assets/tbbr_cot_2.png "Figure 1")
**Figure 2: TBBR chain of trust certificate chains used by the secure boot components.**

[Figure 2](#fig2) shows the TBBR certificate chains as specified in the TBBR specification. The entities relevant to the discussion in this document are described below:

* ROTPK. This is a key certificate containing the ROTPK (ROT public key). 
    * The associated private key is used to sign the following certificates:
        * [TRUSTED-KEY-CERT](#TRUSTED-KEY-CERT).
        * [TRUSTED-BOOT-FW-CERT](#TRUSTED-BOOT-FW-CERT).
    * A ROTPK hash is embedded in the RPI3 BL1 and BL2 images.
* <a name="TRUSTED-KEY-CERT"></a> TRUSTED-KEY-CERT. 
    * This contains the trusted world signing public key `trusted_world_pk` for authenticating certificates chains of trusted world components. 
      The associated private key is used to sign the following certificates:
        * [TRUSTED-OS-FW-KEY-CERT](#TRUSTED-OS-FW-KEY-CERT).
        * [SOC-FW-KEY-CERT](#SOC-FW-KEY-CERT).
    * This certificate also contains the non-trusted world public signing key `non_trusted_world_pk`. The associated private key is used to sign the following certificates for non-trusted world components:
        * NON-TRUSTED-FW-KEY-CERT.
    * This certificate is present in the FIP image. `fiptool` refers to this FIP image component using the [`--trusted-key-cert`](#fiptool-help) option.
    * This certificate is signed by the ROT private key.
* <a name="TRUSTED-BOOT-FW-CERT"></a> TRUSTED-BOOT-FW-CERT. 
    * This is the content certificate for the trusted-world Trusted Boot Firmware (i.e. BL2). The content certificate contains the BL2 hash used to authenticate the image.
    * This certificate is signed by the ROTPrvK.
    * This certificate is present in the FIP image. `fiptool` refers to this FIP image component using the [`--tb-fw-cert`](#fiptool-help) option.
* <a name="TRUSTED-OS-FW-KEY-CERT"></a> TRUSTED-OS-FW-KEY-CERT.
    * This is the key certificate for the trusted-world Trusted OS Firmware (i.e. BL32, OPTEE). It contains the public key of the PKI key pair used to sign the BL32 certificate chain e.g. TRUSTED-OS-FW-CONTENT-CERT.
    * This certificate is signed by the trusted world private key `trusted_world_pk`.
    * This certificate is present in the FIP image. `fiptool` refers to this FIP image component using the [`--tos-fw-key-cert`](#fiptool-help) option.
* <a name="SOC-FW-KEY-CERT"></a> SOC-FW-KEY-CERT
    * This is the key certificate for the trusted-world SoC AP Firmware (i.e. BL31, Secure Monitor). It contains the public key of the PKI key pair used to sign the BL31 certificate chain e.g. SOC-FW-CONTENT-CERT.
    * This certificate is signed by the ROT private key.
    * This certificate is present in the FIP image. `fiptool` refers to this FIP image component using the [`--soc-fw-key-cert`](#fiptool-help) option.
* NON-TRUSTED-FW-KEY-CERT.
    * This is the key certificate for the non-trusted-world Normal World Firmware (i.e. BL33, u-boot). It contains the public key of the PKI key pair used to sign the BL33 certificate chain e.g. NON-TRUSTED-OS-FW-CONTENT-CERT.
    * This certificate is signed by the non-trusted-world private key `non_trusted_world_pk`.
    * This certificate is present in the FIP image. `fiptool` refers to this FIP image component using the [`--nt-fw-key-cert`](#fiptool-help) option.
* <a name="TRUSTED-OS-FW-CONTENT-CERT"></a> TRUSTED-OS-FW-CONTENT-CERT.
    * This is the content certificate for the trusted-world Trusted OS Firmware (i.e. BL32, OPTEE). The content certificate contains the BL32 hash used to authenticate the image.
    * This certificate is signed by the private key associated with the public key in TRUSTED-OS-FW-KEY-CERT.
    * This certificate is present in the FIP image. `fiptool` refers to this FIP image component using the [`--tos-fw-cert`](#fiptool-help) option.
* <a name="SOC-FW-CONTENT-CERT"></a> SOC-FW-CONTENT-CERT.
    * This is the content certificate for the trusted-world SoC AP Firmware (i.e. BL31, Secure Monitor). The content certificate contains the BL31 hash used to authenticate the image.
    * This certificate is signed by the private key associated with the public key in SOC-FW-KEY-CERT.
    * This certificate is present in the FIP image. `fiptool` refers to this FIP image component using the [`--soc-fw-cert`](#fiptool-help) option.
* <a name="NON-TRUSTED-FW-CONTENT-CERT"></a> NON-TRUSTED-FW-CONTENT-CERT.
    * This is the content certificate for the non-trusted-world Normal World Firmware (i.e. BL33, u-boot). The content certificate contains the BL33 hash used to authenticate the image.
    * This certificate is signed by the private key associated with the public key in NON-TRUSTED-FW-KEY-CERT.
    * This certificate is present in the FIP image. `fiptool` refers to this FIP image component using the [`--nt-fw-cert`](#fiptool-help) option.


## <a name="section-2-4"></a> 2.4 BL1, BL2, FIP and FIT image composition


    BL1 Image
    -----------------
    |   ----------  |
    |   | ROTPK  |  |
    |   ----------  |
    -----------------

    BL2 Image
    -----------------
    |   ----------  |
    |   | ROTPK  |  |
    |   ----------  |
    -----------------

    FIP Image (Bank i)
    -------------------------------------------------------------
    |   ---------------------------------------------------     |
    |   | BL31 - Secure Monitor                           |     |
    |   ---------------------------------------------------     |
    |   ---------------------------------------------------     |
    |   | BL32 - OPTEE                                    |     |
    |   ---------------------------------------------------     |
    |   ---------------------------------------------------     |
    |   | BL33 - u-boot                                   |     |
    |   ---------------------------------------------------     |
    |   ---------------------------------------------------     |
    |   | Trusted Key Certificate (TRUSTED-KEY-CERT)|     |     |
    |   ---------------------------------------------------     |
    |   ---------------------------------------------------     |
    |   | BL31 Key Cert (SOC-FW-KEY-CERT)                 |     |
    |   ---------------------------------------------------     |
    |   ---------------------------------------------------     |
    |   | BL32 Key Cert (TRUSTED-OS-FW-KEY-CERT)          |     |
    |   ---------------------------------------------------     |
    |   ---------------------------------------------------     |
    |   | BL33 Key Cert (NON-TRUSTED-FW-KEY-CERT)         |     |
    |   ---------------------------------------------------     |
    |   ---------------------------------------------------     |
    |   | BL31 Content Cert (SOC-FW-CONTENT-CERT)         |     |
    |   ---------------------------------------------------     |
    |   ---------------------------------------------------     |
    |   | BL32 Content Cert (TRUSTED-OS-FW-CONTECT-CERT)  |     |
    |   ---------------------------------------------------     |
    |   ---------------------------------------------------     |
    |   | BL33 Content Cert (NON-TRUSTED-FW-CONTENT-CERT) |     |
    |   ---------------------------------------------------     |
    -------------------------------------------------------------
    

    FIT Image
    ------------------------------------
    |   --------------------------     |
    |   | zImage (Linux kernel)  |     |
    |   --------------------------     |    
    |   --------------------------     |
    |   | initramfs              |     |
    |   --------------------------     |
    |   --------------------------     |
    |   | Kernel DTB             |     |
    |   --------------------------     |
    |   --------------------------     |
    |   | boot.cmd               |     |
    |   --------------------------     |
    ------------------------------------
    
<a name="fig3_ascii_art_bl1_bl2_fip_fit_components"></a>
**Figure 3: Physical Artefacts in the Boot Chain.**
    
[Figure 3](#fig3) shows the composition of the secure boot chain components:

* BL1. This contains a ROTPK hash so BL1 can authenticate BL2.
* FIP Image. This is a very simple filesystem-like container of the BL3x boot chain components and associated certificates. 
  The [`fiptool`](#fiptool) is used to create and manage the image, adding, updating and removing components.
    * BL31 - Secure Monitor. 
        * `fiptool` refers to this FIP image component using the [`--soc-fw`](#fiptool-help) option.
    * BL32 - OPTEE.
        * `fiptool` refers to this FIP image component using the [`--tos-fw`](#fiptool-help) option.
    * BL33 - u-boot.
        * `fiptool` refers to this FIP image component using the [`--nt-fw`](#fiptool-help) option.
    * Trusted Key Certificate ([TRUSTED-KEY-CERT](#TRUSTED-KEY-CERT)).
        * `fiptool` refers to this FIP image component using the [`--trusted-key-cert`](#fiptool-help) option.
    * BL31 Key Cert (SOC-FW-KEY-CERT).
        * `fiptool` refers to this FIP image component using the [`--soc-fw-key-cert`](#fiptool-help) option.
    * BL32 Key Cert (TRUSTED-OS-FW-KEY-CERT).
        * `fiptool` refers to this FIP image component using the [`--tos-fw-key-cert`](#fiptool-help) option.
    * BL33 Key Cert (NON-TRUSTED-FW-KEY-CERT).
        * `fiptool` refers to this FIP image component using the [`--nt-fw-key-cert`](#fiptool-help) option.
    * BL31 Content Cert (SOC-FW-CONTENT-CERT).
        * `fiptool` refers to this FIP image component using the [`--soc-fw-cert`](#fiptool-help) option.
    * BL32 Content Cert (TRUSTED-FW-CONTENT-CERT).
        * `fiptool` refers to this FIP image component using the [`--tos-fw-cert`](#fiptool-help) option.
    * BL33 Content Cert (NON-TRUSTED-FW-KEY-CERT).
        * `fiptool` refers to this FIP image component using the [`--nt-fw-cert`](#fiptool-help) option.
* FIT Image.
    * zImage. This is the Linux Kernel.
    * initramfs. This is the Linux Kernel initial file system which is loaded into RAM.
    * Kernel DTB. This is the Device Tree Binary used to describe the kernel device configuration.
    * boot.cmd. This is the u-boot boot command file which controls the u-boot behaviour for 
      loading the Linux Kernel.
    
        
## <a name="section-3-0"></a> 3.0 Re-signing RPI3 BL1/BL2/FIP images with a new developer ROTPrvK
        
This section describes how to re-sign the RPI3 BL1/BL2/FIP images with a new developer ROTPrvK. An overview of the re-signing process is described below:

1. A new developer ROTPrvK is generated.
1. The BL1 and FIP image are unpacked from the RPI3 `armstub8.bin`. The FIP image components are then unpacked.
1. BL1 and BL2 are patched with the new develoepr ROTPK hash. This means all the certificates have to be regenerated because the new ROTPK is at the root of all the TBBR certicate chains.
1. New certificate chains are generated for all the components using the new developer ROTPK/ROTPrvK.
1. A new FIP is created with the new certificate chains and BL2.
1. A new `armstub8.bin` is created with the new BL1 and FIP.

The above proceedure is currently accomplished by manually working through the following steps. In time, the process will be automated to be part of the MBL build.

* [Step 3.1:](#section-3-1) Get the re-signing scripts. 
    * These are used to patch the ROTPK hashes in BL1 and BL2 for example.
* [Step 3.2:](#section-3-2) Build the ATF ```fiptool```. 
    * This is used to unpack the old FIP image, and create the new one.
* [Step 3.3:](#section-3-3) Build the ATF ```cert_create``` tool. 
    * This is used by the re-signing scripts to create the certificate chains for the new ROTPK.
* [Step 3.4:](#section-3-4) Unpack ```armstub8.bin``` and ```fip.bin```. 
* [Step 3.5:](#section-3-5) Generate a new developer ROTPK/ROTPrvK pair.
* [Step 3.6:](#section-3-6) Generate new developer ROTPK hash.
* [Step 3.7:](#section-3-7) Patch BL1 image with the new developer ROTPK hash. 
    * This replaces the old ROTPK hash in bl1.bin (BL1 image) with the hash of the new ROTPK generated in the previous step.
* [Step 3.8:](#section-3-8) Patch BL2 image with the new developer ROTPK hash
    * This replaces the old ROTPK hash in tw-fw.bin (BL2 Image) with the hash of the new ROTPK.
* [Step 3.9:](#section-3-9) Regenerate armstub8.bin with new developer ROTPK.
* [Step 3.10:](#section-3-10) Boot the new armstub8.bin.


## <a name="section-3-1"></a> 3.1: Get the re-signing scripts

The re-signing scripts are stored in the rpi3-cst git repository https://gitlab.com/grandpaul/rpi3-cst. Get a local copy of these tools by cloning the git repository:

    user@machine:/data/2284/test/to_delete/20181018/pr239$ git clone https://gitlab.com/grandpaul/rpi3-cst
    Cloning into 'rpi3-cst'...
    remote: Enumerating objects: 6, done.
    remote: Counting objects: 100% (6/6), done.
    remote: Compressing objects: 100% (6/6), done.
    remote: Total 6 (delta 1), reused 0 (delta 0)
    Unpacking objects: 100% (6/6), done.
    Checking connectivity... done.

This is a listing of the tools in the rpi3-cst repository:

    -rwxrwxr-x 1 user-007 user-007 4672 Oct 18 14:19 hack_bl1_rothash.py*
    -rw-rw-r-- 1 user-007 user-007 3277 Oct 18 14:19 README.md
    -rwxrwxr-x 1 user-007 user-007 1927 Oct 18 14:19 split_rpi3_bl1_fip.sh*
    -rwxrwxr-x 1 user-007 user-007 6946 Oct 18 14:19 update_bl3x.sh*

The rpi3-cst scripts listed above have the following function:

1. `split_rpi3_bl1_fip.sh`: This script splits `armstub8.bin` into the BL1 `bl1.bin` and FIP image `fip.bin`.
1. `update_bl3x.sh`: This script updates BL32 (OPTEE) and/or BL33 (U-boot) in armstub8.bin to use patched version of BL1/BL2, for example. 
1. `hack_bl1_rothash.py`: This script replaces the ROTPK hash in `bl1.bin` or `tf-fw.bin` (BL2) with a new hash value (for a new ROTPK).
1. `hack_bl1_rothash.py`: This script replaces the ROTPK hash in `bl1.bin` or `tf-fw.bin` (BL2) with a new hash value (for a new ROTPK).

These scripts should be made available on the PATH by adding the rpi3-cst directory to the PATH and exporting into the environment:

    export PATH=`pwd`/rpi3-cst:$PATH
    

## <a name="section-3-2"></a> <a name="fiptool"></a> 3.2: Build the ATF fiptool

The instructions for building the fiptool are available in the [ATF user guide][atf-user-guide-fiptool]. In summary:

1. Get the Linaro GCC AArch64 toolchain tarball binary for linaro-gcc-linaro-7.2.1 from [Linaro Releases][linaro-gcc-linaro-7.2.1].
1. Extract it to somewhere sensible on your devhost e.g.: ```/opt/linaro/```
1. Put the Linaro GCC AArch64 toolchain on the path:

    ```export PATH=/opt/linaro/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin:$PATH```
    
1. Get a clone of the arm-trusted-firmware repo:

	```git clone https://github.com/ARM-software/arm-trusted-firmware.git```
	 
1. Move into the top level ATF directory ```arm-trusted-firmware``` and build the ```fiptool``` as follows: 

    ```make [DEBUG=1] [V=1] fiptool```
    
   On a successful build, ```fiptool``` will be in ```arm-trusted-firmware/tool/fiptool```.
   
1. Make ```fiptool``` available on the PATH:

    ```export PATH=`pwd`/tool/fiptool:$PATH```


<a name="fiptool-help"></a> 
For reference, the ```fiptool``` help is shown below.

    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ fiptool -h
    ../fiptool: invalid option -- 'h'
    usage: fiptool [--verbose] <command> [<args>]
    Global options supported:
      --verbose	Enable verbose output for all commands.
    Commands supported:
      info	List images contained in FIP.
      create	Create a new FIP with the given images.
      update	Update an existing FIP with the given images.
      unpack	Unpack images from FIP.
      remove	Remove images from FIP.
      version	Show fiptool version.
      help	Show help for given command.
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ ../fiptool unpack -h
    unpack: invalid option -- 'h'
    fiptool unpack [opts] FIP_FILENAME
    Options:
      --blob uuid=...,file=...	Unpack an image with the given UUID to file.
      --force	If the output file already exists, use --force to overwrite it.
      --out path	Set the output directory path.
    Specific images are unpacked with the following options:
      --scp-fwu-cfg      FILENAME	SCP Firmware Updater Configuration FWU SCP_BL2U
      --ap-fwu-cfg       FILENAME	AP Firmware Updater Configuration BL2U
      --fwu              FILENAME	Firmware Updater NS_BL2U
      --fwu-cert         FILENAME	Non-Trusted Firmware Updater certificate
      --tb-fw            FILENAME	Trusted Boot Firmware BL2
      --scp-fw           FILENAME	SCP Firmware SCP_BL2
      --soc-fw           FILENAME	EL3 Runtime Firmware BL31
      --tos-fw           FILENAME	Secure Payload BL32 (Trusted OS)
      --tos-fw-extra1    FILENAME	Secure Payload BL32 Extra1 (Trusted OS Extra1)
      --tos-fw-extra2    FILENAME	Secure Payload BL32 Extra2 (Trusted OS Extra2)
      --nt-fw            FILENAME	Non-Trusted Firmware BL33
      --hw-config        FILENAME	HW_CONFIG
      --tb-fw-config     FILENAME	TB_FW_CONFIG
      --soc-fw-config    FILENAME	SOC_FW_CONFIG
      --tos-fw-config    FILENAME	TOS_FW_CONFIG
      --nt-fw-config     FILENAME	NT_FW_CONFIG
      --rot-cert         FILENAME	Root Of Trust key certificate
      --trusted-key-cert FILENAME	Trusted key certificate
      --scp-fw-key-cert  FILENAME	SCP Firmware key certificate
      --soc-fw-key-cert  FILENAME	SoC Firmware key certificate
      --tos-fw-key-cert  FILENAME	Trusted OS Firmware key certificate
      --nt-fw-key-cert   FILENAME	Non-Trusted Firmware key certificate
      --tb-fw-cert       FILENAME	Trusted Boot Firmware BL2 certificate
      --scp-fw-cert      FILENAME	SCP Firmware content certificate
      --soc-fw-cert      FILENAME	SoC Firmware content certificate
      --tos-fw-cert      FILENAME	Trusted OS Firmware content certificate
      --nt-fw-cert       FILENAME	Non-Trusted Firmware content certificate


Note the ```fiptool``` help output uses the TBBR terminology. 
      
## <a name="section-3-3"></a> 3.3: Build the ATF cert_create tool

The instructions for building the cert_create are available in the [ATF user guide][atf-user-guide-cert-create-tool] section for building the certificate generation tool. In summary:

1. Make the `cert_create` tool by using the following command in the top level of the arm-trusted-firmware directory created in the previous section:

	make PLAT=rpi3 USE_TBBR_DEFS=1 [DEBUG=1] [V=1] certtool

1. The `cert_create` should be made available on the PATH as follows:

    export PATH=`pwd`/tool/cert_create:$PATH
    
The name of the tool is `cert_create` rather than `certtool` as the name of the make target might imply.

For reference, the ```cert_create``` help is shown below.

    ./cert_create/cert_create -h
    NOTICE:  CoT Generation Tool: Built : 15:46:24, Aug 31 2018
    NOTICE:  Target platform: TBBR Generic


    The certificate generation tool loads the binary images and
    optionally the RSA keys, and outputs the key and content
    certificates properly signed to implement the chain of trust.
    If keys are provided, they must be in PEM format.
    Certificates are generated in DER format.

    Usage:
        ./cert_create/cert_create [OPTIONS]

    Available options:
        -h,--help                        Print this message and exit
        -a,--key-alg <arg>               Key algorithm: 'rsa' (default) - RSAPSS scheme as per PKCS#1 v2.1, 'rsa_1_5' - RSA PKCS#1 v1.5, 'ecdsa'
        -s,--hash-alg <arg>              Hash algorithm : 'sha256' (default), 'sha384', 'sha512'
        -k,--save-keys                   Save key pairs into files. Filenames must be provided
        -n,--new-keys                    Generate new key pairs if no key files are provided
        -p,--print-cert                  Print the certificates in the standard output
        --tb-fw-cert <arg>               Trusted Boot FW Certificate (output file)
        --trusted-key-cert <arg>         Trusted Key Certificate (output file)
        --scp-fw-key-cert <arg>          SCP Firmware Key Certificate (output file)
        --scp-fw-cert <arg>              SCP Firmware Content Certificate (output file)
        --soc-fw-key-cert <arg>          SoC Firmware Key Certificate (output file)
        --soc-fw-cert <arg>              SoC Firmware Content Certificate (output file)
        --tos-fw-key-cert <arg>          Trusted OS Firmware Key Certificate (output file)
        --tos-fw-cert <arg>              Trusted OS Firmware Content Certificate (output file)
        --nt-fw-key-cert <arg>           Non-Trusted Firmware Key Certificate (output file)
        --nt-fw-cert <arg>               Non-Trusted Firmware Content Certificate (output file)
        --fwu-cert <arg>                 Firmware Update Certificate (output file)
        --rot-key <arg>                  Root Of Trust key (input/output file)
        --trusted-world-key <arg>        Trusted World key (input/output file)
        --non-trusted-world-key <arg>    Non Trusted World key (input/output file)
        --scp-fw-key <arg>               SCP Firmware Content Certificate key (input/output file)
        --soc-fw-key <arg>               SoC Firmware Content Certificate key (input/output file)
        --tos-fw-key <arg>               Trusted OS Firmware Content Certificate key (input/output file)
        --nt-fw-key <arg>                Non Trusted Firmware Content Certificate key (input/output file)
        --tfw-nvctr <arg>                Trusted Firmware Non-Volatile counter value
        --ntfw-nvctr <arg>               Non-Trusted Firmware Non-Volatile counter value
        --tb-fw <arg>                    Trusted Boot Firmware image file
        --tb-fw-config <arg>             Trusted Boot Firmware Config file
        --hw-config <arg>                HW Config file
        --scp-fw <arg>                   SCP Firmware image file
        --soc-fw <arg>                   SoC AP Firmware image file
        --tos-fw <arg>                   Trusted OS image file
        --tos-fw-extra1 <arg>            Trusted OS Extra1 image file
        --tos-fw-extra2 <arg>            Trusted OS Extra2 image file
        --nt-fw <arg>                    Non-Trusted World Bootloader image file
        --scp-fwu-cfg <arg>              SCP Firmware Update Config image file
        --ap-fwu-cfg <arg>               AP Firmware Update Config image file
        --fwu <arg>                      Firmware Updater image file

Note the ```fiptool``` help output uses the TBBR terminology. 


## <a name="section-3-4"></a> 3.4: Unpack armstub8.bin and fip.bin

Create the ```work``` subdirectory and copy the ```armstub8.bin``` from the ```DEPLOY_DIR_IMAGE``` into it:

    user@machine:/data/2284/test/to_delete/20181018/pr239$ mkdir work
    user@machine:/data/2284/test/to_delete/20181018/pr239$ pushd work
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ cp ${DEPLOY_DIR_IMAGE}/armstub8.bin .
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ ll

    -rw-r--r-- 1 user-007 user-007 1016508 Oct 18 14:20 armstub8.bin


Split the ```armstub8.bin``` into ```bl1.bin``` and ```fip.bin``` using the ```rpi3-cst``` ```split_rpi3_bl1_fip.sh``` script:

    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ split_rpi3_bl1_fip.sh --bl1 bl1.bin --fip fip.bin armstub8.bin 
    131072+0 records in
    131072+0 records out
    131072 bytes (131 kB, 128 KiB) copied, 0.255076 s, 514 kB/s
    ll885436+0 records in
    885436+0 records out
    885436 bytes (885 kB, 865 KiB) copied, 1.20543 s, 735 kB/s
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ ll
    total 2000
    drwxrwxr-x 2 user-007 user-007    4096 Oct 18 14:21 ./
    drwxrwxr-x 4 user-007 user-007    4096 Oct 18 14:20 ../
    -rw-r--r-- 1 user-007 user-007 1016508 Oct 18 14:20 armstub8.bin
    -rw-rw-r-- 1 user-007 user-007  131072 Oct 18 14:21 bl1.bin
    -rw-rw-r-- 1 user-007 user-007  885436 Oct 18 14:21 fip.bin
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ 

    
Make the ```fip_components``` subdirectory and unpack the ```fip.bin``` components into ```fip_components```:

    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ mkdir fip_components
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ fiptool unpack fip.bin --out fip_components 

The ```fip_components``` subdirectory now contains the following:

    -rw-rw-r-- 1 user-007 user-007 428904 Oct 18 14:31 nt-fw.bin
    -rw-rw-r-- 1 user-007 user-007   1088 Oct 18 14:31 nt-fw-cert.bin
    -rw-rw-r-- 1 user-007 user-007   1258 Oct 18 14:31 nt-fw-key-cert.bin
    -rw-rw-r-- 1 user-007 user-007  28793 Oct 18 14:31 soc-fw.bin
    -rw-rw-r-- 1 user-007 user-007   1072 Oct 18 14:31 soc-fw-cert.bin
    -rw-rw-r-- 1 user-007 user-007   1242 Oct 18 14:31 soc-fw-key-cert.bin
    -rw-rw-r-- 1 user-007 user-007  75248 Oct 18 14:31 tb-fw.bin
    -rw-rw-r-- 1 user-007 user-007   1135 Oct 18 14:31 tb-fw-cert.bin
    -rw-rw-r-- 1 user-007 user-007     28 Oct 18 14:31 tos-fw.bin
    -rw-rw-r-- 1 user-007 user-007   1230 Oct 18 14:31 tos-fw-cert.bin
    -rw-rw-r-- 1 user-007 user-007 342016 Oct 18 14:31 tos-fw-extra1.bin
    -rw-rw-r-- 1 user-007 user-007      0 Oct 18 14:31 tos-fw-extra2.bin
    -rw-rw-r-- 1 user-007 user-007   1256 Oct 18 14:31 tos-fw-key-cert.bin
    -rw-rw-r-- 1 user-007 user-007   1550 Oct 18 14:31 trusted-key-cert.bin

Use the ```fiptool``` [help command output](#section-3-2) and the [Terminology](#section-1-3) section to understand how the  above ```.bin``` files map to entities in boot chain.

    
## <a name="section-3-5"></a> 3.5 Generate new ROTPK/ROTPrvK (public/private) key pair

First, generate a new ROT key pair (which will is stored in the file rot_key.pem in the new_keys subdirectory:

    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ mkdir new_keys
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ openssl genrsa 2048 > new_keys/rot_key.pem
    Generating RSA private key, 2048 bit long modulus
    ......................+++
    ......+++
    e is 65537 (0x10001)
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$

The ```rot_key.pem``` contains the ROT private key:

    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ cat new_keys/rot_key.pem
    -----BEGIN RSA PRIVATE KEY-----
    MIIEogIBAAKCAQEAl2CBtdfXemzZ4vSK1sosdybUC0Kuk+7pTLzIXQK2WnruM9gF
    jQfoFpbFaAoIERgsZT71fyBBYmG7lvLvsnVcM7MTK2gLujJ4k+Q+u30UqnVUPX1r
    1SydIpn/wMtVIgZ89siKOL4MU245w99SBKVCkKHjMayXIInV0Duit6DTdiG8PwjZ
    BcrC+agNRJXBJ0wiwLRw51LyeSSSCh2Abt4OG2FymZSFJiWo3b0KQxgdxnYjAfGw
    wvaKmXiqNRtrG/YCHUka5QSKciZHTBhYm8KSIt5LHUjM7/lJe9IbE5gHmALOZtDw
    gyl3cafKZ+rmHDL1X94OjnGppWMfkwdbVbj3WwIDAQABAoIBAFRm9curLjTPjmkx
    ylvaXBKPbrlck7ReCGzF8b2SbpRiaIA1mVq6Jti5dhX9SeQmI1LMWNtp46r0LUEL
    8UQClccpuK2CFM/bpklngObO5f/o7XBfhwlUF8UcMnKPrMcM8Q40YIUkygCWu9SP
    ps56SnQUH3Yp8hWtZK73IVHbdSwu5Zz3/48pNzvzuBM8BFZQmyYGM6sq9kMamTAC
    hmHjUKCqpaOFIbE0GezX2smdssdcinljgevpi6CSunLi0UiPUJGgzyFRIKuX9su4
    thaDJaHRMzR2iCleE/tiFW8abZU/RM2g9hkCGb8pP07iPdgHd8enUe75AYJ58wpy
    x0obFIECgYEAxh2h2RhfkRMTsutuyYAlY5Ytqgc5ZII32axy82wEh65XU6xXyl9e
    sc3t2C35bgiWZMo58zERkRzw6r2TiRaGsGLYrws6xA/2L1reQR+l/3PXdCofRXqA
    0/b1v/Q2+qp6DQTEJM7TicCWLy7RqHEKQhAyA4BpFTZMtb9T4j/D9EECgYEAw5r6
    Kt89kfhwDGw4sCnC7KhVrqH0Jb0FwcjSh8STtyUEhywaJbfV0QjVRbPY9/4NWiWZ
    zWvQgbpceQaoc6mrFceg46nd02GdrtfR+r0DEFHJjXCnCMCM4rcyetnFKLOFHK07
    Lug9jpJa8nOirRgq4W4DepQciwWQAotTOo8/FJsCgYBPoX16a0eOYmKamfMP3wgo
    PSbhnsG82nJkdeJGYXZ4quTC5xTqbOb9BM7DA8esKJt6q6YbT+/FqiJT2BtDEODW
    aQS7ZwIZ6GiFpDqNZpEsWn2RXZTwMksx56Pjod+vZXJlZTMJsHBqgBRdpq3yzGzZ
    HPVdXvHd6tNughbPa93xgQKBgF9oUiljJgby5MRKbQQP+pGwMcqyGAHoRsyUhYvP
    aDVmiuTbsA1Bs7r30f7jkCq18hFMUc6Oje8Y1U3632M7GMXQzzr8ecRG0sCbaEIi
    u0HUgrjIf9CXCqDytl6RpccKeRzZqgphINVPsaicmnZPWWsHXA8H+zwcBHgZOQlR
    IXWNAoGANjvU+DUR5sf0eeItQgCdElgDHx9Csn7gBfjpQy/rkTqdSd07cjyqyKgc
    B/h/s78v2RooL1+Lw8WosEBb4sYJXOeFI5g/2dNSocMd81+tk8dzKxrKpVnNHURH
    YJi3JocWnFiJL0qGqt22Gdb0ZCA+DXcj3117+5RGwK8l6Mpxah4=
    -----END RSA PRIVATE KEY-----


The public key can be re-generated from the private key with the following command 
(see the Stackoverflow article ["Use RSA private key to generate public key?"][stackoverflow-ref-1-get-public-key] or the 
Devco article ["Public Private key encryption using OpenSSL"][devco-net-ref-1-get-public-key] for further information):

    $ openssl rsa -in private.pem -out public.pem -outform PEM -pubout


## <a name="section-3-6"></a> 3.6 Generate new developer ROTPK hash

Next generate a SHA256 hash of the ROTPK and store it in the ```new_keys/rotpk_sha256.bin``` file:

    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ openssl rsa -in new_keys/rot_key.pem -pubout -outform DER | openssl dgst -sha256 -binary > new_keys/rotpk_sha256.bin
    writing RSA key

The contents of the hash `rotpk_sha256.bin` file can be seen with the following command:

    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ hexdump new_keys/rotpk_sha256.bin 
    0000000 61a7 bfdd 7d5f 5c84 5139 0de7 8b81 d8a3
    0000010 37c6 7a04 87d8 a4e0 67d2 10ca f8fe 8620


## <a name="section-3-7"></a> 3.7 Patch BL1 image with the new developer ROTPK hash

The BL1 image binary `bl1.bin` is copied into the `new_keys` directory ready for patching. For reference, the current contents of the `new_keys` directory is shown below:

    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ ll new_keys/
    total 144
    drwxrwxr-x 2 user-007 user-007   4096 Oct 18 16:59 ./
    drwxrwxr-x 9 user-007 user-007   4096 Oct 18 17:00 ../
    -rw-rw-r-- 1 user-007 user-007 131072 Oct 18 16:59 bl1.bin
    -rw-rw-r-- 1 user-007 user-007   1679 Oct 18 16:54 rot_key.pem
    -rw-rw-r-- 1 user-007 user-007     32 Oct 18 16:55 rotpk_sha256.bin

The `bl1.bin` ROTPK hash is patched by replacing the old hash with the new hash in `rotpk_sha256.bin` using the `hack_bl1_rothash.py` script:

    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ hack_bl1_rothash.py --bl1 new_keys/bl1.bin --rotpk_sha256_replace=new_keys/rotpk_sha256.bin
    Found following DER headers:
    [18760]
    ROT_PK_SHA256:
    f1 84 06 b6 3c b4 f0 d2 62 83 b0 89 d6 c1 37 dd
    eb 3d 25 5d b9 31 b5 7c f1 98 0d 88 de 1d e4 55
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ 

## <a name="section-3-8"></a> 3.8 Patch BL2 image with the new developer ROTPK hash

The ATF name for BL2 image is `tb-fw.bin`. The BL2 image binary `tb-fw.bin` is copied into the new_keys directory ready for patching. 

    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ mv fip_components/tb-fw.bin new_keys/

    
For reference, the contents of the new_keys directory is then as shown below:

    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ ls -la new_keys/
    total 144
    drwxrwxr-x 2 user-007 user-007   4096 Oct 18 16:59 .
    drwxrwxr-x 9 user-007 user-007   4096 Oct 18 17:24 ..
    -rw-rw-r-- 1 user-007 user-007 131072 Oct 18 17:00 bl1.bin
    -rw-rw-r-- 1 user-007 user-007   1679 Oct 18 16:54 rot_key.pem
    -rw-rw-r-- 1 user-007 user-007     32 Oct 18 16:55 rotpk_sha256.bin
    -rw-rw-r-- 1 user-007 user-007   7356 Oct 18 16:56 tf-fw.bin

Next, replace the old ROTPK hash in the `tb-fw.bin` (the BL2 binary) with the hash of the new ROTPK generated above.
Note in the next command line the tb-fw.bin is specified as the --bl1 argument, so the ROTPK hash is replaced in this binary.
This is somewhat confused by using the hack_bl1_rothash.py script (a script with the bl1 name in it) to patch the bl2.

    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ hack_bl1_rothash.py --bl1 new_keys/tb-fw.bin  --rotpk_sha256_replace=new_keys/rotpk_sha256.bin
    Found following DER headers:
    [15652]
    ROT_PK_SHA256:
    f1 84 06 b6 3c b4 f0 d2 62 83 b0 89 d6 c1 37 dd
    eb 3d 25 5d b9 31 b5 7c f1 98 0d 88 de 1d e4 55
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ 


## <a name="section-3-9"></a> 3.9 Regenerate armstub8.bin with new developer ROTPK

The following `update_bl3x.sh` command line is used to generate a new `armstub8.bin` with the new ROT private key, patched BL1 binary, patched BL2 binary:

    update_bl3x.sh \
        --rot-key new_keys/rot_key.pem \
        --armstub8 fip_components/armstub8.bin \
        --new-bl1 new_keys/bl1.bin \
        --tb-fw new_keys/tb-fw.bin \
        --out fip_components/armstub8_new.bin
        
where:

* `--rot-key new_keys/rot_key.pem` specifies the new ROT private key, which is used to regenerate the BL3x key and content certificates.
* `--armstub8 armstub8.bin` specifies the original `armstub8.bin` from the `DEPLOY_DIR_IMAGE`.
* `--new-bl1 new_keys/bl1.bin` specifies the BL1 binary patched with the new ROTPK hash.
* `--tb-fw new_keys/tb-fw.bin` specifies the BL2 binary patched with the new ROTPK hash.
* `--out armstub8_new.bin` specifies the output name of the new `armstub8.bin` with the patched BL1/BL2 images, and newly generated BL3x key and content certificates.

The following trace shows the output of the `update_bl3x.sh` command:

    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ update_bl3x.sh --rot-key new_keys/rot_key.pem --armstub8 fip_components/armstub8.bin --new-bl1 new_keys/bl1.bin --tb-fw new_keys/tb-fw.bin --out fip_components/armstub8_new.bin
    131072+0 records in
    131072+0 records out
    131072 bytes (131 kB, 128 KiB) copied, 0.24878 s, 527 kB/s
    885436+0 records in
    885436+0 records out
    885436 bytes (885 kB, 865 KiB) copied, 1.13843 s, 778 kB/s
    Trusted Boot Firmware BL2: offset=0x268, size=0x125F0, cmdline="--tb-fw"
    EL3 Runtime Firmware BL31: offset=0x12858, size=0x7079, cmdline="--soc-fw"
    Secure Payload BL32 (Trusted OS): offset=0x198D1, size=0x1C, cmdline="--tos-fw"
    Secure Payload BL32 Extra1 (Trusted OS Extra1): offset=0x198ED, size=0x53800, cmdline="--tos-fw-extra1"
    Secure Payload BL32 Extra2 (Trusted OS Extra2): offset=0x6D0ED, size=0x0, cmdline="--tos-fw-extra2"
    Non-Trusted Firmware BL33: offset=0x6D0ED, size=0x68B68, cmdline="--nt-fw"
    Trusted key certificate: offset=0xD5C55, size=0x60E, cmdline="--trusted-key-cert"
    SoC Firmware key certificate: offset=0xD6263, size=0x4DA, cmdline="--soc-fw-key-cert"
    Trusted OS Firmware key certificate: offset=0xD673D, size=0x4E8, cmdline="--tos-fw-key-cert"
    Non-Trusted Firmware key certificate: offset=0xD6C25, size=0x4EA, cmdline="--nt-fw-key-cert"
    Trusted Boot Firmware BL2 certificate: offset=0xD710F, size=0x46F, cmdline="--tb-fw-cert"
    SoC Firmware content certificate: offset=0xD757E, size=0x430, cmdline="--soc-fw-cert"
    Trusted OS Firmware content certificate: offset=0xD79AE, size=0x4CE, cmdline="--tos-fw-cert"
    Non-Trusted Firmware content certificate: offset=0xD7E7C, size=0x440, cmdline="--nt-fw-cert"
    NOTICE:  CoT Generation Tool: Built : 16:24:14, Oct 18 2018
    NOTICE:  Target platform: TBBR Generic
    NOTICE:  Creating new key for 'Trusted World key'
    NOTICE:  Creating new key for 'Non Trusted World key'
    NOTICE:  Creating new key for 'SCP Firmware Content Certificate key'
    NOTICE:  Creating new key for 'SoC Firmware Content Certificate key'
    NOTICE:  Creating new key for 'Trusted OS Firmware Content Certificate key'
    NOTICE:  Creating new key for 'Non Trusted Firmware Content Certificate key'
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ 


## <a name="section-3-10"></a> 3.10 Boot the new armstub8.bin

The new `armstub8_new.bin` is now copied to the RPI3 SDCard boot partition:


    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ rm /media/user-007/boot/armstub8.bin 
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ cp armstub8_new.bin /media/user-007/boot/armstub8.bin 
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ ls -la /media/user-007/boot
    total 25900
    drwxr-xr-x   3 user-007 user-007   16384 Oct 18 15:50 .
    drwxr-x---+ 14 root     root        4096 Oct 18 15:48 ..
    -rw-r--r--   1 user-007 user-007 1032900 Oct 18 15:50 armstub8.bin
    -rw-r--r--   1 user-007 user-007   23219 Oct 18 09:53 bcm2708-rpi-0-w.dtb
    -rw-r--r--   1 user-007 user-007   22716 Oct 18 09:53 bcm2708-rpi-b.dtb
    -rw-r--r--   1 user-007 user-007   22975 Oct 18 09:53 bcm2708-rpi-b-plus.dtb
    -rw-r--r--   1 user-007 user-007   22493 Oct 18 09:53 bcm2708-rpi-cm.dtb
    -rw-r--r--   1 user-007 user-007   24019 Oct 18 09:53 bcm2709-rpi-2-b.dtb
    -rw-r--r--   1 user-007 user-007   25362 Oct 18 09:53 bcm2710-rpi-3-b.dtb
    -rw-r--r--   1 user-007 user-007   25657 Oct 18 09:53 bcm2710-rpi-3-b-plus.dtb
    -rw-r--r--   1 user-007 user-007   24138 Oct 18 09:53 bcm2710-rpi-cm3.dtb
    -rw-r--r--   1 user-007 user-007       0 Oct 18 09:53 bcm2835-bootfiles-20180817.stamp
    -rw-r--r--   1 user-007 user-007   52116 Oct 18 09:53 bootcode.bin
    -rw-r--r--   1 user-007 user-007    1591 Oct 18 09:53 boot.scr
    -rw-r--r--   1 user-007 user-007      93 Oct 18 09:53 cmdline.txt
    -rw-r--r--   1 user-007 user-007   36259 Oct 18 09:53 config.txt
    -rw-r--r--   1 user-007 user-007    2617 Oct 18 09:53 fixup_cd.dat
    -rw-r--r--   1 user-007 user-007    6659 Oct 18 09:53 fixup.dat
    -rw-r--r--   1 user-007 user-007    9888 Oct 18 09:53 fixup_db.dat
    -rw-r--r--   1 user-007 user-007    9884 Oct 18 09:53 fixup_x.dat
    -rw-r--r--   1 user-007 user-007  428904 Oct 18 09:53 kernel7.img
    drwxr-xr-x   2 user-007 user-007    2048 Oct 18 09:53 overlays
    -rw-r--r--   1 user-007 user-007  677508 Oct 18 09:53 start_cd.elf
    -rw-r--r--   1 user-007 user-007 5108452 Oct 18 09:53 start_db.elf
    -rw-r--r--   1 user-007 user-007 2846532 Oct 18 09:53 start.elf
    -rw-r--r--   1 user-007 user-007 4047332 Oct 18 09:53 start_x.elf
    -rw-r--r--   1 user-007 user-007 5083184 Oct 18 09:53 uImage
    -rw-r--r--   1 user-007 user-007 6939384 Oct 18 09:53 uImage-initramfs-raspberrypi3-mbl.bin
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ sync
    user@machine:/data/2284/test/to_delete/20181018/pr239/work$ sudo eject /dev/sdd


The reprogrammed SDCard should now show the following boot trace:

    NOTICE:  Booting Trusted Firmware
    NOTICE:  BL1: v1.5(release):v1.5-645-g3ba9295
    NOTICE:  BL1: Built : 08:53:26, Oct 18 2018
    INFO:    BL1: RAM 0x100ee000 - 0x100fa000
    INFO:    Using crypto library 'mbed TLS'
    NOTICE:  rpi3: Detected: Raspberry Pi 3 Model B (1GB, Embest, China) [0x00a22082]
    INFO:    BL1: Loading BL2
    INFO:    Loading image id=6 at address 0x100b4000
    INFO:    Image id=6 loaded: 0x100b4000 - 0x100b446f
    INFO:    Loading image id=1 at address 0x100b4000
    INFO:    Image id=1 loaded: 0x100b4000 - 0x100c65f0
    NOTICE:  BL1: Booting BL2
    INFO:    Entry point address = 0x100b4000
    INFO:    SPSR = 0x3c5
    NOTICE:  BL2: v1.5(release):v1.5-645-g3ba9295
    NOTICE:  BL2: Built : 08:53:28, Oct 18 2018
    INFO:    Using crypto library 'mbed TLS'
    INFO:    BL2: Doing platform setup
    INFO:    BL2: Loading image id 3
    INFO:    Loading image id=7 at address 0x100e0000
    INFO:    Image id=7 loaded: 0x100e0000 - 0x100e060e
    INFO:    Loading image id=9 at address 0x100e0000
    INFO:    Image id=9 loaded: 0x100e0000 - 0x100e04da
    INFO:    Loading image id=13 at address 0x100e0000
    INFO:    Image id=13 loaded: 0x100e0000 - 0x100e0430
    INFO:    Loading image id=3 at address 0x100e0000
    INFO:    Image id=3 loaded: 0x100e0000 - 0x100e7079
    INFO:    BL2: Loading image id 4
    INFO:    Loading image id=10 at address 0x10100000
    INFO:    Image id=10 loaded: 0x10100000 - 0x101004e8
    INFO:    Loading image id=14 at address 0x10100000
    INFO:    Image id=14 loaded: 0x10100000 - 0x101004ce
    INFO:    Loading image id=4 at address 0x10100000
    INFO:    Image id=4 loaded: 0x10100000 - 0x1010001c
    INFO:    OPTEE ep=0x10100000
    INFO:    OPTEE header info:
    INFO:          magic=0x4554504f
    INFO:          version=0x2
    INFO:          arch=0x1
    INFO:          flags=0x0
    INFO:          nb_images=0x1
    INFO:    BL2: Loading image id 21
    INFO:    Loading image id=21 at address 0x10100000
    INFO:    Image id=21 loaded: 0x10100000 - 0x10153800
    INFO:    BL2: Skip loading image id 22
    INFO:    BL2: Loading image id 5
    INFO:    Loading image id=11 at address 0x11000000
    INFO:    Image id=11 loaded: 0x11000000 - 0x110004ea
    INFO:    Loading image id=15 at address 0x11000000
    INFO:    Image id=15 loaded: 0x11000000 - 0x11000440
    INFO:    Loading image id=5 at address 0x11000000
    INFO:    Image id=5 loaded: 0x11000000 - 0x11068b68
    INFO:    BL33 will boot in Non-secure AArch32 Hypervisor mode
    NOTICE:  BL1: Booting BL31
    INFO:    Entry point address = 0x100e0000
    INFO:    SPSR = 0x3cd
    NOTICE:  BL31: v1.5(release):v1.5-645-g3ba9295
    NOTICE:  BL31: Built : 08:53:30, Oct 18 2018
    INFO:    BL31: Initializing runtime services
    INFO:    BL31: Initializing BL32
    E/TC:0 0 init_fdt:775 Device Tree missing
    INFO:    BL31: Preparing for EL3 exit to normal world
    INFO:    Entry point address = 0x11000000
    INFO:    SPSR = 0x1da


    U-Boot 2018.07 (Oct 18 2018 - 08:53:13 +0000)

    DRAM:  948 MiB
    RPI 3 Model B (0xa22082)
    MMC:   mmc@7e202000: 0, sdhci@7e300000: 1
    Loading Environment from FAT... *** Warning - bad CRC, using default environment

    Failed (-5)
    In:    serial
    Out:   vidconsole
    Err:   vidconsole
    Net:   No ethernet found.
    starting USB...
    USB0:   scanning bus 0 for devices... 3 USB Device(s) found
           scanning usb for storage devices... 0 Storage Device(s) found
    Hit any key to stop autoboot:  0 
    U-Boot>

## <a name="section-4-0"></a> 4.0 References

* Trusted Board Boot Requirements CLIENT (TBBR-CLIENT), Document number: ARM DEN0006C-1, Copyright ARM Limited 2011-2015
* [Linaro Releases][linaro-gcc-linaro-7.2.1]
* [Trusted Firmware For Cortex-A User Guide, Building and using the fip tool][atf-user-guide-fiptool]
* [Trusted Firmware For Cortex-A User Guide, Building and using the cert tool][atf-user-guide-cert-create-tool]
* [Using RSA Private Key to Generate Public Key, Stackoverflow][stackoverflow-ref-1-get-public-key]
* [Public-Private Key Encryption Using Openssl][devco-net-ref-1-get-public-key]

        
        
[atf-user-guide-fiptool]: https://github.com/ARM-software/arm-trusted-firmware/blob/master/docs/user-guide.rst#45building-and-using-the-fip-tool
[atf-user-guide-cert-create-tool]: https://github.com/ARM-software/arm-trusted-firmware/blob/master/docs/user-guide.rst#47building-the-certificate-generation-tool
[devco-net-ref-1-get-public-key]: https://www.devco.net/archives/2006/02/13/public_-_private_key_encryption_using_openssl.php
[linaro-gcc-linaro-7.2.1]: http://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/aarch64-linux-gnu/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu.tar.xz 
[linaro-connect-las16-402-slides]: https://connect.linaro.org/resources/las16/las16-402/
[stackoverflow-ref-1-get-public-key]: https://stackoverflow.com/questions/5244129/use-rsa-private-key-to-generate-public-key

