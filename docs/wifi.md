# Setting up Wifi in Mbed Linux

## Overview

Mbed Linux uses `ifupdown` and [`wpa_supplicant`][ws_home_page]
to manage wifi interfaces and connections. To configure wifi settings one can
edit the file `/etc/wpa_supplicant.conf` (which is actually a symlink to
`/config/wpa_supplicant.conf` on Mbed Linux) or use the `wpa_cli` utility.

This document does not provide detailed information about how to configure wifi
in every case, but may help with some common scenarios. Please refer to
`wpa_supplicant`'s [man page][ws_man_page] and [reference
configuration file][ws_reference_config] for further information.

## wpa\_supplicant.conf network blocks
`wpa_supplicant.conf` contains, among other settings, zero or more "network"
blocks that each specify the configuration for a particular network. Network
blocks begin with the line
```
network={
```
and end with the line
```
}
```
between which are lines specifying settings for the network. For example, the
following network block specifies a WPA-PSK network network with SSID "my-ssid"
and passphrase "my-password".
```
network={
    ssid="my-ssid"
    psk="my-password"
}
```

## Default configuration

The default `wpa_supplicant.conf` in Mbed Linux is
```
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=0
update_config=1

network={
    key_mgmt=NONE
}
```
The first three lines specify global settings to enable `wpa_cli`, when run by
a member of the group `root`, to configure `wpa_supplicant` and write to the
configuration file.  Removing or changing these lines is not recommended.

The network block tells `wpa_supplicant` to connect to any open network. This
policy will probably change in the future.

## Network priority
The priority order in which `wpa_supplicant` attempts to connect to the
networks specified in `wpa_supplicant.conf` is, by default, affected by the
security policies and signal strengths of the networks among other things (see
the [reference configuration file][ws_reference_config] for more details). To
influence `wpa_supplicant`'s priorities for networks, one can use the `priority`
field in a network block. The value is an integer and networks with higher
`priority` values are preferred by `wpa_supplicant`. For example, the following
configuration specifies two WPA-PSK networks, with SSIDs "ssid1" and "ssid2".
The "ssid2" network will be prefered by `wpa_supplicant` because of the higher
`priority` value.
```
network={
    ssid="ssid1"
    psk="my-password1"
    priority=1
}

network={
    ssid="ssid2"
    psk="my-password2"
    priority=2
}
```
A network's default priority value is `0`.

## Disabling networks
A network block in `wpa_supplicant.conf` can be marked as `disabled` to prevent
`wpa_supplicant` from using the specified network. In the following example,
the network with SSID "ssid1" will not be used.
```
network={
    ssid="ssid1"
    psk="my-password1"
    disabled=1
}

network={
    ssid="ssid2"
    psk="my-password2"
}
```

## Making changes to `wpa_supplicant.conf` take effect
After editing `wpa_supplicant.conf`, run the following to make the changes take
effect.
```
ifdown wlan0
ifup wlan0
```

## Checking the wifi connection status
To see information about the current wifi connection, run
```
wpa_cli status
```

## Discovering wifi networks
`wpa_cli` can be used to discover available networks. First, use `wpa_cli` to ask `wpa_supplicant` to perform a scan with
```
root@imx7s-warp-mbl:~# wpa_cli scan
Selected interface 'wlan0'
OK
root@imx7s-warp-mbl:~#
```
then view the results of the scan with
```
root@imx7s-warp-mbl:~# wpa_cli scan_results
Selected interface 'wlan0'
bssid / frequency / signal level / flags / ssid
00:53:0a:64:35:01       2462    -62     [ESS]   ExampleOpenNetwork
00:53:f8:98:e8:18       2422    -33     [WPA2-PSK-CCMP][ESS]    ExampleWPAPersonalNetwork
00:53:00:64:3a:81       2462    -56     [WPA2-EAP-CCMP][ESS]    ExampleWPAEnterpriseNetwork
00:53:03:64:8d:01       2437    -61     [WPA2-EAP-CCMP][ESS]    ExampleWPAEnterpriseNetwork
00:53:e0:64:35:22       2462    -62     [WPA2-EAP-CCMP][ESS]    ExampleWPAEnterpriseNetwork
00:53:90:64:51:0d       2412    -71     [WPA2-EAP-CCMP][ESS]    ExampleWPAEnterpriseNetwork
00:53:02:64:95:cc       2437    -82     [WPA2-EAP-CCMP][ESS]    ExampleWPAEnterpriseNetwork
00:53:b0:5d:63:80       2437    -89     [WPA2-EAP-CCMP][ESS]    ExampleWPAEnterpriseNetwork
00:53:06:64:3a:84       2462    -54     [ESS]   ExampleOpenNetwork
00:53:45:64:8d:09       2437    -63     [ESS]   ExampleOpenNetwork
00:53:76:64:51:07       2412    -71     [ESS]   ExampleOpenNetwork
00:53:a7:64:95:a1       2437    -81     [ESS]   ExampleOpenNetwork
00:53:b0:5d:63:91       2437    -87     [ESS]   ExampleOpenNetwork
root@imx7s-warp-mbl:~#
```
The output above shows three SSIDs:
* `ExampleOpenNetwork` - an open network with six known BSSIDs.
* `ExampleWPAPersonalNetwork` - a WPA-PSK network with a single known BSSID.
* `ExampleWPAEnterpriseNetwork` - a WPA-Enterprise network with six known BSSIDs.

