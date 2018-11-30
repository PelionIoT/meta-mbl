# Introduction to Mbed Linux OS (mbl) OpenEmbedded Layer meta-mbl

This is the Mbed Linux OS [OpenEmbedded][openembedded-homepage] (OE) distribution layer for creating Mbed Linux OS IoT file system images.
Mbed Linux OS provides the software stack for a secure trusted execution environment for applications.

meta-mbl provides the recipes for building the above software by leveraging the Yocto-OE-Bitbake ecosystem.
The main components of the layer are:

* ```meta-mbl/conf/distro/mbl.conf``` - This is the OE distribution configuration for creating an mbed linux distribution
* ```meta-mbl/recipes-core/images/mbl-console-image-test.bb``` - This is the OE recipe for creating a minimal image for testing and evaluation.


## Documentation

Please see:

* The [release note][mbl-release-note] for information about this release.
* The [introduction][mbl-introduction] for an overview of Mbed Linux OS and its features.
* The [getting started guide][mbl-start-guide] to jump right in and get started.
* Other technical and reference documentation can be found in this repository in the docs folder.


## License

Please see the [License][mbl-license] document for more information.


## Contributing

Please see the [Contributing][mbl-contributing] document for more information.


[mbl-license]: LICENSE.md
[mbl-contributing]: CONTRIBUTING.md
[mbl-release-note]: docs/release_note.md
[mbl-start-guide]: https://os.mbed.com/docs/linux-os/latest/getting-started/index.html
[mbl-introduction]: https://os.mbed.com/docs/linux-os/latest/welcome/index.html

[openembedded-homepage]: http://www.openembedded.org
