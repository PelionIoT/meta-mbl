## Networking over USB in Mbed Linux OS

Copyright © 2018 Arm Limited.

### Introduction
An Mbed Linux OS IoT device with suitable hardware supports
networking over USB by using the Mbed Linux OS kernel's appropriate driver mechanism.

### USB peripheral and USB host port types

When a device with USB host port(s) is used (such as a Raspberry Pi 3), communication between
the device and a development PC can be established via a peripheral Ethernet-to-USB adapter
plugged into one of the available USB host ports on the device. The Linux kernel's CDC
Ethernet driver is used on the device for supporting this kind of communication.

When a device with USB peripheral port(s) is used (such as a WaRP7), communication between
the device and the development PC can be established by connecting the device
directly to the development PC with a USB cable. The Linux kernel's USB Gadget
driver is used on the device in this case.

* When running on WaRP7, the Mbed Linux OS kernel's USB Gadget driver mechanism creates
  a `usb0` network interface on the IoT device and makes the IoT device itself appear
  as a network interface to another device connected via USB (e.g. a development PC).

* When Mbed Linux OS is installed on Raspberry Pi 3, the kernel's USB Gadget driver is not installed due to
  hardware limitations of the board, and the `usb0` interface does not exist. There are two Ethernet network
  interfaces in Mbed Linux OS when installed on Raspberry Pi 3: `eth0`, which belongs to the wired
  Ethernet port, and `eth1` which is created by the CDC Ethernet driver, once appropriate hardware
  has been connected.
  An Ethernet-to-USB hardware adapter is required in order to support USB networking on an IoT
  device based on a Raspberry Pi 3 board.
  Once an Ethernet-to-USB adapter's USB "male" connector is inserted into any of the four type-A
  USB ports of the Raspberry Pi 3 board, the Mbed Linux OS kernel's CDC Ethernet driver mechanism creates an `eth1`
  network interface. This makes it possible for another device to establish communication with the IoT device.
  In order to establish communication with the development PC, the Ethernet cable of the
  adapter should be connected to an available Ethernet port on the development PC.

By default, Mbed Linux OS attempts to obtain an IPv4 address for the `usb0` interface on WaRP7
or the `eth1` interface on Raspberry Pi 3 using DHCP and falls back to assigning a link-local IPv4
address if a DHCP server can't be found.

#### Connecting a WaRP7 IoT device to a PC
To connect a PC to an Mbed Linux OS IoT WaRP7 device using the USB networking facility,
perform the following steps:

1. Check which network interfaces are already available on the PC.
2. Connect the IoT device to the PC.
3. Check which network interfaces are available on the PC again, and compare
   this with the information obtained in step #1 to determine which interface
   is for the IoT device.
4. Configure the PC to use link-local IPv4 addressing for the interface and
   determine the address assigned to the interface.

For example, on an Ubuntu 16.04 PC, do the following:

Use `ifconfig -a` to list available network interfaces. Once the IoT device
has been connected to the development PC, the PC kernel will
instantiate the ethernet net_device for the USB network interface. This is shown
in the following listing, which shows the interface is present but has not yet
been assigned an IP address:

  ```
  $ ifconfig -a
  < ... lines deleted to save space >

  enp0s20u5u4u4 Link encap:Ethernet  HWaddr ee:a9:74:68:fe:69
            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
            RX packets:136 errors:0 dropped:0 overruns:0 frame:0
            TX packets:322 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000
            RX bytes:37211 (37.2 KB)  TX bytes:57393 (57.3 KB)

  < ... lines deleted to save space >
  ```

#### Connecting a Raspberry Pi 3 IoT device to a PC
To connect a PC to an Mbed Linux OS IoT Raspberry Pi 3 device using an Ethernet-to-USB adapter,
perform the following steps:

1. Connect an Ethernet-to-USB adapter's USB "male" connector into any of
   the four type-A USB ports of the Raspberry Pi 3 board, and the Ethernet
   cable of the adapter into an available Ethernet port on the development PC.
2. Check which network interface belongs to the port that is connected to the
   Raspberry Pi 3 device.
3. Configure the PC to use link-local IPv4 addressing for the interface and
   determine the address assigned to the interface.

For example, on an Ubuntu 16.04 PC and a Raspberry Pi 3 device connected to an
RTL8153 Gigabit Ethernet-to-USB adapter, do the following:

