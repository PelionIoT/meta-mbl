# Introduction to Mbed Linux OS (MBL) OpenEmbedded Layer meta-mbl

This is the Mbed Linux OS [OpenEmbedded][openembedded-homepage] (OE) distribution for creating Mbed Linux OS IoT (Internet of Things) file system images.
Mbed Linux OS provides the software stack for a secure trusted execution environment for applications.

meta-mbl provides the layers and recipes for building the above software by leveraging the Yocto-OE-Bitbake ecosystem.
Here is an overview of the layers:

* `meta-mbl-distro` - MBL distribution layer including image recipes containing `mbl.conf`, `mbl-image*.bb` recipes and `*.wks files`.
* `meta-mbl-apps` -  	MBL applications e.g. mbl-cloud-client.
* `meta-mbl-bsp-common` - MBL layer for BSP (Board Support Platform) meta-data commonly used by more than one target BSP
* `*-mbl` - MBL staging layers for the community layers, containing MBL customizations. For example `meta-raspberrypi-mbl` is the staging layer for `meta-raspberrypi`.

The main components of the MBL distribution layer are:
* `meta-mbl-distro/conf/distro/mbl.conf` - This is the OE distribution configuration for creating an mbed linux distribution
* `meta-mbl-distro/recipes-core/images/mbl-image-development.bb` - This is the OE recipe for creating an image for testing and development.

For more information on the layers, please see the [BSP porting guide][mbl-bsp-guide].

## Documentation

Please see:

* The [release note][mbl-release-note] for information about the current release.
* The [website][mbl-documentation] for the documentation about Mbed Linux OS.
* Other technical and reference documentation can be found in this repository in the docs folder.
  * Please refer to the docs on the correct release branch - see the [release note][mbl-release-note].


## License

Please see the [License][mbl-license] document for more information.


## Contributing

Please see the [Contributing][mbl-contributing] document for more information.


[mbl-license]: LICENSE.md
[mbl-contributing]: CONTRIBUTING.md
[mbl-release-note]: docs/release_note.md
[mbl-bsp-guide]: docs/bsp-porting-guide.md
[mbl-documentation]: https://os.mbed.com/docs/mbed-linux-os/latest/welcome/index.html

[openembedded-homepage]: http://www.openembedded.org
