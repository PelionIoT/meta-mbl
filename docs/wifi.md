## Qualcomm WiFi

Copyright © 2019 Arm Limited.

### Introduction

For legal reasons Arm is not permitted to redistribute the Qualcomm QCA9377 firmware.
The following is a brief description of how to install the firmware on an mbed Linux image.

#### Getting the firmware

A script has been supplied on the root filesystem which will download the requisite firmware.

Connect an Ethernet cable or bring up the USB Ethernet interface as described in [USB networking feature][mbl-usb-networking].

A script to add the WiFi driver to the device has been added to the MBL image at /etc/mbl-firmware.d/populate_rootfs_qca.sh.

It does this by either:

* Downloading it or
* Running a previously downloaded firmware on the rootfs

#### Sample log

root@mbed-linux-os-4345:~# cd /tmp/
root@mbed-linux-os-4345:/tmp# /etc/mbl-firmware.d/populate_rootfs_qca.sh 
....
Do you accept the EULA you just read? (y/N) y
EULA has been accepted. The files will be unpacked at 'firmware-qca-2.0.3'

Unpacking file ................................................... done
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/etc/bluetooth/firmware.conf' -> '/etc/bluetooth/firmware.conf'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/etc/bluetooth' -> '/etc/bluetooth'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/etc' -> '/etc'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/lib/firmware/qca/tfbtfw11.tlv' -> '/lib/firmware/qca/tfbtfw11.tlv'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/lib/firmware/qca/tfbtnv11.bin' -> '/lib/firmware/qca/tfbtnv11.bin'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/lib/firmware/qca' -> '/lib/firmware/qca'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/lib/firmware/qca9377/bdwlan30.bin' -> '/lib/firmware/qca9377/bdwlan30.bin'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/lib/firmware/qca9377/otp30.bin' -> '/lib/firmware/qca9377/otp30.bin'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/lib/firmware/qca9377/qwlan30.bin' -> '/lib/firmware/qca9377/qwlan30.bin'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/lib/firmware/qca9377/utf30.bin' -> '/lib/firmware/qca9377/utf30.bin'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/lib/firmware/qca9377' -> '/lib/firmware/qca9377'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/lib/firmware/wlan/qca9377/qcom_cfg.ini' -> '/lib/firmware/wlan/qca9377/qcom_cfg.ini'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/lib/firmware/wlan/qca9377' -> '/lib/firmware/wlan/qca9377'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/lib/firmware/wlan' -> '/lib/firmware/wlan'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/lib/firmware' -> '/lib/firmware'
'./firmware-qca-2.0.3/1PJ_QCA9377-3_LEA_2.0/lib' -> '/lib'

root@mbed-linux-os-4345:~# reboot
root@mbed-linux-os-4345:~# ip addr

4: wlan0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq qlen 3000
    link/ether 00:1f:7b:31:04:3a brd ff:ff:ff:ff:ff:ff
