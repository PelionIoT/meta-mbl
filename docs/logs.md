# Logs for Mbed Linux OS (mbl)

Copyright © 2018 Arm Limited.

In addition to the standard log files for Linux, there are log files for the Mbed Linux Cloud Client. These are:
* `/var/log/mbl/cloud-client.log`: the main log file for the Mbed Linux Cloud Client.
* `/opt/arm/arm_update_activate.log`: the log file used by the firmware update script.
* `/opt/arm/arm_update_active_details.log`: the log file used by the script that reports current firmware details to the Mbed Cloud.

**Note:** currently logs in `/var/log` are not kept on the device's flash storage and do not persist across Linux reboots.

## Collecting logs

### When using the standard image
When a device has been installed with the standard image (built using `bitbake mbl-console-image`) there is not currently a convenient, secure mechanism to transfer Mbed Linux OS log files to another device. Two methods are described below.

#### Collecting logs using Netcat
If the IoT device and the recipient device are connected to the same network where insecure communication between the two devices is not a problem (e.g. when using the IoT device's [USB networking feature][mbl-usb-networking]) then Netcat can be used to transfer log files from the IoT device. To use Netcat to transfer a log file onto a development PC:
1. On the development PC run:
   ```
   nc -l <dev-pc-ip-address> 51689 > <path-to-log-on-dev-pc>
   ```
   where:
   * `-l` tells netcat to listen for connections rather than initiating a connection. The listening must be done on the development PC because the version of Netcat in Mbed Linux OS does not support listening.
   * `<dev-pc-ip-address>` is the IP address of the development PC.
   * `51689` is the port to listen on. If Netcat reports an error due to the port being in use then try any other port in the range 49152-65535.
   * `<path-to-log-on-dev-pc>` is the path to which the log file will be saved on the development PC.
2. On the IoT device run:
   ```
   nc <dev-pc-ip-address> 51689 < <path-to-log-on-mbl-device>
   ```
   where:
   * `<dev-pc-ip-address>` is the IP address of the development PC.
   * `51689` is the port on the development PC on which Netcat is listening.
   * `<path-to-log-on-mbl-device>` is the path to the log file on the IoT device that is to be sent to the development PC.

   See the [`nc` man page][netcat-manpage] for more information.

#### Collecting logs using the serial console
Use the `cat` command on the IoT device to dump the logs to the serial console.

### When using the test image
If an mbl device has been installed with the test image (built using `bitbake mbl-console-image-test`) then it will have an SSH daemon running, which enables the use of `scp` to transfer logs to a development PC accessible over a network (e.g. using the IoT device's [USB networking feature](mbl-usb-networking)). Run the following command on the development PC to copy a log file to the current directory:
```
scp root@<mbl-device-ip>:<path-to-log-on-mbl-device> <file-name-on-dev-pc>
```
replacing:
* `<mbl-device-ip>` with the ip address of the Mbed Linux OS device.
* `<path-to-log-on-mbl-device>` with the path to the log file on the mbl device (e.g. `/var/log/mbl-cloud-client.log`).
* `<file-name-on-dev-pc>` with the desired name of the log file on the development PC.

[netcat-manpage]: https://linux.die.net/man/1/nc
[mbl-usb-networking]: usb-networking.md
