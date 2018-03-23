# Introduction to Mbed Linux OS (mbl) OpenEmbedded Layer meta-mbl

This is the Mbed Linux OS [OpenEmbedded][openembedded-homepage] (OE) distribution layer for creating Mbed Linux OS IoT file system images.
Mbed Linux OS provides the software stack for a secure trusted execution environment for applications. This is
built using the following main components:
* The bootloader chain (Broadcom bootloader and/or u-boot for example).
* [OP-TEE][optee-homepage].
* [Docker][docker-homepage].

meta-mbl provides the recipes for building the above software by leveraging the Yocto-OE-Bitbake ecosystem.
The main components of the layer are:
* meta-mbl/conf/mbl.conf. This is the OE distribution configuration for creating an mbed linux distribution
* meta-mbl/recipes-core/images/mbl-console-image.bb. This is the OE recipe for creating a minimal image.


## Documentation
Please see:
* The [Release Note][mbl-release-note] for information about this release.
* The [walkthrough][mbl-walkthrough] for instructions on building mbl and performing over-the-air updates.
* The [WaRP7 image signing instructions][mbl-image-signing-w7] for instructions on signing mbl images for WaRP7 devices and setting up WaRP7 devices to verify image signatures.
* The [mbl-app-qrcode README][mbl-app-qrcode-readme] for instructions on building and running an example application on mbl.
* The [Wi-Fi instructions][mbl-wifi] for setting up Wi-Fi on the IoT device.
* The [troubleshooting document][mbl-troubleshooting] for troubleshooting tips.
* The [Logs][mbl-logs] document for information about Mbed Linux OS's log files.


## License

Please see the [License][mbl-license] document for more information.


## Contributing

Please see the [Contributing][mbl-contributing] document for more information.


[mbl-license]: LICENSE.md
[mbl-contributing]: CONTRIBUTING.md
[mbl-walkthrough]: docs/walkthrough.md
[mbl-image-signing-w7]: docs/warp7-image-signing.md
[mbl-app-qrcode-readme]: https://github.com/ARMmbed/mbl-app-qrcode
[mbl-wifi]: docs/wifi.md
[mbl-troubleshooting]: docs/troubleshooting.md
[mbl-release-note]: docs/release_note.md
[mbl-logs]: docs/logs.md

[optee-homepage]: https://github.com/op-tee/optee_os
[docker-homepage]: https://www.docker.com
[openembedded-homepage]: http://www.openembedded.org
