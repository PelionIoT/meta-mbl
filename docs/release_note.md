# mbl-os-0.8

Copyright © 2018-2019 Arm Limited.

We are pleased to announce that [Mbed Linux OS 0.8.0][mbl-release] is now available as a public preview release.

## Summary

This release is intended to enable customers to continue to validate the Mbed Linux operating system. This release is built upon the OpenEmbedded build automation framework and uses versions of OpenEmbedded and Third Party IP that are pinned for this release.

For more information about the features and product vision, please see the [introduction on our website][mbl-introduction].

## Changes

The main additions to 0.8 over 0.7:

* Partial BSP support for the [TechNexion PICO-PI development board with an i.MX6UL System on Module](https://os.mbed.com/docs/mbed-linux-os/v0.8/first-image/hardware.html).
* New [meta-psa layer](https://github.com/ARMmbed/meta-mbl/tree/mbl-os-0.8/meta-psa) that adds support for [Mbed Crypto](https://github.com/ARMmbed/mbed-crypto).
* Beta [standalone signing tool](https://github.com/ARMmbed/meta-mbl/tree/mbl-os-0.8/openembedded-core-mbl/scripts/signctl/README.md) to simplify the certificate generation and signing of the boot loaders and update components.

## Known issues

Please refer to the [list of issues][mbl-issues] for all the main and supporting Mbed Linux OS repositories.

## Using this release

Refer to the [website][mbl-start-guide] for documentation on getting started with Mbed Linux OS.

Evaluation binaries can be found in github attached to the [github release][mbl-release], please refer to the [website][mbl-start-guide] for more information on how to use these binaries.

Please ask any questions or provide feedback about this release via [mbed support][mbed-email] or raise an issue on the relevant repository in github.

### Repositories

This release is made up of several repositories, the main ones are:

* [meta-mbl (mbl-os-0.8 branch)][meta-mbl] - OpenEmbedded (OE) distribution layer for creating Mbed Linux OS IoT file system images.
* [mbl-core (mbl-os-0.8 branch)][mbl-core] - Mbed Linux OS source code, tests and a tutorial application.
* [mbl-tools (mbl-os-0.8 branch)][mbl-tools] - Tools to enable building and testing of Mbed Linux OS.
* [mbl-cli (mbl-os-0.8 branch)][mbl-cli] - Command line utility that uses a Development Connection to aid in development with Mbed Linux OS platforms.

The supporting repositories are:

* [mbl-manifest (mbl-os-0.8 branch)][mbl-manifest] - the repo manifest xml for Mbed Linux OS distributions.
* [mbl-config (mbl-os-0.8 branch)][mbl-config] - configuration and environment files for Mbed Linux OS.

### Documentation

Thhe main documentation is on the [website][mbl-introduction]. There are some supporting reference and technical documentation in [meta-mbl/docs][mbl-extra-docs].


[mbl-release]: https://github.com/ARMmbed/mbl-manifest/releases/tag/mbl-os-0.8.0
[mbl-extra-docs]: https://github.com/ARMmbed/meta-mbl/tree/mbl-os-0.8/docs
[mbl-start-guide]: https://os.mbed.com/docs/mbed-linux-os/v0.8/welcome/index.html#getting-started
[mbl-introduction]: https://os.mbed.com/docs/mbed-linux-os/v0.8/welcome/index.html
[mbed-email]: mailto:support@mbed.com
[mbl-issues]: https://github.com/issues?q=is%3Aissue+archived%3Afalse+repo%3AARMmbed%2Fmbl-tools+repo%3AARMmbed%2Fmeta-mbl+repo%3AARMmbed%2Fmbl-manifest+repo%3AARMmbed%2Fmbl-core+repo%3AARMmbed%2Fmbl-cli+repo%3AARMmbed%2Fmbl-config+is%3Aopen

[meta-mbl]: https://github.com/ARMmbed/meta-mbl/tree/mbl-os-0.8
[mbl-core]: https://github.com/ARMmbed/mbl-core/tree/mbl-os-0.8
[mbl-tools]: https://github.com/ARMmbed/mbl-tools/tree/mbl-os-0.8
[mbl-manifest]: https://github.com/ARMmbed/mbl-manifest/tree/mbl-os-0.8
[mbl-config]: https://github.com/ARMmbed/mbl-config/tree/mbl-os-0.8
[mbl-cli]: https://github.com/ARMmbed/mbl-cli/tree/mbl-os-0.8
