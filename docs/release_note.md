# Arm Mbed Linux OS Alpha Release

## Mbed Linux OS Alpha
We are pleased to announce that [Mbed Linux OS](https://github.com/ARMmbed/meta-mbl/releases/tag/XXX) is now available for alpha testing.

### Content of Release
This initial Alpa release is intended for limited distribution to enable partners to validate the initial foundations of the Mbed Linux operating system. This release is built upon the OpenEmbedded build automation framework and uses versions of OpenEmbedded that are tagged for the Rocko release of the Yocto reference distribution. 

1. Secure boot using a signed bootloader and firmware image on [NXP WaRP7](https://www.nxp.com/support/developer-resources/reference-designs/warp7-next-generation-iot-and-wearable-development-platform:WARP7)
2. Remote firmware and application updates when used in conjunction with [Mbed Cloud](https://cloud.mbed.com/docs/v1.2/introduction/update.html)
3. Support for deploying embedded applications as containers using Docker.
4. Support for the [OP-TEE](https://www.op-tee.org/) Trusted Execution Engine.

### Supported Modules
This release supports the following modules and platforms based on the microprocessors used by these modules.

* [NXP WaRP7](https://www.nxp.com/support/developer-resources/reference-designs/warp7-next-generation-iot-and-wearable-development-platform:WARP7)
* [Raspberry PI 3 Model B](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)

### Tested Build Platforms
This release has been tested on Ubuntu Linux 16.04.

### Known issues
The following list of known issues apply to this release:

* Bug:XYZ The container environment is currently unstable and containers can become corrupt.

#### Fixes and changes since last release

* None - this is the first release of the Mbed Linux OS.

### Using the release 

Please feel free to ask any questions or provide feedback about this release via support@mbed.org.
