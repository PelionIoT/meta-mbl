# Introduction to Mbed Linux OS (MBL) OpenEmbedded Layer meta-mbl

This is the Mbed Linux OS [OpenEmbedded][openembedded-homepage] (OE) distribution for creating Mbed Linux OS IoT (Internet of Things) file system images.
Mbed Linux OS provides the software stack for a secure trusted execution environment for applications and gateways.

meta-mbl provides the layers and recipes for building the above software by leveraging the Yocto-OE-Bitbake ecosystem.
Here is an overview of the layers:

* `meta-mbl-distro` - MBL distribution layer including image recipes containing `mbl.conf`, `mbl-image*.bb` recipes and `*.wks files`.
* `meta-mbl-apps` -  	MBL applications e.g. mbl-cloud-client.
* `meta-mbl-bsp-common` - MBL layer for BSP (Board Support Platform) meta-data commonly used by more than one target BSP.
* `*-mbl` - MBL staging layers for the community layers, containing MBL customizations. For example `meta-raspberrypi-mbl` is the staging layer for `meta-raspberrypi`.

The main components of the MBL distribution layer are split into development and production:

* Development - distribution and image for development with Mbed Linux OS.
    * `meta-mbl-distro/conf/distro/mbl-development.conf` - The OE distribution configuration for development.
    * `meta-mbl-distro/recipes-core/images/mbl-image-development.bb` - The OE recipe for creating a development image.
* Production - distribution and image for a production version of Mbed Linux OS.
    * `meta-mbl-distro/conf/distro/mbl-production.conf` - The OE distribution configuration for production.
    * `meta-mbl-distro/recipes-core/images/mbl-image-production.bb` - The OE recipe for creating a production image.

For more information on the layers, please see the [BSP porting guide][mbl-bsp-guide].

## Documentation

Please see:

* The [release note][mbl-release-note] for information about the current release.
* The [website][mbl-documentation] for the documentation about Mbed Linux OS.
* Other technical and reference documentation can be found in this repository in the docs folder.
    * Please refer to the docs on the correct release branch - see the [release note][mbl-release-note].

## Branches

We recommend you use the latest release branches - `mbl-os-*` - of all Mbed Linux OS repositories when working with Mbed Linux OS.
The [release note][mbl-release-note] and [website][mbl-documentation] will cover how to work with the latest release.

Alternatively, you can use the latest development version by using the `warrior-dev` branches of the Mbed Linux OS repositories.
These branches are based on the stable Yocto release `warrior`, but include our on-going development changes.
Replace the release branch name of `mbl-os-*` with `warrior-dev` when using the above documentation.

Our `master` branches of the Mbed Linux OS repositories are tracking the upstream Yocto master branches.
There is no guarantee that these branches will build or run correctly, and they may not contain the same features as `warrior-dev`.
We do not advise that you work with the `master` branches, and instead please use our releases or `warrior-dev`.


## License

Please see the [License][mbl-license] document for more information.


## Contributing

Please see the [Contributing][mbl-contributing] document for more information.


[mbl-license]: LICENSE.md
[mbl-contributing]: CONTRIBUTING.md
[mbl-release-note]: docs/release_note.md
[mbl-bsp-guide]: https://os.mbed.com/docs/mbed-linux-os/latest/develop-mbl/board-support-package-porting.html
[mbl-documentation]: https://os.mbed.com/docs/mbed-linux-os/latest/welcome/index.html

[openembedded-homepage]: http://www.openembedded.org
