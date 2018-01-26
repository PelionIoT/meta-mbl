## Introduction

This document provides instructions for building Mbed Linux with the meta-mbl-private layer (which provides Mbed Cloud Client) and for performing an over-the-air firmware update.

### Only the Warp7 board is currently supported. Ignore the Raspberry Pi 3 sections

## Disclaimer

The Mbed Linux project is in its early stages and information found in this document may become stale very quickly. The `jh-unstable` branches of repositories used in these instructions contain hacks and unreviewed code.

### Only the Warp7 board is currently supported. Ignore the Raspberry Pi 3 sections

## Getting an Mbed Cloud account

Contact Nadya.Sandler@arm.com or Jyri.Ryymin@arm.com to get an Mbed Cloud account. 
- You should report which account to use e.g. arm-mbed-linux.
- You should say your environment is Linux.
- You should request an account with a high firmware storage limit - Mbed Linux firmware packages can be 40-50MiB.

## Create a working directory for the Mbed Linux build
This document will assume that you have a directory `~/mbl` under which all work will be done.

## Download Mbed Cloud dev credentials file
Follow instructions at https://cloud.mbed.com/docs/v1.2/provisioning-process/provisioning-development.html#creating-and-downloading-a-developer-certificate to create and download a "credentials C file" (`mbed_cloud_dev_credentials.c`) to a directory `~/mbl/cloud-credentials`. This contains credentials for your device to connect to with Mbed Cloud and will be required during the build process.

## Create an Update resources file
Follow instructions at https://cloud.mbed.com/docs/v1.2/updating-firmware/manifest-tutorial.html to install `manifest-tool`, then generate Update resources by running
```
mkdir ~/mbl/manifests && cd ~/mbl/manifests
manifest-tool init -q -d arm.com -m dev-device
```
This will generate a file `update_default_resources.c` that will be required during the build process.

## Download the required Yocto/OpenEmbedded "meta" layers
```
cd ~/mbl
mkdir mbl-unstable && cd mbl-unstable
repo init -u git@github.com/armmbed/mbl-manifest.git -b jh-unstable -m private.xml
repo sync
```

## Set up the build environment
To setup the building environment for Warp7, use the following command to source the environment setup script with the MACHINE an DISTRO variable defined:
```
MACHINE=imx7s-warp-mbl DISTRO=mbl . setup_environment
```

The following table lists the {MACHINE, DISTRO} values for the Mbed Linux supported devices. Use the appropriate values for the device of interest. 


| Device         | MACHINE          | DISTRO     |
| :---           | ---              | ---        |
| Warp7          | `imx7s-warp-mbl` | `mbl` |
| Raspberry Pi 3 | `raspberrypi3`   | `mbl`      |

This command should change your working directory to the "build directory" `~/mbl/mbl-unstable/build-mbl`. It also sets some environment variables that will affect how `bitbake` behaves, so ensure that you are using this shell instance when running any `bitbake` commands later.


Copy the Mbed Cloud dev credentials file and the Update resources file to the build directory:
```
cp ~/mbl/cloud-credentials/mbed_cloud_dev_credentials.c .
cp ~/mbl/manifests/update_default_resources.c .
```


Set the Wifi SSID for the device to use:
```
echo 'MBL_WIFI_SSID="Guest-AccessNG"' >> conf/local.conf
```

Currently only open Wifi networks are supported.

## Build Mbed Linux
```
bitbake mbl-console-image
```

This command will generate two files that we are interested in:
* a full disk image file which will be written to the device's flash storage;
* a root file system archive which is used for firmware updates.

The paths of these files are

| Warp7                    |     |
| :---                     | --- |
| full disk image          | ~/mbl/mbl-unstable/build-mbl/tmp-mbl-glibc/deploy/images/imx7s-warp-mbl/mbl-console-image-imx7s-warp-mbl.wic.gz |
| root file system archive | ~/mbl/mbl-unstable/build-mbl/tmp-mbl-glibc/deploy/images/imx7s-warp-mbl/mbl-console-image-imx7s-warp-mbl.tar.xz |

| Raspberry Pi 3           |     |
| :---                     | --- |
| full disk image          | ~/mbl/mbl-unstable/build-mbl/tmp-mbl-glibc/deploy/images/raspberrypi3/mbl-console-image-raspberrypi3.rpi-sdimg |
| root file system archive | ~/mbl/mbl-unstable/build-mbl/tmp-mbl-glibc/deploy/images/raspberrypi3/mbl-console-image-raspberrypi3.tar.bz2 |


## Write the disk image to your device and boot Mbed Linux ##

### Warp 7
To transfer your disk image to the Warp7's flash device, you must first access the Warp7's serial console. To do this, connect the Warp7's I/O USB socket (on the I/O board) to your PC and the Warp7's power USB socket (on the CPU board) to a USB power supply. From your PC you should then be able to see a USB TTY device at e.g. /dev/ttyUSB0.