There are example configurations for networks of these types below.

## Some useful network blocks

### For connecting to a named open network

To specify an open network with the SSID "my-ssid" in
`wpa_supplicant.conf`, add the following network block.
```
network={
    ssid="my-ssid"
    key_mgmt=NONE
}
```

### For connecting to a WPA-PSK network

To specify a WPA-PSK (WPA-Personal) network with SSID "my-ssid" and passphrase
"my-passphrase", add the following block to `wpa_supplicant.conf`.
```
network={
    ssid="my-ssid"
    key_mgmt=WPA-PSK
    psk="my-passphrase"
}
```
Alternatively, one can use a hash of the passphrase rather than putting it
into the configuration file in plain text. The `wpa_passphrase` utility can be
used to generate a network block containing the hash like this:
```
root@imx7s-warp-mbl:~# wpa_passphrase my-ssid my-passphrase
network={
        ssid="my-ssid"
        #psk="my-passphrase"
        psk=85892d35689549be10f89580f60dd53dd3e65696fe61f4a8e99ac75e110d94c7
}
root@imx7s-warp-mbl:~#
```
The line containing "my-passphrase" can be removed before adding the network
block to `wpa_supplicant.conf`:
```
network={
        ssid="my-ssid"
        psk=85892d35689549be10f89580f60dd53dd3e65696fe61f4a8e99ac75e110d94c7
}
```
Note, however, that although the network block does not contain the original
passphrase in plain text, knowing the hash of the passphrase is enough to gain
access to the network.

### For connecting to a WPA2-Enterprise network

There are many different configurations for WPA2-Enterprise networks. The
following network block is an example for connecting to a PEAP/EAP-MSCHAPv2
authenticated WPA2-Enterprise network called "my-ssid" as the user
"my-username" with password "my-password". See the `wpa_supplicant` [man
page][ws_man_page] for more examples.
```
network={
    ssid="my-ssid"
    proto=RSN
    key_mgmt=WPA-EAP
    auth_alg=OPEN
    eap=PEAP
    phase2="MSCHAPV2"
    identity="my-username"
    password="my-password"
}
```

Mbed Linux does not currently support keeping the username or password in
secure storage, so if persistence of these settings is required then these
details must be kept in the configuration file in plain text.

If persistence of the settings is not required then adding these details to the
configuration file can be avoided by using `wpa_cli` to provide them. To do
this, first add the network block to `wpa_supplicant.conf` but without the
sensitive information:
```
network={
    ssid="my-ssid"
    proto=RSN
    key_mgmt=WPA-EAP
    auth_alg=OPEN
    eap=PEAP
    phase2="MSCHAPV2"
}
```
Bring the wireless interface down and back up:
```
ifdown wlan0
ifup wlan0
```

Next, the "network id" that `wpa_supplicant` uses for the network must be
determined. `wpa_cli` can be used to do this:
```
root@imx7s-warp-mbl:~# wpa_cli list_networks
Selected interface 'wlan0'
network id / ssid / bssid / flags
0       some-ssid  any
1       my-ssid    any
root@imx7s-warp-mbl:~#
```
Note the number in the "network id" column on the line with the SSID matching
the network of interest. You can then use `wpa_cli` to provide the required
credentials:
```
wpa_cli set_network 1 identity "my-username"
wpa_cli set_network 1 password "my-password"
```
where "1" is the "network id". The credentials will be used until
`wpa_supplicant` dies but will not be written to `wpa_supplicant.conf` (unless
one runs `wpa_cli save`).

To avoid leaving passwords in terminal logs one could e.g. use a shell function
like 
```
set_wifi_password() {
network_id="$1"
    printf "identity: "
    read identity
    printf "password: "
    read -s password
    wpa_cli set_network "$network_id" identity "\"$identity\""
    wpa_cli set_network "$network_id" password "\"$password\""
}
```
[ws_home_page]: https://w1.fi/wpa_supplicant/
[ws_man_page]: https://linux.die.net/man/5/wpa_supplicant.conf
[ws_reference_config]: https://w1.fi/cgit/hostap/plain/wpa_supplicant/wpa_supplicant.conf
