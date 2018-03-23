# Logs for Mbed Linux OS (mbl)

In addition to the standard log files for Linux, there are log files for the Mbed Linux Cloud Client. These are:
* `/var/log/mbl/cloud-client.log`: the main log file for the Mbed Linux Cloud Client.
* `/opt/arm/arm_update_activate.log`: the log file used by the firmware update script.
* `/opt/arm/arm_update_active_details.log`: the log file used by the script that reports current firmware details to the Mbed Cloud.

**Note:** currently logs in `/var/log` are not kept on the device's flash storage and do not persist across Linux reboots.

## Collecting logs

### When using the standard image
When a device has been installed with the standard image (built using `bitbake mbl-console-image`) there is not currently a convenient mechanism to transfer Mbed Linux OS log files to another device. The recommended procedure is to use `cat` on the mbl device to dump the logs to the serial console.

### When using the test image
If an mbl device has been installed with the test image (built using `bitbake mbl-console-image-test`) then it will have an SSH daemon running, which enables the use of `scp` to transfer logs to a development PC accessible over a network. Run the following command on the development PC to copy a log file to the current directory:
```
scp root@<mbl-device-ip>:<path-to-log-on-mbl-device> <file-name-on-dev-pc>
```
replacing:
* `<mbl-device-ip>` with the ip address of the Mbed Linux OS device.
* `<path-to-log-on-mbl-device>` with the path to the log file on the mbl device (e.g. `/var/log/mbl-cloud-client.log`).
* `<file-name-on-dev-pc>` with the desired name of the log file on the development PC.
