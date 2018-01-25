## Intoduction

This document provides instructions for building Mbed Linux with the meta-mbl-private layer (which provides Mbed Cloud Client) and for performing an over-the-air firmware update.

### Only the Warp7 board is currently supported. Ignore the Raspberry Pi 3 sections

## Disclaimer

The Mbed Linux project is in its early stages and information found in this document may become stale very quickly. The `jh-unstable` branches of repositories used in these instructions contain hacks and unreviewed code.

### Only the Warp7 board is currently supported. Ignore the Raspberry Pi 3 sections

## Getting an Mbed Cloud account

Contact Nadya.Sandler@arm.com or Jyri.Ryymin@arm.com to get an Mbed Cloud account. You'll need an account with a high firmware storage limit - Mbed Linux firmware packages can be 40-50MiB.

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
repo init -u https://github.com/armmbed/mbl-manifest.git -b jh-unstable -m private.xml
repo sync
```

## Set up the build environment
Source the environment setup script:
```
. setup_environment
```
When prompted to select a "machine" and a "distro", select the values for your device in the following table.

| Device         | Machine          | Distro |
| :---           | ---              | ---    |
| Warp7          | `imx7s-warp-mbl` | `mbl`  |
| Raspberry Pi 3 | `raspberrypi3`   | `mbl`  |

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
* a root filesystem archive which is used for firmware updates.

The paths of these files are

| Warp7                   |     |
| :---                    | --- |
| full disk image         | ~/mbl/mbl-unstable/build-mbl/tmp-mbl-glibc/deploy/images/imx7s-warp-mbl/mbl-console-image-imx7s-warp-mbl.wic.gz |
| root filesystem archive | ~/mbl/mbl-unstable/build-mbl/tmp-mbl-glibc/deploy/images/imx7s-warp-mbl/mbl-console-image-imx7s-warp-mbl.tar.xz |

| Raspberry Pi 3          |     |
| :---                    | --- |
| full disk image         | ~/mbl/mbl-unstable/build-mbl/tmp-mbl-glibc/deploy/images/raspberrypi3/mbl-console-image-raspberrypi3.rpi-sdimg |
| root filesystem archive | ~/mbl/mbl-unstable/build-mbl/tmp-mbl-glibc/deploy/images/raspberrypi3/mbl-console-image-raspberrypi3.tar.bz2 |


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
to expose the Warp7's flash device to Linux as USB mass storage. You should now see the Warp7's flash device in `/dev`, probably as `/dev/sdX` for some letter `X`. the output of `lsblk` can be useful to identify the name of the device.

From a linux prompt Write the disk image to the Warp7's flash device with
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

After a firmware update, the flash partition used for the root filesystem will change. Check which partition is mounted at `/` now so that you can check that it changes after the update. You can use `lsblk` to do this.

The easiest way to update firmware on a single device is to use manifest-tool. To use the manifest tool for firmware updates you may need to install an additionall package, [the Python mbed-cloud-sdk](https://github.com/ARMmbed/mbed-cloud-sdk-python):
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