Connect to the Warp7's console with something like
```
minicom -D /dev/ttyUSB0
```
You should see a U-Boot prompt.  At the U-Boot prompt, type
```
ums 0 mmc 0
```
to expose the Warp7's flash device to Linux as USB mass storage. You should now see the Warp7's flash device in `/dev`, probably as `/dev/sdX` for some letter `X`. The output of `lsblk` can be useful to identify the name of the device.

From a Linux prompt Write the disk image to the Warp7's flash device with
```
gunzip -c ~/mbl/mbl-unstable/build-mbl/tmp-mbl-glibc/deploy/images/imx7s-warp-mbl/mbl-console-image-imx7s-warp-mbl.wic.gz | sudo dd status=progress conv=fsync bs=4M of=/dev/sdX
```
replacing `/dev/sdX` with the correct device file for the Warp7's flash device. This may take some time.


When `dd` has finished eject the device:
```
eject /dev/sdX
```

Back on the Warp7's U-Boot prompt, press Ctrl-C to exit USB mass storage mode, then type
```
reset
```
to reboot the Warp7. It should now boot into Mbed Linux.

### Raspberry Pi 3

Connect a micro SD card to your PC. You should see the SD card device file in `/dev`, probably as `/dev/sdX` for some letter `X`. The output of `lsblk` can be useful to identify the name of the device.

Write the disk image to the SD card with
```
sudo dd status=progress conv=fsync bs=4M if=~/mbl/mbl-unstable/build-mbl/tmp-mbl-glibc/deploy/images/raspberrypi3/mbl-console-image-raspberrypi3.rpi-sdimg of=/dev/sdX
```
replacing `/dev/sdX` with the correct device file for the SD card. This may take some time.

When `dd` has finished eject the device:
```
eject /dev/sdX
```

Detach the micro SD card from your PC and plug it into the Raspberry Pi 3.

