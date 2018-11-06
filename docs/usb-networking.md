## Networking over USB in Mbed Linux OS

An Mbed Linux OS IoT device with suitable hardware (e.g. WaRP7) supports
networking over USB by using the Linux kernel's USB Gadget driver mechanism.
The kernel creates a `usb0` network interface on the IoT device and makes the
IoT device itself appear as a network interface to another device connected via
USB (e.g. a development PC). The two network interfaces are implemented by the
kernel such that each device appears to be connected to the other via Ethernet.

By default, Mbed Linux OS attempts to obtain an IPv4 address for the `usb0`
interface using DHCP and falls back to assigning a link-local IPv4 address if a
DHCP server can't be found.

### Connecting the IoT device to a PC
To connect a PC to an Mbed Linux IoT device using the USB networking facility,
perform the following steps:

1. Check which network interfaces are already available on the PC.
2. Connect the IoT device to the PC.
3. Check which network interfaces are available on the PC again, and compare
   this with the information obtained in step #1 to determine which interface
   is for the IoT device.
4. Configure the PC to use link-local IPv4 addressing for the interface and
   determine the address assigned to the interface.

On an Ubuntu 16.04 PC using NetworkManager, do the following:

1. Use `ifconfig -a` to list available network interfaces. Once the IoT device has been connected to the development PC, the PC kernel will
  instantiate the ethernet net_device for the USB network interface. This is shown
  in the following listing, which shows the interface is present but has not yet 
  been assigned an IP address:

    ```
    $ sudo ifconfig -a
    < ... lines deleted to save space >

    enp0s20u5u4u4 Link encap:Ethernet  HWaddr ee:a9:74:68:fe:69  
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:136 errors:0 dropped:0 overruns:0 frame:0
              TX packets:322 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000 
              RX bytes:37211 (37.2 KB)  TX bytes:57393 (57.3 KB)

    < ... lines deleted to save space >
    ```  
  
1. Create a NetworkManager connection profile called `mbl-ipv4ll` for the
interface with the `link-local` IPv4 addressing method using the NetworkManager's command line interface:

    ```
    $ sudo nmcli connection add ifname <interace-name-on-pc> con-name mbl-ipv4ll type ethernet -- ipv4.method link-local
    ```  

    where `<interface-name-on-pc>` is the name of the network interface on the
    PC created when plugging in the IoT device. Using the `enp0s20u5u4u4` interface shown in the previous listing:

    ```
    $ sudo nmcli connection add ifname enp0s20u5u4u4 con-name mbl-ipv4ll type ethernet -- ipv4.method link-local
    Connection 'mbl-ipv4ll' (0076a29f-6892-45bb-8338-2879b863efdf) successfully added.
    ```

1. Activate the `mbl-ipv4ll` connection profile:
    ```
    $ sudo nmcli connection up mbl-ipv4ll
    ```
    This step my not be required as the NetworkManager may automatically enable the connection profile.

1. The NetworkManager connection has now been created and can be inspected using the following command:
    
    ```
    $ sudo nmcli connection show
    NAME                UUID                                  TYPE            DEVICE        
    mbl-ipv4ll          0076a29f-6892-45bb-8338-2879b863efdf  802-3-ethernet  enp0s20u5u4u4 
    Wired connection 1  99cf6de7-2297-3607-923a-4286fdbf357a  802-3-ethernet  --          
    ```     
     
    The interface should now have been allocated an IPv4 link-local (169.254.x.y) address:

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
mbl-console-image-test`) then it will be running an SSH server and you can
operate on the IoT device without using the serial console. The IoT device will
respond to DNS-SD service discovery requests, so a PC with support for DNS-SD
can discover the IoT device's SSH service without previous knowledge of the
device's IP address or hostname.

#### Avahi service discovery on a local network
[Avahi][avahi-homepage] is a free zero-configuration networking (zeroconf) implementation, including a system for multicast DNS/DNS-SD service discovery on a local network. This enables you to plug your computer and the IoT device into a network and instantly be able to view the device's available services.
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
