# mbl-os-0.6

Copyright © 2018-2019 Arm Limited.

We are pleased to announce that [Mbed Linux OS 0.6.0][mbl-linux-release] is now available as a restricted preview release.

## Summary

This preview release is an incremental improvement over Mbed Linux OS 0.5, but it still intended for limited distribution to enable customers to continue to validate the foundations of the Mbed Linux operating system. This release is built upon the OpenEmbedded build automation framework and uses versions of OpenEmbedded and Third Party IP that are pinned for this release.

For more information about the the features and product vision, please see the [introduction on our website][mbl-introduction].

## Known issues

Please refer to the [list of issues][mbl-issues] for all the main and supporting Mbed Linux OS repositories.

## Using this release

Refer to the [website][mbl-start-guide] for documentation on getting started with Mbed Linux OS.

Evaluation binaries can be found in github attached to the [github release][mbl-linux-release], please refer to the [website][mbl-start-guide] for more information on how to use these binaries.

Please ask any questions or provide feedback about this release via [mbed support][mbed-email] or raise an issue on the relevant repository in github.

### Repositories

This release is made up of several repositories, the main ones are:

* [meta-mbl (mbl-os-0.6 branch)][meta-mbl] - OpenEmbedded (OE) distribution layer for creating Mbed Linux OS IoT file system images.
* [mbl-core (mbl-os-0.6 branch)][mbl-core] - Mbed Linux OS source code, tests and a tutorial application.
* [mbl-tools (mbl-os-0.6 branch)][mbl-tools] - Tools to enable building and testing of Mbed Linux OS.
* [mbl-cli (mbl-os-0.6 branch)][mbl-cli] - Command line utility that uses a Development Connection to aid in development with Mbed Linux OS platforms.

The supporting repositories are:

* [mbl-manifest (mbl-os-0.6 branch)][mbl-manifest] - the repo manifest xml for Mbed Linux OS distributions.
* [mbl-config (mbl-os-0.6 branch)][mbl-config] - configuration and environment files for Mbed Linux OS.

### Documentation

Thhe main documentation is on the [website][mbl-introduction]. There are some supporting reference and technical documentation in [meta-mbl/docs][mbl-extra-docs].


[mbl-linux-release]: https://github.com/ARMmbed/mbl-manifest/releases/tag/mbl-os-0.6.0
[mbl-extra-docs]: https://github.com/ARMmbed/meta-mbl/tree/mbl-os-0.6/docs
[mbl-start-guide]: https://os.mbed.com/docs/mbed-linux-os/v0.6/welcome/index.html#getting-started
[mbl-introduction]: https://os.mbed.com/docs/mbed-linux-os/v0.6/welcome/index.html
[mbed-email]: mailto:support@mbed.com
[mbl-issues]: https://github.com/issues?q=is%3Aissue+archived%3Afalse+repo%3AARMmbed%2Fmbl-tools+repo%3AARMmbed%2Fmeta-mbl+repo%3AARMmbed%2Fmbl-manifest+repo%3AARMmbed%2Fmbl-core+repo%3AARMmbed%2Fmbl-cli+repo%3AARMmbed%2Fmbl-config+is%3Aopen

[meta-mbl]: https://github.com/ARMmbed/meta-mbl/tree/mbl-os-0.6
[mbl-core]: https://github.com/ARMmbed/mbl-core/tree/mbl-os-0.6
[mbl-tools]: https://github.com/ARMmbed/mbl-tools/tree/mbl-os-0.6
[mbl-manifest]: https://github.com/ARMmbed/mbl-manifest/tree/mbl-os-0.6
[mbl-config]: https://github.com/ARMmbed/mbl-config/tree/mbl-os-0.6
[mbl-cli]: https://github.com/ARMmbed/mbl-cli/tree/mbl-os-0.6