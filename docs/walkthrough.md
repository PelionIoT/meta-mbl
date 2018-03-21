## Introduction

This document provides instructions for building Mbed Linux with the meta-mbl-internal-extras layer (which provides Mbed Cloud Client) and explains how to do a firmware update over the air. It describes the end-to-end process from preparing your environment to updating your device's firmware.

Warp7 and Raspberry Pi 3 boards are currently supported.

## Disclaimer

The Mbed Linux project is in its early developmental stages and information found in this document may become stale very quickly.

These instructions use the developer workflow and developer certificates.  Do not use this workflow for production devices.

## Workflow for building Mbed Linux and updating the firmware

To build Mbed Linux and do a firmware update over the air, follow these steps:

1. [Prepare your development environment](#prerequisites).
1. [Create a working directory](#create-working-directory).
1. [Download an Mbed Cloud dev credentials file](#get-cloud-credentials) that contains the credentials that the device can use to access your Mbed Cloud account.
1. [Create an Update resources file](#create-update-resources) that contains a certificate used by the device to authenticate new firmware packages.
1. [Download the required Yocto/OpenEmbedded "meta" layers](#get-meta-layers). This data contains rules for downloading and building the code for Mbed Linux.
1. [Set up the build environment](#set-up-build-env). This configures the build for the correct device and injects any user-specific data into the build.
1. [Build Mbed Linux](#build-mbl). This builds Mbed Linux and generates (a) an image that can be written directly to the device and (b) an image that can be used as a firmware update payload.
1. [Write the disk image to your device and boot Mbed Linux](#write-image-and-boot).
1. [Log in to Mbed Linux](#log-in).
1. [Set up a network connection](#set-up-network)
1. [Check if the device has connected to Mbed Cloud](#check-mbl-cc)
1. [Perform a firmware update](#do-update).

## <a name="prerequisites"></a> 1. Prepare your development environment

To build and run Mbed Linux using this guide you will need:

* A PC running Ubuntu 16.04.
* A development board, such as:
    * A **Warp7 board** with two micro USB cables - one to provide power to the Warp7 and one to connect the Warp7 to a PC.
    * A **Raspberry Pi 3 board** with a micro SD card and a C232HD-DDHSP-0 cable to connect it to a PC.
* An Mbed Cloud account (see [Getting an Mbed Cloud account](#get-cloud-account)).
* A Github account with access to private ARMmbed repositories.
* An SSH agent (required for cloning repositories non-interactively during the build process).
* To install:
    * Some software packages which are required to support Mbed Linux (see [Installing software dependencies](#install-software-dependencies)).
    * Google's `repo` tool (see [Installing Google's repo tool](#install-google-repo)).
    * Mbed's `manifest-tool` with the Mbed Cloud SDK library (see [Installing the manifest tool](#install-manifest-tool)).

### <a name="get-cloud-account"></a> 1.1. Getting an Mbed Cloud account

Contact Nadya.Sandler@arm.com or Jyri.Ryymin@arm.com to get an Mbed Cloud account.  You will need to let them know:
- Which team account to use, for example, arm-mbed-linux.
- That you are using Linux.
- That you need an account with a high firmware storage limit, as Mbed Linux firmware packages can be 40-50MiB.

### <a name="install-software-dependencies"></a> 1.2. Installing software dependencies

The following packages are required by software used later in this document:
* chrpath.
* curl.
* gawk.
* git.
* python-dev.
* texinfo.
* whiptail.

The command to install them will look something like this:

```
sudo apt-get install chrpath curl gawk git python-dev texinfo whiptail
```

### <a name="install-google-repo"></a> 1.3. Installing Google's repo tool

Install Google's [`repo` tool](https://gerrit.googlesource.com/git-repo) with the following commands:
```
mkdir ~/bin
PATH=~/bin:$PATH

curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
```

### <a name="install-manifest-tool"></a> 1.4. Installing the manifest tool

Install the Mbed Cloud manifest tool and Cloud SDK with the following commands:
```
pip install -U "git+https://github.com/ARMmbed/manifest-tool-restricted.git"
pip install mbed-cloud-sdk
```
See <https://github.com/ARMmbed/manifest-tool-restricted> for more information about the manifest tool.


## <a name="create-working-directory"></a> 2. Create a working directory for the Mbed Linux build
The examples in the document use a working directory (`~/mbl`) for the Mbed Linux build.  Create this working directory using the following command:
```
mkdir ~/mbl
```

## <a name="get-cloud-credentials"></a> 3. Download Mbed Cloud dev credentials file
During the build process, you will need a file that contains the credentials to connect your device to with Mbed Cloud. To create a **credentials C file** (`mbed_cloud_dev_credentials.c`) and download it to your working directory `~/mbl/cloud-credentials`, follow the instructions for [creating and downloading a developer certificate](https://cloud.mbed.com/docs/v1.2/provisioning-process/provisioning-development.html#creating-and-downloading-a-developer-certificate).

## <a name="create-update-resources"></a> 4. Create an Update resources file
Initialize `manifest-tool` settings and generate Update resources by running the following commands:
```
mkdir ~/mbl/manifests && cd ~/mbl/manifests
manifest-tool init -q -d arm.com -m dev-device
```
This generates a file `update_default_resources.c` that is required during the build process.

## <a name="get-meta-layers"></a> 5. Download the Yocto/OpenEmbedded "meta" layers
This data contains the rules for downloading and building code for Mbed Linux.  To download this data, use the following commands:

```
cd ~/mbl
mkdir mbl-alpha && cd mbl-alpha
repo init -u ssh://git@github.com/armmbed/mbl-manifest.git -b alpha -m restricted.xml
repo sync
```

## <a name="set-up-build-env"></a> 6. Set up the build environment

You need to configure your build environment for your device, including setting your working directory to the build directory (in this case `~/mbl/mbl-alpha/build-mbl`). To set up your build environment, use the following command:

```
MACHINE=<machine> DISTRO=<distro> . setup-environment
```
Select the {MACHINE, DISTRO} values for your Mbed Linux device from the table below:

| Device         | MACHINE          | DISTRO     |
| :---           | ---              | ---        |
| Warp7          | `imx7s-warp-mbl` | `mbl`      |
| Raspberry Pi 3 | `raspberrypi3`   | `mbl`      |

So, for example, to set up the build environment for a Warp7 board, your command would look like this:
```
MACHINE=imx7s-warp-mbl DISTRO=mbl . setup-environment
```

<span class="notes">**Note:** During the build process, make sure you are using this shell instance when running `bitbake` commands, as the set-up script changes bitbake settings by setting environment variables of the shell process.</span>

**Warning:**: Do not source the setup-environment script more that once in a terminal session. Invoking the script a second time can corrupt environment variables and cause `bitbake` commands to fail in unexpected places.

Copy your Mbed Cloud dev credentials file and Update resources file to the build directory, as follows:
```
cp ~/mbl/cloud-credentials/mbed_cloud_dev_credentials.c .
cp ~/mbl/manifests/update_default_resources.c .
```

## <a name="build-mbl"></a> 7. Build Mbed Linux

You will need the following files created during the build process:

* **A full disk image** This is a compressed image of the entire flash, created by the build process using the Wic tool from OpenEmbedded.  Once decompressed, this image can be directly written to storage media. See [this section](https://www.yoctoproject.org/docs/latest/mega-manual/mega-manual.html#creating-partitioned-images-using-wic) of the Yocto Mega Manual for more information about Wic. You will need this for [Step 8 Write the disk image to your device and boot Mbed Linux](#write-image-and-boot). You use the full disk image to initialize the device's storage with a full set of disk partitions and an initial version of firmware.
* **A root filesystem archive** This is a compressed tar archive, that you will need for a firmware update; see [Step 12 Performing a firmware update](#do-update). Once the device storage has been initialized, you can use the root file system archive to update the firmware, as this only requires a single root partition to be updated.

To generate these files, use the following command:

```
bitbake mbl-console-image
```
You will see several "WARNING" messages in the `bitbake` output - these are safe to ignore.

**File locations**

The paths of these files are given in the table below, where `<MACHINE>` should be replaced with the MACHINE value for your device from the table in [section 6](#set-up-build-env).

| Image type               | Path |
|--------------------------|------|
| Full disk image          | `~/mbl/mbl-alpha/build-mbl/tmp-mbl-glibc/deploy/images/<MACHINE>/mbl-console-image-<MACHINE>.wic.gz` |
| Root file system archive | `~/mbl/mbl-alpha/build-mbl/tmp-mbl-glibc/deploy/images/<MACHINE>/mbl-console-image-<MACHINE>.tar.xz` |

## <a name="write-image-and-boot"></a> 8. Write the disk image to your device and boot Mbed Linux

To enable firmware update, the full disk image contains a partition table and all the partitions required by Mbed Linux, including two root partitions. Only one of the root filesystem partitions is **active** at any one time, and the other is available to receive a new version of firmware during an update. At the end of the update process, the root partition with the new firmware becomes **active** and the other root partition becomes available to receive the next firmware update.  

This section contains instructions for writing the full disk image to a:

* Warp7 device
* Raspberry Pi 3 device

### 8.1. Write the full disk image to a Warp 7 device

To transfer your disk image to the Warp7's flash device, you must first access the Warp7's serial console. To do this:

1. Connect the Warp7's I/O USB socket (on the I/O board) to your PC and the Warp7's power USB socket (on the CPU board) to a USB power supply. From your PC you should then be able to see a USB TTY device, such as, `/dev/ttyUSB0`.
1. Connect to the Warp7's console using a command such as:
    ```
    minicom -D /dev/ttyUSB0
    ```
    Use the following settings:
    * A baud rate of 115200.
    * [8N1](https://en.wikipedia.org/wiki/8-N-1) encoding.
    * No hardware flow control.
1. Depending on the previous contents of the device's storage, you may get a U-boot prompt or you may see an operating system (e.g. Android) boot. If an operating system boots, reboot the device and then press a key when U-Boot starts, to prevent it booting the operating system.
1. To expose the Warp7's flash device to Linux as USB mass storage, when you get a U-Boot prompt, type:
    ```
    ums 0 mmc 0
    ```
    You should now see device files with `WaRP7` in their names in `/dev/disk/by-id` for the Warp7's flash device and its partitions. For example you might see something like:
    ```
    $ find /dev/disk/by-id -name '*WaRP7*'
    /dev/disk/by-id/usb-Linux_UMS_disk_0_WaRP7-0xcc2400d300000054-0:0-part7
    /dev/disk/by-id/usb-Linux_UMS_disk_0_WaRP7-0xcc2400d300000054-0:0-part5
    /dev/disk/by-id/usb-Linux_UMS_disk_0_WaRP7-0xcc2400d300000054-0:0-part3
    /dev/disk/by-id/usb-Linux_UMS_disk_0_WaRP7-0xcc2400d300000054-0:0-part2
    /dev/disk/by-id/usb-Linux_UMS_disk_0_WaRP7-0xcc2400d300000054-0:0-part6
    /dev/disk/by-id/usb-Linux_UMS_disk_0_WaRP7-0xcc2400d300000054-0:0-part1
    /dev/disk/by-id/usb-Linux_UMS_disk_0_WaRP7-0xcc2400d300000054-0:0-part4
    /dev/disk/by-id/usb-Linux_UMS_disk_0_WaRP7-0xcc2400d300000054-0:0
    $
    ```
    `mbl-console-image-imx7s-warp-mbl.wic.gz` is a full disk image so should be written to the whole flash device, not a partition. The device file for the whole flash device is the one without `-part` in the name (`/dev/disk/by-id/usb-Linux_UMS_disk_0_WaRP7-0xcc2400d300000054-0:0` in this example).
1. Ensure that none of the Warp7's flash partitions are mounted by running:
    ```
    sudo umount /dev/disk/by-id/*WaRP7*-part*
    ```
1. From a Linux prompt, write the disk image to the Warp7's flash device using the following command:
    ```
    gunzip -c ~/mbl/mbl-alpha/build-mbl/tmp-mbl-glibc/deploy/images/imx7s-warp-mbl/mbl-console-image-imx7s-warp-mbl.wic.gz | sudo dd status=progress conv=fsync bs=512 of=/dev/disk/by-id/<device-file-name>
    ```
    replacing `<device-file-name>` with the correct device file for the Warp7's flash device. This command can take about 20 minutes to complete and may appear to freeze while it is running.
1. When `dd` has finished eject the device:
    ```
    sudo eject /dev/sdX
    ```
1. On the Warp7's U-Boot prompt, press Ctrl-C to exit USB mass storage mode.
1. Reboot the Warp7 using the following command:
    ```
    reset
    ```
    The device should now boot into Mbed Linux.

### 8.2. Write the full disk image to a Raspberry Pi 3 device

1. Connect a micro SD card to your PC. You should see the SD card device file in `/dev`, probably as `/dev/sdX` for some letter `X` as well as device files for its partitions `/dev/sdXN` for some numbers `N`. The output of `lsblk` can be useful to identify the name of the device.
1. Ensure that none of the micro SD card's partitions are mounted by running:
    ```
    sudo umount /dev/sdX*
    ```
    replacing `/dev/sdX` with the correct device file name prefix for the SD card partitions.
1. Write the disk image to the SD card using the following command:
    ```
    gunzip -c ~/mbl/mbl-alpha/build-mbl/tmp-mbl-glibc/deploy/images/raspberrypi3/mbl-console-image-raspberrypi3.wic.gz | sudo dd status=progress conv=fsync bs=4M of=/dev/sdX
    ```
    replacing `/dev/sdX` with the correct device file for the SD card. This may take some time.
1. When `dd` has finished, eject the device:
    ```
    sudo eject /dev/sdX
    ```
1. Detach the micro SD card from your PC and plug it into the Raspberry Pi 3.
1. Before powering on the Raspberry Pi 3, connect it to your PC so that you can access its console. You can do this, for example, by connecting it using a [C232HD-DDHSP-0](http://www.ftdichip.com/Support/Documents/DataSheets/Cables/DS_C232HD_UART_CABLE.pdf) cable. Refer to our instructions on [how to connect that cable to your device](https://github.com/ARMmbed/raas-daemon/blob/master/doc/resources/ftdi-d2xx/HARDWARE.md).
1. Connect to the Raspberry Pi 3's console with something like:
    ```
    minicom -D /dev/ttyUSB0
    ```
    Use the following settings:
    * A baud rate of 115200.
    * [8N1](https://en.wikipedia.org/wiki/8-N-1) encoding.
    * No hardware flow control.
1. Connect the Raspberry Pi 3's micro USB socket to a USB power supply. It should now boot into Mbed Linux.

## <a name="log-in"></a> 9. Log in to Mbed Linux

To log in to Mbed Linux, enter the username `root` with no password.

## <a name="set-up-network"></a> 10. Set up a network connection

If your device is connected to a network with a DHCP server using Ethernet, then it automatically connects to that network. Otherwise, follow [the instructions](https://github.com/ARMmbed/meta-mbl/blob/master/docs/wifi.md) for setting up wifi in Mbed Linux.

## <a name="check-mbl-cc"></a> 11. Check if the device has connected to Mbed Cloud

While the device boots into Mbed Linux, `mbl-cloud-client` should automatically start and connect to Mbed Cloud. You can check whether it has connected by:

* Checking the device status on the [Mbed Cloud Portal](https://portal.mbedcloud.com/) ([Checking device status](#fig8)).
* Reviewing the log file for `mbl-cloud-client` at `/var/log/mbl-cloud-client.log`.

If your device hasn't automatically connected to Mbed Cloud, this may occur if networking wasn't configured before the device was rebooted or if there are issues with the network.  The device retries periodically, but you may need to restart `mbl-cloud-client`, as follows:
```
/etc/init.d/mbl-cloud-client restart
```

## <a name="do-update"></a> 12. Perform a firmware update using the Mbed Cloud Portal

To perform a firmware update using the Mbed Cloud Portal, follow these steps:

- 12.1. [Update Step 1](#update2-1): Prerequisites.
- 12.2. [Update Step 2](#update2-2): Upload a firmware image to the cloud.
- 12.3. [Update Step 3](#update2-3): Create a manifest.
- 12.4. [Update Step 4](#update2-4): Upload the manifest to the cloud.
- 12.5. [Update Step 5](#update2-5): Create a filter for your device.
- 12.6. [Update Step 6](#update2-6): Run a campaign to update the device firmware.

**How firmware gets updated**

The device has two banks of software:

- The running bank. A device partition storing the rootfs for the running system.
- The non-running bank. A device partition that will receive the firmware update.

You can use `lsblk` to check which partition is mounted at `/`.

During a firmware update, the update software:

- Writes the new software rootfs to the non-running bank.
- Sets the non-running bank to be the running bank next time the device boots.
- Reboots the device.

### <a name="update2-1"></a> 12.1. Update Step 1: Prerequisites

Before you upgrade the firmware on the device, make sure you:

* Have a root file system archive that contains the firmware upgrade.
* Have an Mbed Cloud account.
* Know which device partition is active (the running bank),so that you can check the upgrade has been successful.
* Have installed and initialized the `manifest-tool`.

### <a name="update2-2"></a> 12.2. Update Step 2: Upload a firmware image to Mbed Cloud

To upload your firmware update image to the Cloud:

- Log into the [Mbed Cloud Portal](https://portal.mbedcloud.com/login).
- On the **Firmware Update** tab, select **Images>Upload new images**.
- Select the update image on your local hard disk that contains the root file system image for upgrading. For a Warp7 device, for example, the update image will have a filename like this: `mbl-console-image-imx7s-warp-mbl-<date>.rootfs.tar.xz`.
- Provide a name for the firmware image, such as, "test\_image\_20180125\_1", and if required, a description.
- Press the **Upload firmware image** button.
- Copy the firmware image URL. You will need this URL to create the manifest (described in the next section).

### <a name="update2-3"></a> 12.3. Update Step 3: Create a manifest

To use the manifest-tool to create a manifest for the firmware image:

- Make sure the current working directory is where `manifest-tool init` was performed.
- Create a manifest called "test-manifest" by using the following command:
    ```
    manifest-tool create -p test-image -u http://firmware-catalog-media-8a31.s3.dualstack.eu-west-1.amazonaws.com/test-image -o test-manifest
    ```
    Where:
    - The **test-image** is a symlink to the full name of the image file to be used, such as, `mbl-console-image-imx7s-warp-mbl-20180124161247.rootfs.tar.xz`. The tool sometimes doesn't cope
  very well with long filenames.
    - The **-u URL** is the firmware image URL copied to the clipboard in the previous section.
    - The **test-manifest** is the name of the output manifest file.

### <a name="update2-4"></a> 12.4. Update Step 4: Upload the manifest to the Mbed Cloud

To upload the test-manifest to the Mbed Cloud:

- On the Mbed Cloud Portal, from the **Firmware Update** tab, select **Manifests>Upload new manifest**.
- Give the manifest a name, a description (if required) and select the manifest to use.

### <a name="update2-5"></a> 12.5. Update Step 5: Create a filter for your device

<span class= "notes"> **Note:** the device ID changes each time you load a new image onto the device.</span>

Before you can configure an update campaign, you need to create a device filter, as follows:

- To get the device ID, you can either:
    - Copy the device ID to the clipboard from the **Device Directory** tab, on Mbed Cloud Portal.
	  - Search for the device ID in the `mbl-cloud-client` log file `/var/log/mbl-cloud-client.log`, using the following command:
    ```
    grep -i 'device id' /var/log/mbl-cloud-client.log
    ```
- On Mbed Cloud Portal, from the **Device Directory** tab, select **Saved filters** and click **Create New Filter**.
- Click **Add attribute** and select **Device ID**.
- Paste the Device ID into the Device ID edit box and click **Save Filter**.

### <a name="update2-6"></a> 12.6. Update Step 6: Run an update campaign

To create a campaign to update the firmware on a device:

- On the Mbed Cloud Portal, from the **Firmware Update** tab, select **Update campaigns>Create campaign**.
- Provide:
    * A name for the campaign.
    * A description (optional).
- Select the:
    * Manifest file (in this example, `test-manifest`).
    * Device filter created in update step 5.
- Click **Save** to create the new update campaign.

To run your update campaign:

- On the **Firmware update** tab, select **Update campaigns** and find your update campaign from the list.
- Press **Start** to run your test campaign.
    - The firmware update process may take a while to complete.
    - On the device, you can monitor the device console to see the update occurring using `tail -f /var/log/mbl-cloud-client.log` .
    - On the Mbed Cloud Portal, as the campaign progresses, it reports the **Publishing** state.
- Once the firmware update is complete, the device reboots.
- When the device comes up, login and verify that the running bank (partition) has changed from that noted in update step 1.


 #### 12.2.7. Figures

<a name="fig1"></a>
![fig1](pics/01.png "Figure 1")
Figure 1: The mbed cloud portal login.

<a name="fig2"></a>
![fig2](pics/02.png "Figure 2")
Figure 2: Select the team you want to use e.g. arm-mbed-linux.

<a name="fig3"></a>
![fig3](pics/03.png "Figure 3")
Figure 3: Dashboard after you login.

<a name="fig4"></a>
![fig4](pics/04.png "Figure 4")
Figure 4: Firmware update/Images screen.

<a name="fig5"></a>
![fig5](pics/05.png "Figure 5")
Figure 5: Firmware update/Images screen showing how to copy URL.

<a name="fig6"></a>
![fig6](pics/06.png "Figure 6")
Figure 6: Upload firmware image screen.

<a name="fig7"></a>
![fig7](pics/07.png "Figure 7")
Figure 7: Device details screen.

<a name="fig8"></a>
![fig8](pics/08.png "Figure 8")
Figure 8: Device directory screen for viewing device registration status and adding device filters.

<a name="fig9"></a>
![fig9](pics/09.png "Figure 9")
Figure 9: Device directory for adding a filter device id attribute.

<a name="fig10"></a>
![fig10](pics/10.png "Figure 10")
Figure 10: Device directory for adding a filter.

<a name="fig11"></a>
![fig11](pics/11.png "Figure 11")
Figure 11: Saved filters screen.

<a name="fig12"></a>
![fig12](pics/12.png "Figure 12")
Figure 12: Update campaigns screen.

<a name="fig13"></a>
![fig13](pics/13.png "Figure 13")
Figure 13: New update campaign screen.

<a name="fig14"></a>
![fig14](pics/15.png "Figure 14")
Figure 14: Firmware update/Campaign status screen.

<a name="fig15"></a>
![fig15](pics/16.png "Figure 15")
Figure 15: Test campaign details screen.