Connect the Raspberry Pi 3 device to the PC and use `ifconfig -a` to identify the network interface.

  ```
  $ ifconfig -a
  < ... lines deleted to save space >

  eno0 Link encap:Ethernet  HWaddr 6c:0b:84:67:18:f5
        UP BROADCAST MULTICAST  MTU:1500  Metric:1
        RX packets:5463 errors:0 dropped:0 overruns:0 frame:0
        TX packets:2839 errors:0 dropped:0 overruns:0 carrier:0
        collisions:0 txqueuelen:1000
        RX bytes:3149461 (3.1 MB)  TX bytes:900468 (900.4 KB)
        Memory:fb100000-fb17ffff

  < ... lines deleted to save space >
  ```

  Note, that an IP address was not assigned yet to the `eno0` network interface.

#### Assigning an IP address to the network interface on a PC

On an Ubuntu 16.04 PC using NetworkManager:

1. Create a NetworkManager connection profile called `mbl-ipv4ll` for the
interface with the `link-local` IPv4 addressing method using the NetworkManager's command line interface:

    ```
    $ sudo nmcli connection add ifname <interace-name-on-pc> con-name mbl-ipv4ll type ethernet -- ipv4.method link-local
    ```

    where `<interface-name-on-pc>` is the name of the network interface on the
    PC that connects to the IoT device.

    * For example, if using a WaRP7 and the name of the interface on the PC for the WaRP7 connection is `enp0s20u5u4u4`:
      ```
      $ sudo nmcli connection add ifname enp0s20u5u4u4 con-name mbl-ipv4ll type ethernet -- ipv4.method link-local
      Connection 'mbl-ipv4ll' (0076a29f-6892-45bb-8338-2879b863efdf) successfully added.
      ```

    * If using a Raspberry Pi 3 connected to the PC's `eno0` interface:
      ```
      $ sudo nmcli connection add ifname eno0 con-name mbl-ipv4ll type ethernet -- ipv4.method link-local
      Connection 'mbl-ipv4ll' (475ebfb1-d67e-47e9-afd2-8f2cf8a16cdd) successfully added.
      ```

1. Activate the `mbl-ipv4ll` connection profile:
    ```
    $ sudo nmcli connection up mbl-ipv4ll
    ```
    * This step may not be required as NetworkManager may automatically enable the connection profile.
    * If this command finishes with the error
      `Error: Connection activation failed: No suitable device found for this connection.`
      verify that the device is managed by NetworkManager (that the field `managed` is set to `true` in the
      `/etc/NetworkManager/NetworkManager.conf` configuration file on the Linux development PC).

1. The NetworkManager connection has now been created and can be inspected using the `nmcli connection show` command.
    * For example, when using a WaRP7 based IoT device:
      ```
      $ sudo nmcli connection show
      NAME                UUID                                  TYPE            DEVICE
      mbl-ipv4ll          0076a29f-6892-45bb-8338-2879b863efdf  802-3-ethernet  enp0s20u5u4u4
      Wired connection 1  99cf6de7-2297-3607-923a-4286fdbf357a  802-3-ethernet  --
      ```

    * When using a Raspberry Pi 3 based IoT device:
      ```
      $ sudo nmcli connection show
      NAME                UUID                                  TYPE            DEVICE
      eno1                a815455d-8f18-4f25-a8d1-39f0f89fc022  802-3-ethernet  eno1
      mbl-ipv4ll          475ebfb1-d67e-47e9-afd2-8f2cf8a16cdd  802-3-ethernet  eno0
      ```

    The PC's network interface (that communicates with an IoT device) should now have been
    allocated an IPv4 link-local (169.254.x.y) address:
    * For example, when using a WaRP7 based IoT device:
      ```
      $ sudo ifconfig enp0s20u5u4u4
      enp0s20u5u4u4 Link encap:Ethernet  HWaddr ba:77:68:c0:73:df
              inet addr:169.254.131.167  Bcast:169.254.255.255  Mask:255.255.0.0
              inet6 addr: fe80::b418:c138:20f0:57c7/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:146 errors:0 dropped:0 overruns:0 frame:0
              TX packets:364 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000
              RX bytes:40589 (40.5 KB)  TX bytes:65923 (65.9 KB)
      ```

    * When using a Raspberry Pi 3 based IoT device:

      ```
      $ sudo ifconfig eno0
      eno0 Link encap:Ethernet  HWaddr 6c:0b:84:67:18:f5
          inet addr:169.254.4.179  Bcast:169.254.255.255  Mask:255.255.0.0
          inet6 addr: fe80::3714:e5ad:7eb2:c3a5/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:5529 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2936 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:3176233 (3.1 MB)  TX bytes:915351 (915.3 KB)
          Memory:fb100000-fb17ffff
      ```

