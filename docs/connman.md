## ConnMan

Copyright © 2018 Arm Limited.

### Introduction
ConnMan (Connection Manager) has been chosen as the MBed Linux OS network manager. It is a daemon that manages network connections Within embedded devices and integrates a range of features usually split between many daemons such as DHCP, DNS, and NTP.

#### Main attributes
* Lightweight, small footprint with low memory consumption.
* Fast response time for changing network conditions.
* Has a built-in support for the next technologies:
    * Ethernet / Ethernet over USB.
    * WiFi using wpa_supplicant.
    * Celluar (2G/3G/4G) connectivity using oFono.
    * Bluetooth connectivity using Bluez
* Fully modular and it can be extended through plug-ins. Hence, it supports all kinds of wired and wireless technologies.
* Automatically manages wired connections.
* Supports configuration methods such as DNS, DHCP using plug-ins.
* ConnMan can be used also through a command line interface client known as **connmanctl**, which can be run in two modes: a plain synchronous command input, and an asynchronous interactive shell.
* Uses D-BUS as its API.

#### ConnMan on Mbed Linux OS

ConnMan comes as part of the Mbed Linux OS image, with few modifications:
* The official ConnMan depends on GNU General Public License version 3 (GPLv3) libraries. All these dependencies have been removed on build/linking stages by disabling or replacing some functionalities :
    * wispr (Wireless Internet Service Provider roaming) is not supported.
    * readline library has been replaced by editline. For this reason, auto-complete and history are disabled for now for the connmanctl  CLI.
    * connman-vpn daemon (a daemon for managing vpn connections together with ConnMan) is not supported for now.
* In order to avoid conflicts with wpa_supplicant, AP scanning/selection is disabled in wpa_supplicant.conf (ap_scan=0)

#### Configuration and state
Both can be found under the same path /config/user/connman/:
* Configuration : main.conf (also known as connman.conf) can be found under /config/user/connnman/main.config (moved from it's original location under /etc/connman/main.conf).
* State : ConnMan settings and state can also be found also under /config/user/connman (moved from it's original location under /var/lib/connman).

ConnMan's main.conf is currently configured to give priority for Ethernet connections over WiFi connections (see 'PreferredTechnologies' section). That means, if both connections exist at the same time, the default chosen route will be the one of the Ethernet connection. The other WiFi connection stays connected in ConnMan 'ready'  state and becomes 'Online' only if Ethernet cable is disconnected or connection is lost.

#### Supported (validated and tested) technologies
For now, we have validated ConnMan operation under the following connections types :
* WiFi - non-protected APs and password protected APs (WEP, WPA, WPA2).
* Ethernet / Ethernet Over USB

#### Known issues
At this stage, connmanctl interactive mode has known display bugs while using advanced navigation features such as end button, home button etc.

#### Additional references
ConnMan official documnetation :
https://01.org/connman/documentation

ConnMan can be downloaded from https://mirrors.edge.kernel.org/pub/linux/network/connman/

ConnMan can be cloned from git :
git://git.kernel.org/pub/scm/network/connman/connman.git

ConnMan man pages (debian) :
https://manpages.debian.org/testing/connman/connman.8.en.html
https://manpages.debian.org/testing/connman/connman-service.config.5.en.html

connmanctl man pages (debian) : https://manpages.debian.org/testing/connman/connmanctl.1.en.html
https://manpages.debian.org/testing/connman/connman.conf.5.en.html

An excellent page explaining ConnMan (Embedded Computing, http://www.embedded-computing.com, 'Managing Internet connections on Linux devices with ConnMan'):  
http://www.embedded-computing.com/networking/the-connman

editline portal:
http://thrysoee.dk/editline/
