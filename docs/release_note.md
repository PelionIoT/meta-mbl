# Arm Mbed Linux OS Alpha Release

## Mbed Linux OS Alpha
We are pleased to announce that [Mbed Linux OS][mbl-linux-release] is now available for alpha testing.

### Content of Release
This initial Alpa release is intended for limited distribution to enable partners to validate the initial foundations of the Mbed Linux operating system. This release is built upon the OpenEmbedded build automation framework and uses versions of OpenEmbedded that are tagged for the Rocko release of the Yocto reference distribution.

1. Secure boot using a signed bootloader and firmware image on [NXP WaRP7][nxp-warp7]
2. Remote firmware and application updates when used in conjunction with [Mbed Cloud][mbed-cloud]
3. Support for deploying embedded applications as containers using [Docker][docker].
4. Support for the [OP-TEE][op-tee] Trusted Execution Engine. [^1]

### Supported Modules
This release supports the following modules and platforms based on the microprocessors used by these modules.

* [NXP WaRP7][nxp-warp7]
* [Raspberry PI 3 Model B][rpi3-modelb]

### Tested Build Platforms
This release has been built and tested using Ubuntu Linux 16.04.

### Known issues
The following list of known issues apply to this release:

* IOTMBL-66: No network date/time support (ntp missing in distribution).
* IOTMBL-251: Docker container environment is unstable when using Video4Linux device driver on WaRP7.

#### Fixes and changes since last release

* None - this is the first release of the Mbed Linux OS.

### Using the release

Please refer to the [documentation][mbl-documentation].

Please feel free to ask any questions or provide feedback about this release via [mbed-linux-team@arm.com][mbl-team-email].

[^1]: OP-TEE is not currently used for secure key storage or secure services.

[mbl-documentation]: https://github.com/ARMmbed/meta-mbl/tree/alpha/docs
[mbl-linux-release]: https://github.com/ARMmbed/meta-mbl/releases/tag/alpha
[mbl-team-email]: mailto:mbed-linux-team@arm.com
[mbed-cloud]: https://cloud.mbed.com/docs/v1.2/introduction/update.html
[op-tee]: https://www.op-tee.org/
[docker]: https://www.docker.com/
[nxp-warp7]: https://www.nxp.com/support/developer-resources/reference-designs/warp7-next-generation-iot-and-wearable-development-platform:WARP7
[rpi3-modelb]: https://www.raspberrypi.org/products/raspberry-pi-3-model-b/
