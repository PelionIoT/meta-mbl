## Setting up Wifi in Mbed Linux

Mbed Linux uses `ifupdown` and [`wpa_supplicant`][ws_home_page] to manage wifi interfaces and connections. To configure wifi settings you can either:

* Edit the file `/etc/wpa_supplicant.conf` (which is actually a symlink to `/config/wpa_supplicant.conf` on Mbed Linux).
* Use the `wpa_cli` utility.

This document provides some basic information about how to configure wifi using the `wpa_supplicant.conf` file and the `wpa_cli` utility. Refer to the `wpa_supplicant` [man page][ws_man_page] and [reference configuration file][ws_reference_config] for further information.

### Using the `wpa_supplicant.conf` file

By default, the `wpa_supplicant.conf` file contains, among other settings:

* **Global settings** to enable `wpa_cli`, when run by a member of the group `root`, to configure `wpa_supplicant` and write to the configuration file.  Do **not** remove or change these lines.
    ```
    ctrl_interface=/var/run/wpa_supplicant
    ctrl_interface_group=0
    update_config=1
    ```
* Zero or more **network blocks** that each specify the configuration for a particular network. The default network block tells `wpa_supplicant` to connect to any open network.
    ```
    network={
    key_mgmt=NONE
    }
    ```
    <span class="notes">**Note** This policy may change in the future.</span>

#### The network block structure

A network block has the following structure:
```
network={
    <network settings>
}
```
Where `<network settings>` contains the configuration details of the network. For example, the following network block specifies a WPA-PSK network, where the:

* SSID is `my-ssid`.
* passphrase is `my-password`.

```
network={
    ssid="my-ssid"
    psk="my-password"
}
```

The parameters that need to be included for the network settings depend upon the type of network connection.  For more examples of the parameters that you should include, refer to the [network block examples](#network-block-examples) at the end of this document.

### Applying network configuration changes

After editing `wpa_supplicant.conf`, run the following commands to make the network configuration changes take effect:

```
ifdown wlan0
ifup wlan0
```

### Configuring network priority

By default, the order in which `wpa_supplicant` attempts to connect to the networks in `wpa_supplicant.conf` is affected by several factors, including:

* The security policies.
* The signal strengths of the networks.

For information about the factors that influence connection attempts, refer to the [reference configuration file][ws_reference_config].

You can influence the network priorities for `wpa_supplicant` by using the `priority` field (an integer) in a network block. Network blocks with higher `priority` values are preferred by `wpa_supplicant`. By default, A network's `priority` is `0`.

**Example**

The following configuration specifies two WPA-PSK networks, with SSIDs `ssid1` and `ssid2`. The `ssid2` network is preferred by `wpa_supplicant` because of the higher `priority` value (`2` is greater than `1`).

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

### Disabling networks

To prevent `wpa_supplicant` from using a specified network, you can mark the network block as `disabled`. In the following example, `wpa_supplicant` will not use the network with SSID `ssid1`:

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

### Checking the wifi connection status

You can use `wpa_cli` to get the status of the current wifi interface; run the following command:

```
wpa_cli status
```

### Discovering wifi networks

You can use `wpa_cli` to discover available networks.

1. Use `wpa_cli` to request a new scan from `wpa_supplicant`, by running the following command:

    ```
    wpa_cli scan

    ```
1. View the results of this scan using the following command:

    ```
    wpa_cli scan_results
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
    ```
This output shows three SSIDs:

* `ExampleOpenNetwork` - an open network with six known BSSIDs.
* `ExampleWPAPersonalNetwork` - a WPA-PSK network with a single known BSSID.
* `ExampleWPAEnterpriseNetwork` - a WPA-Enterprise network with six known BSSIDs.

There are example configurations for networks of these types [below](#network-block-examples).

### Network blocks examples

The following sections provide an example network block for connection to a:

* Named open network.
* WPA-PSK network.
* WPA2-Enterprise network.

For more examples, refer to the `wpa_supplicant` [man page][ws_man_page].

#### Connecting to a named open network

To specify an open network with the SSID `my-ssid`, add the following network block to `wpa_supplicant.conf`:

```
network={
    ssid="my-ssid"
    key_mgmt=NONE
}
```

#### Connecting to a WPA-PSK network

To specify a WPA-PSK (WPA-Personal) network with SSID `my-ssid` and passphrase `my-passphrase`, add the following block to `wpa_supplicant.conf`:

```
network={
    ssid="my-ssid"
    key_mgmt=WPA-PSK
    psk="my-passphrase"
}
```
Alternatively, you can use a hash of the passphrase rather than using it in plain text to the configuration file.

**Generating a hash of a passphrase**

To generate a network block containing the hash, use the `wpa_passphrase` utility, as follows:

```
wpa_passphrase my-ssid my-passphrase

network={
        ssid="my-ssid"
        #psk="my-passphrase"
        psk=85892d35689549be10f89580f60dd53dd3e65696fe61f4a8e99ac75e110d94c7
}
```
Remove the line containing `my-passphrase` before adding the network block to `wpa_supplicant.conf`:

```
network={
        ssid="my-ssid"
        psk=85892d35689549be10f89580f60dd53dd3e65696fe61f4a8e99ac75e110d94c7
}
```
<span class="notes">**Note** Although this network block does not contain the original passphrase in plain text, knowing the hash of the passphrase is enough to gain access to the network.</span>

### Connecting to a WPA2-Enterprise network

There are many different configurations for WPA2-Enterprise networks. The following network block is an example for connecting to a PEAP/EAP-MSCHAPv2 authenticated WPA2-Enterprise network called `my-ssid`, as the user `my-username` with password `my-password`. See the `wpa_supplicant` [man page][ws_man_page] for more examples.

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

Mbed Linux does not currently support saving the username or password in secure storage, so if you need to persistently store these settings, you must store them in the configuration file in plain text.

If you do not need to persistently store these settings, and want to avoid adding them to configuration file, you can use `wpa_cli` to provide them. To do this:

1. Add the network block to `wpa_supplicant.conf` but without the sensitive information:
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
1. Bring the wireless interface down and back up:
```
ifdown wlan0
ifup wlan0
```
1. Determine the network id that `wpa_supplicant` uses for the network using the following `wpa_cli` command:
```
wpa_cli list_networks
Selected interface 'wlan0'
network id / ssid / bssid / flags
0       some-ssid  any
1       my-ssid    any
```
   Make a note of the network id for the SSID of your network (in this example `my-ssid`).
1. Use `wpa_cli` to provide the required credentials for this network, as follows:
```
wpa_cli set_network 1 identity "my-username"
wpa_cli set_network 1 password "my-password"
```
    ...where `1` is the network id.

   These credentials will be used until `wpa_supplicant` dies, but will not be written to `wpa_supplicant.conf` (unless you run `wpa_cli save`).

To avoid leaving passwords in terminal logs, you could use a shell function, for example:

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
