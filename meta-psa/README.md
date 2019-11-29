# meta-psa OpenEmbedded layer

The meta-psa OpenEmbedded layer provides reference implementations and tests for
the Arm Platform Security Architecture APIs.

# 1.0 PSA
The Arm Platform Security Architecture (PSA) is a holistic set of threat
models, security analyses, hardware and firmware architecture specifications,
and an open source firmware reference implementation. PSA provides a recipe,
based on industry best practice, that allows security to be consistently
designed in, at both a hardware and firmware level.

For more information, see the [PSA website][psa].

# 2.0 Recipes
This layer currently provides recipes for:
* [Mbed Crypto][mbed-crypto] - an implementation of the Arm [PSA Crypto API][psa-crypto].
* [psa-trusted-storage-linux][psa-trusted-storage-linux] - an implementation of the Arm [PSA Storage API][psa-storage-linux-spec].

# 3.0 Dependencies
meta-psa is a reusable software component of PSA features and
it's therefore important to understand the interfaces with and dependencies on other components.
This layer depends on the following:
- [meta-security][meta-security] OpenEmbedded Layer. This layer provides recipes for ecryptfs-utils and keyutils
  used by psa-trusted-storage-linux.
- Linux kernel configuration options. The Linux kernel must be built with specific cryptographic and [eCryptfs][ecryptfs]
  configuration options enabled.

# 4.0 PSA trusted storage Linux using eCryptfs
## 4.1 Overview
The PSA Trusted Storage API Linux implementation uses the eCryptfs file system
for file level security. ECryptfs is a stacked filesystem which transparently ciphers
files using a per-file, randomly generated File Encryption Key (FEK).
Each FEK is (in turn) encrypted with a master key called the File Encryption Key Encryption
Key (FEKEK). The PSA Trusted Storage Linux system integration provided here is an indicative example
implementation intended to be enhanced with additional, platform-specific security measures, as discussed later.

