## Introduction

This document provides instructions for building Mbed Linux with the meta-mbl-reference-apps layer (which provides reference applications) and explains how to add a new reference application to the layer. 

1. [Building Mbed Linux OS with the meta-mbl-reference-apps layer](#build-mbed-linux-with-meta-mbl-reference-apps-layer).
1. [Adding new reference application to meta-mbl-reference-apps layer](#adding-new-reference-application).
1. [Links](#links).

## <a name="build-mbed-linux-with-meta-mbl-reference-apps-layer"></a> 1. Building Mbed Linux OS with the meta-mbl-reference-apps layer

The procedure is based on the [walkthrough document][mbl-walkthrough]. In order to build Mbed Linux OS with the meta-mbl-reference-apps layer, please follow these steps:

* Follow steps from 1 to 4 in the [walkthrough document][mbl-walkthrough].
* In [step 5][mbl-walkthrough-step5], please pull the `master` branch instead of the `alpha` branch, and use reference-apps.xml instead of restricted.xml. In order to do this, please replace the `repo init` command in step 5 by the following  command: 
```
repo init -u ssh://git@github.com/armmbed/mbl-manifest.git -b master -m reference-apps.xml
```
* All other steps after step 5 in the [walkthrough document][mbl-walkthrough] should remain unchanged.

## <a name="adding-new-reference-application"></a> 2. Adding new reference application to meta-mbl-reference-apps layer

In order to create a new reference application, please follow the following steps:
* Create a new repository that should contain sources for the new application. If you create a Git repository under  [github/ARMmbed](https://github.com/ARMmbed) organization, please view the ARM policies for the new git repositories. This new git repo should contain appropriate licensing and contributing information, and a readme file, that explains all important issues about the application, as well. An example of such a repository is https://github.com/ARMmbed/mbl-optee-secure-storage-app.
* Download Mbed Linux OS with the meta-mbl-reference-apps layer.
* Create a recipe (.bb) file in the appropriate location in the meta-mbl-reference-apps repository. This recipe should use the created source repository.
* Include the new package to the final image by appending the name of the package to `PACKAGEGROUP_MBL_TEST_PKGS` in `meta-mbl-reference-apps/recipes-core/packagegroups/packagegroup-mbl-test.bbappend`, or to `PACKAGEGROUP_MBL_PKGS` in `meta-mbl-reference-apps/recipes-core/packagegroups/packagegroup-mbl.bbappend`. Put attention that `PACKAGEGROUP_MBL_TEST_PKGS` should automatically include everything in `PACKAGEGROUP_MBL_PKGS`.

## <a name="links"></a> 3. Links

Please view [Mbed Linux OS walkthrough document][mbl-walkthrough], which provides instructions for building Mbed Linux with the meta-mbl-internal-extras layer and explains how to update your device's firmware.

[mbl-walkthrough]: walkthrough.md
[mbl-walkthrough-step5]: walkthrough.md#-5-download-the-yoctoopenembedded-meta-layers
