# Introduction to Mbed Linux OS (mbl) OpenEmbedded Layer meta-mbl

This is the Mbed Linux OS [OpenEmbedded][openembedded-homepage] (OE) distribution layer for creating Mbed Linux OS IoT file system images.
Mbed Linux OS provides the software stack for a secure trusted execution environment for applications.

meta-mbl provides the recipes for building the above software by leveraging the Yocto-OE-Bitbake ecosystem.
The main components of the layer are:

* ```meta-mbl/conf/distro/mbl.conf``` - This is the OE distribution configuration for creating an mbed linux distribution
* ```meta-mbl/recipes-core/images/mbl-image-development.bb``` - This is the OE recipe for creating a minimal image for testing and development.


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
[mbl-documentation]: https://os.mbed.com/docs/mbed-linux-os/latest/welcome/index.html

[openembedded-homepage]: http://www.openembedded.org
