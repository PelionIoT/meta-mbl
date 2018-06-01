# Mbed Linux OS (mbl) Troubleshooting

## General tips

### Using the test images

Troubleshooting and development can sometimes be much easier when using the
"test" variant of the mbl images rather than the standard images due to the
inclusion of an SSH client and server, allowing files to be easily copied
between the IoT device and a development PC using `scp`. To create test images,
specify `mbl-console-image-test` rather than `mbl-console-image` when running
Bitbake:
```
bitbake mbl-console-image-test
```
In particular, this makes collecting log files much easier. See the
[logs][mbl-logs] documentation for more information.


## Wi-Fi

### Ensure Wi-Fi traffic is not being redirected to a login server
When using open Wi-Fi hotspots it is common for all traffic to be redirected to
a login server until the connection has been properly authenticated. When this
is the case, pinging public web servers may appear to work and indicate that the
device is connected to the Internet when, in fact, it isn't. For example:
```
ping google.com
```
may appear to work when in reality the replies are coming from a login server
for the Wi-Fi network. The standard mbl images do not come with sophisticated
network troubleshooting tools, but Wget, which is included, can be useful to
determine whether a connection to the Internet is actually available because
the contents of a file downloaded with Wget file can be examined.


## Bitbake

### Multiple build directories (don't use them)
It is possible to create multiple build directories (default `build-mbl`) in
the meta-mbl workspace at the same level as the .repo subdirectory by
specifying a directory to the setup-environment script:
```
MACHINE=raspberrypi3-mbl DISTRO=mbl . setup-environment mybuild-dir1
```

The `*.conf` files must then be modified to store the sstate-cache directory in
`mybuild-dir1` so as not to be shared with other builds. However, this
configuration has been found to cause (unspecified) problems.

### Wget `trust_server_names=on` option (don't use it)
Do not to use the Wget `trust_server_names=on` option in a `.wgetrc` file. i.e.:
```
trust_server_names = on
```

This results in Wget using the last component of a redirection URL (e.g.
1.20170405) for the local file name rather than using the requested URL
filename (e.g. 1.20170405.tar.gz).  This causes problems for Bitbake recipes
that expect the file name requested in the URL (with the .tar.gz extension).

[mbl-logs]: logs.md
