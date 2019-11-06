# meta-psa OpenEmbedded layer

The meta-psa OpenEmbedded layer provides reference implementations and tests for
the Arm Platform Security Architecture APIs.

## PSA
The Arm Platform Security Architecture (PSA) is a holistic set of threat
models, security analyses, hardware and firmware architecture specifications,
and an open source firmware reference implementation. PSA provides a recipe,
based on industry best practice, that allows security to be consistently
designed in, at both a hardware and firmware level.

For more information, see the [PSA website][psa].

## Recipes
This layer currently provides recipes for:
* [Mbed Crypto][mbed-crypto] - an implementation of the Arm [PSA Crypto API][psa-crypto].
* [psa-arch-tests][psa-arch-tests] - the Arm PSA Architecture test suite.
* [psa-trusted-storage-linux][psa-trusted-storage-linux] - an implementation of the Arm [PSA Storage API][psa-storage-linux-spec].

## Dependencies
meta-psa is a reusable software component of PSA features and
it's therefore important to understand the interfaces with and dependencies on other components.
This layer depends on the following:
- [meta-security][meta-security] OpenEmbedded Layer. This layer provides recipes for ecryptfs-utils and keyutils
  used by psa-trusted-storage-linux.
- Linux kernel configuration options. The Linux kernel must be built with specific cryptographic and [ecryptfs][ecryptfs]
configuration options enabled.

### Ecryptfs Kernel Configuration
The required Linux kernel configuration options for [ecryptfs][ecryptfs] are documented in the [ecryptfs-faq][ecryptfs-faq]:

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


[ecryptfs]:https://launchpad.net/ecryptfs
[ecryptfs-faq]: https://github.com/dustinkirkland/ecryptfs-utils/blob/master/doc/ecryptfs-faq.html
[mbed-crypto]: https://github.com/ARMmbed/mbed-crypto
[meta-security]: https://git.yoctoproject.org/cgit/cgit.cgi/meta-security
[psa]: https://developer.arm.com/architectures/security-architectures/platform-security-architecture
[psa-arch-tests]: https://github.com/ARM-software/psa-arch-tests
[psa-crypto]: https://armmbed.github.io/mbed-crypto/html/general.html
[psa-storage-linux-spec]: https://developer.arm.com/-/media/Files/pdf/PlatformSecurityArchitecture/Implement/IHI0087-PSA_Storage_API-1.0.0.pdf
[psa-trusted-storage-linux]: https://github.com/ARMmbed/psa-trusted-storage-linux