Note, that network interface names (like `enp0s20u5u4u4`, `eno0` etc.) and connection's UUID values
can be different on other development PCs.

An alternative to using the NetworkManager command line interface is to use the `nm-connection-editor` GUI to configure the interface.

See the [`nmcli` man page][nmcli-manpage] for more information.

### Example usage

#### Using Netcat to transfer files
See [the Netcat example in the logs document][mbl-logs-netcat-example] to see
how to transfer files from the IoT device to a PC. When specifying the IP
address of the PC in the Netcat commands, ensure you use the link-local address
for the network interface representing the USB connection to the IoT device.

A similar technique can be used to transfer files from a PC to the IoT device -
reverse the directions of the redirection operators (`<` and `>`) in the Netcat
commands.

#### SSH (test image only)
If the IoT device is running a "test" image (created using `bitbake
mbl-image-development`) then it will be running an SSH server and you can
operate on the IoT device without using the serial console. The IoT device will
respond to DNS-SD service discovery requests, so a PC with support for DNS-SD
can discover the IoT device's SSH service without previous knowledge of the
device's IP address or hostname.

#### Avahi service discovery on a local network
[Avahi][avahi-homepage] is a zero-configuration networking (zeroconf) implementation that allows mDNS/DNS-SD service discovery on a local network. This enables you to plug your computer and the IoT device into a network and instantly be able to view the device's available services.
Avahi is installed on Ubuntu 16.04 by default, and it is also built into mbl image build.

##### Using Avahi to discover device's services

On a Linux PC with [Avahi][avahi-homepage] installed, the IoT device's SSH service can be
discovered using the [`avahi-browse`][avahi-browse-manpage] command:
```
avahi-browse --terminate --resolve --verbose _ssh._tcp | grep --after-context 4 '^= *<interface-on-dev-pc>'
```
replacing `<interface-on-dev-pc>` with the name of the network interface on the
development PC provided by the IoT device.
The arguments used for `avahi-browse` are:
* `--terminate` - this tells `avahi-browse` to "terminate after dumping a more
  or less complete list".
* `--resolve` - this tells `avahi-browse` to get hostnames, IP addresses, and
  port numbers for the services it finds.
* `--verbose` - this tells `avahi-browse` to actually print the hostnames, IP
  addresses and port numbers it finds.
* `_ssh._tcp` - this tells `avahi-browse` to look for SSH services.

`avahi-browse` will search for local SSH services available via every network
interface, so it is useful to filter the results using `grep`. For each
resolved service found `avahi-browse` will print five lines of information,
starting with a line prefixed with '=' (meaning "resolved") followed by the
interface via which the service was accessible. Therefore, the arguments used
for `grep` are:
* `--after-context 4` - this tells grep to print the four lines of output
  following the matching line (in addition to the matching line itself).
* `'^= *<interface-on-dev-pc>'` - this tells grep to match lines that start
  with '=' and the name of the relevant network interface.

An example command and output is:
```
$ avahi-browse --terminate --resolve --verbose _ssh._tcp | grep --after-context 4 '^= *enp0s20u13u3'
Server version: avahi 0.6.32-rc; Host name: e113079-lin.local
E Ifce Prot Name                                          Type                 Domain
= enp0s20u13u3 IPv4 imx7s-warp-mbl                                SSH Remote Terminal  local
   hostname = [imx7s-warp-mbl.local]
   address = [169.254.7.205]
   port = [22]
   txt = []
$
```
In this example the IoT device has the address 169.254.7.205 and is running an
SSH server on port 22 (the default SSH port). A shell on the device could be
accessed with:
```
ssh root@169.254.7.205
```

[mbl-logs-netcat-example]: logs.md#collecting-logs-using-netcat

[avahi-homepage]: https://www.avahi.org/
[netcat-manpage]: https://linux.die.net/man/1/nc
[avahi-browse-manpage]:https://linux.die.net/man/1/avahi-browse
[nmcli-manpage]: https://linux.die.net/man/1/nmcli