The following sub-sections describe different aspects of the PSA Trusted Storage Linux implementation:
* [Linux kernel configuration](#section-4-2). This section describes the Linux kernel configuration required to support eCryptfs.
* [eCryptfs Linux System Integration](#section-4-3) The section describes the example system integration provided here,
  including system start-up, initialisation, generating the FEKEK and FEKEK passphrases, and mounting the
  eCryptfs overlay driver on the storage directory.
* [Basic security of the eCryptfs passphrase](#section-4-4). This section describes the proposal
  for how the top-level passphrase can be managed more securely by taking advantage of
  platform specific security services. To have an acceptable level of security,
  the final system integrator must provide a hardware passphrase facility and integrate this as described
  in this section.

## <a name="section-4-2"></a> 4.2 Linux Kernel Configuration
The required Linux kernel configuration options for [eCryptfs][ecryptfs] are documented in the [ecryptfs-faq][ecryptfs-faq]:

    CONFIG_EXPERIMENTAL=y
    CONFIG_KEYS=y
    CONFIG_CRYPTO=y
    CONFIG_CRYPTO_ALGAPI=y
    CONFIG_CRYPTO_BLKCIPHER=y
    CONFIG_CRYPTO_HASH=y
    CONFIG_CRYPTO_MANAGER=y
    CONFIG_CRYPTO_MD5=y
    CONFIG_CRYPTO_ECB=y
    CONFIG_CRYPTO_CBC=y
    CONFIG_CRYPTO_AES=y
    CONFIG_ECRYPT_FS=y
    CONFIG_ECRYPT_FS_MESSAGING=y

The options enable support for the following kernel features:
- **CONFIG_EXPERIMENTAL**: This option enables features under active development and testing.
- **CONFIG_KEYS**: This option enables support for retaining authentication tokens and access keys in the kernel.
- **CONFIG_CRYPTO**: This option enables the core Cryptographic API.
- **CONFIG_CRYPTO_ALGAPI**: This option enables the API for cryptographic algorithms.
- **CONFIG_CRYPTO_BLKCIPHER**: This option enables cryptographic block cipher algorithms.
- **CONFIG_CRYPTO_HASH**: This option enables cryptographic hash algorithms.
- **CONFIG_CRYPTO_MANAGER**: This option enables default cryptographic template instantiations such as cbc(aes).
- **CONFIG_CRYPTO_MD5**: This option enables the MD5 message digest algorithm (RFC1321).
- **CONFIG_CRYPTO_ECB**: This option enables the Electronic CodeBook mode. This is the simplest block cipher algorithm.
- **CONFIG_CRYPTO_CBC**: This option enables Cipher Block Chaining mode.
- **CONFIG_CRYPTO_AES**: This option enables Advanced Encryption Standard cipher algorithms (FIPS-197).
- **CONFIG_ECRYPT_FS**: This option enables the encrypted filesystem that operates on the VFS layer.
- **CONFIG_ECRYPT_FS_MESSAGING**: This option enables the /dev/ecryptfs entry for use by ecryptfsd and other userspace tools like OpenSSL.

The kernel configuration is typically stored in a configuration fragment file (e.g. `ecryptfs.cfg`)
and processed by the Linux kernel recipe used to build the kernel. For example, if a Linux kernel recipe
`/meta-vendor/recipes-kernel/linux/linux-vendor-soc.bb` builds the kernel, then the following
`/meta-mydistro/recipes-kernel/linux/linux-vendor-soc.bbappend` could be used to apply
`/meta-mydistro/recipes-kernel/linux/files/ecryptfs.cfg`:

    # Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
    #
    # SPDX-License-Identifier: MIT

    FILESEXTRAPATHS_prepend:="${THISDIR}/files:"
    SRC_URI_append = "file://ecryptfs.cfg "

## <a name="section-4-3"></a> 4.3 eCryptfs Linux System Integration
PSA Trusted Storage leverages the eCryptfs usage model in the following way:
* The system stores encrypted files in a dedicated storage area of the computer's file system
  (e.g. a directory called `/home/root/.secret`). Each file is encrypted with it's unique
  FEK to maintain confidentiality.
* The system accesses the encrypted files by mounting the eCryptfs overlay driver
  on the storage area during system initialisation (e.g. using the
  mountpoint `/home/root/secret`).
  The files appear decrypted when accessed via the mountpoint because the overlay
  driver uses the FEKEK to decrypt the file's FEK, and then uses the FEK to decrypt
  the file.
* Once mounted, files saved into `/home/root/secret` are encrypted and stored in the under-lying
  storage directory `/home/root/.secret`.
* The systemd service file [psa-ecryptfs.service][psa-ecryptfs.service] orchestrates start-up initialisation
  by running the [psa-ecryptf-init.sh][psa-ecryptf-init.sh] bash script. This is provided as an example
  demonstrating one method. In summary, the script performs the following operations:
    * On first boot the script generates a system-unique FEKEK, and a FEFEK passphrase. This step is a one
      time operation and is skipped on subsequent boots.
    * The script populates the FEKEK into the kernel keyring for use by eCryptfs.
    * The script mounts the storage directory at the specified mountpoint.

Note in this context "passphrase" refers to a key i.e. a sequence of alpha-numeric characters
used to cipher data. eCryptfs requires 2 passphrases to encrypt the data in the file storage:

* A wrapped passphrase - that is used as the FEKEK (File Encryption File Encryption Key)
    * Referred to as the "wrapped FEKEK" or just FEKEK as the unwrapped version.
    * The wrapped FEKEK is stored on the system.
* A top-level passphrase - that is used to wrap/unwrap the FEKEK and as a key to allow mounting of
  the eCryptfs.
    * The top-level passphrase is not supposed to be stored on the system

### 4.3.1 The eCryptfs example start-up/initialisation flow and passphrase process
This section describes the example reference implementation used to test the PSA Trusted Storage on Linux.

The start-up and initialisation of the example functionality is performed by the
[psa-ecryptf-init.sh][psa-ecryptf-init.sh] initialization script, which is run on every boot
by systemd.

#### 4.3.1.1 On first boot

The following operations are performed the first time the system boots:

* Directories are created to manage the storage of files and configuration information:
    * `/home/root/.secret`. This is the directory used to store encrypted files.
    * `/home/root/secret`. This is the mount point directory for accessing unencrypted versions of the files.
    * `/home/root/.ecrypt`. This is a configuration directory used for storing the passphrase and "wrapped FEKEK".
       The start-up script ensures this directory is only readable by the assigned system user (i.e. no group or world access is permitted).
       In the example integration, the system user is `root`.
* The FEKEK is generated, which will be wrapped and become the wrapped passphrase (i.e. the "wrapped FEKEK", see next points).
* The top-level passphrase is generated and stored in `/home/root/.ecrypt`.
* The FEKEK is encrypted (i.e. "wrapped FEKEK") with the top-level passphrase and stored in `/home/root/.ecrypt`.
* Discard the FEKEK (i.e. the "unwrapped FEKEK").

The following command can be used to wrap (encrypt) the FEKEK with the passphrase "passphrase",
where `[wrapped FEKEK]` is the name of file containing the wrapped FEKEK:

    # Wrapping the FEKEK
    printf "%s\n%s" "FEKEK" "passphrase" | ecryptfs-wrap-passphrase [wrapped FEKEK] -

#### 4.3.1.2 On each boot (including the first boot)
The [psa-ecryptf-init.sh][psa-ecryptf-init.sh] script performs the following initialisation
steps on the first and all subsequent boots:
* Using the top-level passphrase from `/home/root/.ecrypt`, unwrap "wrapped FEKEK" and store it in the kernel user keyring.
* Using the top-level passphrase from `/home/root/.ecrypt`, mount the encrypted storage in the unencrypted directory.

The following command can be used to decrypt the wrapped FEKEK and insert it into the keyring,
where `[wrapped FEKEK]` is the name of file containing the wrapped FEKEK:

    # Insert FEKEK in keyring
    printf "%s" "passphrase" | ecryptfs-insert-wrapped-passphrase-into-keyring [wrapped_FEKEK] -

Once installed in the keyring, the FEKEK can be referenced with its signature (e.g.
`b89bed87989fcf3d`). The following command mounts the encrypted files storage directory
`/home/root/.secret` to make the decrypted files visible at the `/home/root/secret`
mount point:

    mount -t ecryptfs /home/root/.secret /home/root/secret -o \
    ecryptfs_sig=b89bed87989fcf3d,ecryptfs_fnek_sig=b89bed87989fcf3d,\
    ecryptfs_cipher=aes,ecryptfs_key_bytes=16,\
    key=passphrase:passphrase_passwd_file=/home/root/.ecryptfs/passphrase.txt,\
    ecryptfs_passthrough=n,ecryptfs_unlink_sigs,no_sig_cache

### 4.3.2 Security concerns
The top-level passphrase used to wrap the FEKEK is stored on the system under user account protection.
This is discussed further in the next section.

## <a name="section-4-4"></a> 4.4 Securing the eCryptfs top-level passphrase
The previous sections explained that the top-level eCryptfs passphrase is used to decrypt the "wrapped FEKEK" and mount the encrypted storage.
However, this passphrase is not held securely in the example integration provided. This section provides guidance on how the passphrase can be secured using platform specific hardware services.

### 4.4.1 Securing the eCryptfs passphrase
In order to store the top-level passphrase securely, the following requirements must be met:
- The top-level passphrase must be stored securely in the system using hardware enabled security features (e.g. TrustZone).
- The passphrase may be regenerated when required e.g. using a key generation algorithm to derive a new key from a hardware unique key.
- The top-level passphrase must be unique to the device, but the same on each system boot.
- The top-level passphrase must be retrieved (or regenerated) on each boot and populated into the kernel key retention service (keyring).
  This operation must be performed in a secure manner.
- eCryptfs must recover the top-level passphrase from the keyring and mount the encrypted storage directory. Once
  mounted, the top-level passphrase should be removed from the keyring and discarded.

Some IoT devices will include a TPM (Trusted Platform Module) which solves the passphrase storage problem by providing secure
storage hardware. A hardware TPM typically provides several other security services
including secure storage of keys and certificates, key provisioning, a secure identity, attestation support
and anti-rollback protection. Alternatively, a lower-cost firmware TPM using an OPTEE (TrustZone) trusted application
could be implemented to provide equivalent APIs to those offered by hardware TPMs.

Some IoT devices will include a Secure Element (SE) accessible via a cryptographic API (e.g. the PSA Crypto API).
In this case, the SE key storage services are used to store the top level passphrase.

There are 3 principal methods for securing top-level eCryptfs passphrase:
* Create a custom function using a TPM for storing the passphrase securely. The function is called once during kernel boot to
  retrieve the eCryptfs passphrase, which is then populated into the kernel key retention service (keyring)
  for use by eCryptfs.
* Create a custom function using a SE crypto-API for storing the passphrase securely. The function is called once during kernel boot to
  retrieve the eCryptfs passphrase, which is then populated into a kernel keyring for use by eCryptfs.
* Derive the eCryptfs passphrase using a crypto-library API and the Hardware Unique Key (HUK) during secure boot. This passphrase can be passed from the
  secure boot to the kernel via DTB (Device Tree Blob) entry, where the kernel then populates the passphrase into a kernel keyring
  for use by eCryptfs.

It is up to the integrator to provide this passphrase facility.
In the following sections, the hardware passphrase retrieval facility will be referred to as `get_eCryptfs_passphrase_from_hardware`.

### 4.4.2 Flow
#### 4.4.2.1 In the OS distribution
The following directories should be created by the OS distribution:
* Encrypted storage directory.
* Mounted unencrypted storage directory.

#### 4.4.2.2 In the factory
The following operations should be performed in the factory:
* Generate a FEKEK per device.
* On the device - using the passphrase (`get_eCryptfs_passphrase_from_hardware`).
  wrap the FEKEK to create the "wrapped FEKEK", and store this in the factory configuration
  location on the device.
* Discard the FEKEK.

#### 4.4.2.3 Each boot
During the initramfs script that is part of the kernel boot process:
* Using the passphrase (`get_eCryptfs_passphrase_from_hardware`) unwrap
  the "wrapped FEKEK" and store it in the kernel user keyring.
* Mount the encrypted storage in the unencrypted directory using the same passphrase.

The mounting operation can be performed as follows:

    passphrase=$(get_eCryptfs_passphrase_from_hardware)

    # Insert FEKEK in keyring
    printf "%s" "$passphrase" | \
    ecryptfs-insert-wrapped-passphrase-into-keyring /factory_config/wrapped_FEKEK -

    # Mount via stdin
    printf "passphrase_passwd=%s" "$passphrase" | mount -t ecryptfs \
    /home/root/.secret /home/root/secret -o \
    ecryptfs_sig=b89bed87989fcf3d,\
    ecryptfs_fnek_sig=b89bed87989fcf3d,ecryptfs_cipher=aes,\
    ecryptfs_key_bytes=16,ecryptfs_passthrough=n,\
    ecryptfs_unlink_sigs,no_sig_cache,key=passphrase:passphrase_passwd_fd=0

    # Throw away passphrase by zeroing the environment variable and DTB entry (if any)

### 4.4.3 Security risks
The passphrase is available in user memory for a short period during boot.


[ecryptfs]:https://launchpad.net/ecryptfs
[ecryptfs-faq]: https://github.com/dustinkirkland/ecryptfs-utils/blob/master/doc/ecryptfs-faq.html
[psa-ecryptf-init.sh]: https://github.com/ARMmbed/psa_trusted_storage_linux/blob/master/linux/systemd/psa-ecryptfs-init.sh
[psa-ecryptfs.service]: https://github.com/ARMmbed/psa_trusted_storage_linux/blob/master/linux/systemd/psa-ecryptfs.service
[mbed-crypto]: https://github.com/ARMmbed/mbed-crypto
[meta-security]: https://git.yoctoproject.org/cgit/cgit.cgi/meta-security
[psa]: https://developer.arm.com/architectures/security-architectures/platform-security-architecture
[psa-arch-tests]: https://github.com/ARM-software/psa-arch-tests
[psa-crypto]: https://armmbed.github.io/mbed-crypto/html/general.html
[psa-storage-linux-spec]: https://developer.arm.com/-/media/Files/pdf/PlatformSecurityArchitecture/Implement/IHI0087-PSA_Storage_API-1.0.0.pdf
[psa-trusted-storage-linux]: https://github.com/ARMmbed/psa-trusted-storage-linux
