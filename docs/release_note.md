# Arm Mbed Linux OS Alpha Release

## Mbed Linux OS Alpha
We are pleased to announce that [Mbed Linux OS][mbl-linux-release] is now available for alpha testing.

### Content of Release
This initial Alpha release is intended for limited distribution to enable partners to validate the initial foundations of the Mbed Linux operating system. This release is built upon the OpenEmbedded build automation framework and uses versions of OpenEmbedded that are tagged for the Rocko release of the Yocto reference distribution.

1. Secure boot using a signed bootloader and firmware image on [NXP WaRP7][nxp-warp7]
2. Remote firmware and application updates when used in conjunction with [Mbed Cloud][mbed-cloud]
3. Support for deploying embedded applications as containers using [Docker][docker].
4. Support for the [OP-TEE][op-tee] Trusted Execution Engine.

#### Repositories
This release is made up of several repositories, the main ones are:

* [meta-mbl (alpha branch)][meta-mbl] - OpenEmbedded (OE) distribution layer for creating Mbed Linux OS IoT file system images.
* [mbl-app-qrcode (alpha branch)][mbl-app-qrcode] - reference application for reading QR codes to demonstrate the application workflow.

The significant supporting repositories are:

* [mbl-manifest (alpha branch)][mbl-manifest] - the repo manifest xml for Mbed Linux OS distributions.
* [mbl-config (alpha branch)][mbl-config] - configuration and environment files for Mbed Linux OS.
* [meta-mbl-restricted-extras (alpha_branch)][meta-mbl-restricted-extras] - restricted extra recipes including the Mbed Cloud client.

### Supported Modules
This release supports the following modules and platforms based on the microprocessors used by these modules.

* [NXP WaRP7][nxp-warp7]
* [Raspberry PI 3 Model B][rpi3-modelb]

### Tested Build Platforms
This release has been built and tested using Ubuntu Linux 16.04.

### Known issues
The following list of known issues apply to this release:

* OP-TEE is included but not currently used for secure key storage or secure services.
* IOTMBL-66: No network date/time support (ntp missing in distribution).
* IOTMBL-251: Docker container environment is unstable when using Video4Linux device driver on WaRP7.

#### Fixes and changes since last release

* None - this is the first release of the Mbed Linux OS.

### Using the release

Please refer to the [meta-mbl readme][mbl-readme] for links to the documentation.

Please feel free to ask any questions or provide feedback about this release via [mbed-linux-team@arm.com][mbl-team-email].


[mbl-readme]: https://github.com/ARMmbed/meta-mbl/blob/alpha/README.md
[mbl-linux-release]: https://github.com/ARMmbed/meta-mbl/releases/tag/alpha
[meta-mbl]: https://github.com/ARMmbed/meta-mbl/tree/alpha
[mbl-app-qrcode]: https://github.com/ARMmbed/mbl-app-qrcode/tree/alpha
[mbl-manifest]: https://github.com/ARMmbed/mbl-manifest/tree/alpha
[mbl-config]: https://github.com/ARMmbed/mbl-config/tree/alpha
[meta-mbl-restricted-extras]: https://github.com/ARMmbed/meta-mbl-restricted-extras/tree/alpha

[mbl-team-email]: mailto:mbed-linux-team@arm.com
[mbed-cloud]: https://cloud.mbed.com/docs/v1.2/introduction/update.html
[op-tee]: https://www.op-tee.org/
[docker]: https://www.docker.com/
[nxp-warp7]: https://www.nxp.com/support/developer-resources/reference-designs/warp7-next-generation-iot-and-wearable-development-platform:WARP7
[rpi3-modelb]: https://www.raspberrypi.org/products/raspberry-pi-3-model-b/