Before powering on the Raspberry Pi 3, you will need to connect it to your PC such that you can access its console. You can do this e.g. by connecting it via a [C232HD-DDHSP-0](http://www.ftdichip.com/Support/Documents/DataSheets/Cables/DS_C232HD_UART_CABLE.pdf) cable. See [here](https://github.com/ARMmbed/raas-daemon/blob/master/doc/resources/ftdi-d2xx/HARDWARE.md) for instructions on how to connect that cable to your device.

Connect to the Raspberry Pi 3's console with something like
```
minicom -D /dev/ttyUSB0
```

Now connect the Raspberry Pi 3's micro USB socket to a USB power supply. It should now boot into Mbed Linux.

## Log in to Mbed Linux 

To log in, use the username `root` with no password.

During Mbed Linux boot, `mbl-cloud-client` should automatically start and connect to the Mbed Cloud. You can check this by using the Mbed Cloud web interface or by reviewing `mbl-cloud-client`'s log file at `/var/log/mbl-cloud-client.log`.

## Perform a firmware update

The following sections describe 2 ways to perform an update:

- **Method 1.** Using the manifest-tool. The development machine runs the manifest-tool to request a firmware update via a web API.
- **Method 2.** Using the mbed-cloud web interface. A firmware update is initiated using the mbed cloud web interface.

Note:  at the current time developers are unable to use Method 1 due to a problem (a bug?) using API keys. Therefore, the following section should be skipped in preference for Method 2, which works fine.


### Method 1: Perform a Firmware Update Using the Manifest-Tool.

After a firmware update, the flash partition used for the root filesystem will change. Check which partition is mounted at `/` now so that you can check that it changes after the update. You can use `lsblk` to do this.

The easiest way to update firmware on a single device is to use manifest-tool. To use the manifest tool for firmware updates you may need to install an additional package, [the Python mbed-cloud-sdk](https://github.com/ARMmbed/mbed-cloud-sdk-python):
```
pip install mbed-cloud-sdk
```

You will also need an Mbed Cloud API key. Follow the instructions at https://cloud.mbed.com/docs/v1.2/connecting/api-keys.html#generating-an-api-key to generate an API key for the "Administrators" group, then create the file `~/mbl/manifests/.mbed_cloud_config.json` with the following content
```
{
    "api_key": "<api-key>"
}
```
replacing `<api-key>` with the key obtained earlier.

The firmware "payload" used for updates is the "root filesystem archive" generated during the Mbed Linux build process. I've noticed that `manifest-tool` sometimes barks if the path to the firmware image is too long, so link this file into the manifests directory with

| Device         | Command |
| ---            | --- |
| Warp 7         | `ln -s ~/mbl/mbl-unstable/build-mbl/tmp-mbl-glibc/deploy/images/imx7s-warp-mbl/mbl-console-image-imx7s-warp-mbl.tar.xz test-image` |
| Raspberry Pi 3 | `ln -s ~/mbl/mbl-unstable/build-mbl/tmp-mbl-glibc/deploy/images/raspberrypi3/mbl-console-image-raspberrypi3.tar.bz2 test-image` |


Now perform the update with
```
cd ~/mbl/manifests
manifest-tool update device -p test-image --manifest-name test-manifest --payload-name test-image --device-id <device ID>
```
replacing `<device ID>` with the device's ID. The ID can be found by looking on the Mbed Cloud web interface or by looking in `mbl-cloud-client`'s log file on the device:
```
grep -i 'device id' /var/log/mbl-cloud-client.log
```
Note that the device ID may change if a new disk image is written to the flash.

Example `manifest-tool` output:
```
$ manifest-tool update device -p test-image --manifest-name test-manifest --payload-name test-image --device-id 0161292331c700000000000100100246
[INFO] 2018-01-25 10:10:03 - manifesttool.update_device - Created new firmware at http://firmware-catalog-media-ca57.s3.dualstack.us-east-1.amazonaws.com/test-image
[INFO] 2018-01-25 10:10:03 - manifesttool.update_device - Created temporary manifest file at /tmp/tmpOoloXY/manifest
[INFO] 2018-01-25 10:10:04 - manifesttool.update_device - Created new manifest at http://firmware-catalog-media-ca57.s3.dualstack.us-east-1.amazonaws.com/manifest_BytWSLL
[INFO] 2018-01-25 10:10:05 - manifesttool.update_device - Campaign successfully created. Current state: 'draft'
[INFO] 2018-01-25 10:10:05 - manifesttool.update_device - Campaign successfully created. Filter result: {'id': {u'$eq': '0161292331c700000000000100100246'}}
[INFO] 2018-01-25 10:10:05 - manifesttool.update_device - Starting the update campign...
[INFO] 2018-01-25 10:10:05 - manifesttool.update_device - Campaign successfully started. Current state: u'scheduled'. Checking updates..
[INFO] 2018-01-25 10:10:06 - manifesttool.update_device - Current state: 'publishing'
[INFO] 2018-01-25 10:16:03 - manifesttool.update_device - Current state: 'deployed'
```

Once the manifest-tool indicates that the current state has changed to "Publishing" you can follow the update progress in `mbl-cloud-client`'s log file:
```
tail -f /var/log/mbl-cloud-client.log
```
When the update has finished the device should reboot into the new firmware. You can check that this has happened by checking that the flash partition mounted at `/` is different to before the update.


A short time after the new firmware has booted, `manifest-tool` should report that the state has changed from 'Publishing' to 'Deployed'.


### Method 2: Perform a firmware update Using the Mbed Cloud Web Interface

This section describes how to preform a device firmware update using the mbed cloud web interface. The following steps
are described in the following sections:

- Step 1: Prerequisites.
- Step 2: Upload a firmware image to the cloud.
- Step 3: Create a manifest.
- Step 4: Upload the manifest to the cloud.
- Step 5: Create a filter for your device.
- Step 6: Run an update campaign to update the device firmware.


#### Step 1: Prerequisites

The following should have already been performed:
- A build generating a device image.
- You have a set of mbed Cloud account credentials so you can log in.
- You've checked which is the currently running bank. This will change after a firmware update
  and should be checked before and after the update to verify the new firmware is running.

The following provides information on how to check which is the running bank (partition).
The device has 2 banks of software:
- The running bank. A device partition storing the rootfs for the running system.
- The non-running bank. A device partition that will receive the firmware update.

The process of performing a firmware update includes the following steps:
- The update SW writes the non-running bank with the new software rootfs.
- The update SW sets the non-running bank to be the running bank next time the device boots.
- The update SW reboots the device.

Check which partition is mounted at `/` now so that you can check that it changes after the update.
You can use `lsblk` to do this.


#### Step 2: Upload a Firmware Image to the Cloud

This requires the following steps:
- Log into the med cloud portal e.g. at the following link https://portal-os2.mbedcloudstaging.net/login.
- If more than one team is available, select a team/group e.g. arm-mbed-linux.
- Navigate to the Firmware Update/Images screen.
- Select Upload new images
- Choose an image file from your local hard disk. This should be the mbl-console-image-imx7s-warp-mbl-<date>.rootfs.tar.xz, which contains the root file system image for upgrading. 
- Provide a name for the firmware image e.g. test\_image\_20180125\_1.
- Optionally, provide a description.
- Press the "Upload firmware image" button.
- On the main Firmware Update/Images screen you'll see the image listed in the table.
- Copy the firmware image URL (2nd column in table) to your clipboard URL by clicking the "2 page" icon in the third column of the table. This URL will be needed for creating the manifest (described in the next section).


#### Step 3: Create a Manifest

This step describes how to use the manifest-tool to create a manifest for the firmware image:
- In the section "Create an Update resources file" earlier in this document, you will have: 
    - Installed the `manifest-tool`,
    - Created the ~mbl/manifest sub-directory, and 
    - Performed the `manifest-tool init` command.
- Make the current working directory the place where the `manifest-tool init` was performed.  
- Create a manifest called test-manifest by using the manifest-tool in the following way:
```
manifest-tool create -p test-image -u http://firmware-catalog-media-8a31.s3.dualstack.eu-west-1.amazonaws.com/test-image -o test-manifest
```
- The **test-image** is a symlink to the full name of the image file to be used e.g.
  mbl-console-image-imx7s-warp-mbl-20180124161247.rootfs.tar.xz. The tool sometimes doesn't cope
  very well with long filenames.
- The **-u URL** is the image URL copied to the clipboard in the previous section.
- The **test-manifest** is the name of the output manifest file.


#### Step 4: Upload the Manifest to the Cloud.

This requires the following steps to upload the test-manifest to the cloud:
- Navigate to the Firmware Update/Manifests screen
- Push the "Upload new manifest" button
- Press the "Chose File" button to select the test-manifest from your local filesystem
- Give the manifest a name e.g. test-manifest
- Optionally provide a description of the manifest
- Push the "Upload firmware manifest" button.


#### Step 5: Create a filter for your device

A device filter has to be created before an update campaign can be configure. This is done in the following way:
- Navigate to the Device Directory screen.
- Copy the device id to the clipboard. This can be done as follows:
	- Search for the device id in the device /var/log/mbl-cloud-client.log.
```
grep -i 'device id' /var/log/mbl-cloud-client.log
```
	Note the device id changes each time you load a new image onto the device.
	- By finding the device in the table presented on the Device Directory screen, clicking on it to get the device specific
	information page and then copying the device ID to the clipboard.
- Push the "Create New Filter" button.
- Push the "Add attribute" button and select "Device ID".
- Paste the Device ID into the Device ID edit box and click "Save Filter".
- See that the newly created filter reported on the Device Directory/Saved Filters screen.

#### Step 6: Run an Update Campaign to Update the Device Firmware

The following steps are needed to run a test campaign to perform the firmware update:
- Navigate to the Firmware Update/Update Campaigns screen.
- Push the "Create Campaign" button.
- Provide a name for the campaign e.g. "test-campaign".
- Optionally provide a description.
- Select the previously created test-manifest from the first drop down list box.
- Select the previously created test-filter from the second drop down list box. The device filter should report the Device ID of your device.
- Push the "Save" button to save the test campaign.
- The saved test-campaign will be reported on the screen. Press the "Start" button to run the test campaign.
	- You may see the "Something went wrong" screen indicating problems with the update service. Be patient! This kind of thing seems normal. However, sometimes things have gone wrong and the update will not happen.
- Monitor the device console tail -f /var/log/mbl-cloud-client.log to see the update occurring.
	- You can also monitor the progress of the update via the web interface. It should report the "Publishing" state.
- After considerable console output, the update will complete and the device reboots.
- When the device comes up again, login and verify that the running bank (partition) has changed from that noted in Step 1.


 #### Figures

![fig1](pics/01.png "Figure 1")
Figure 1: The mbed cloud portal login.

![fig2](pics/02.png "Figure 2")
Figure 2: Select the team you want to use e.g. arm-mbed-linux.

![fig3](pics/03.png "Figure 3")
Figure 3: Dashboard after you login.

![fig4](pics/04.png "Figure 4")
Figure 4: Firmware update/Images screen.

![fig5](pics/05.png "Figure 5")
Figure 5: Firmware update/Images screen showing how to copy URL.

![fig6](pics/06.png "Figure 6")
Figure 6: Upload firmware image screen.

![fig7](pics/07.png "Figure 7")
Figure 7: Device details screen.

![fig8](pics/08.png "Figure 8")
Figure 8: Device directory for adding a filter screen.

![fig9](pics/09.png "Figure 9")
Figure 9: Device directory for adding a filter device id attribute.

![fig10](pics/10.png "Figure 10")
Figure 10: Device directory for adding a filter.

![fig11](pics/11.png "Figure 11")
Figure 11: Saved filters screen.

![fig12](pics/12.png "Figure 12")
Figure 12: Update campaigns screen.

![fig13](pics/13.png "Figure 13")
Figure 13: New update campaign screen.

![fig14](pics/15.png "Figure 14")
Figure 14: Firmware update/Update campaigns screen.

![fig15](pics/16.png "Figure 15")
Figure 15: Test campaign details screen.