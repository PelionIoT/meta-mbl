# Mbed Linux OS Signing Tool

## Overview

This signing tool is an early release and is still under development. It has the following restrictions:
* The tool has only been tested with the Raspberry Pi 3B+
* The tool uses Hashicorp Vault as an example back-end for the private key storage and signing operations.
* The tool only supports signing for a single device at the moment.

The release version of the tool will support multiple devices; we will provide documentation and guidance for setting access control policies in Vault, and for locking down the Vault machine for production use. **The current flow is only for development use.**

The `signctl` tool automates the basic signing flow for Raspberry PI 3. For more information on the background and details of the signing operations see [the basic signing flow document][mbl-basic-signing-flow].

The signing tool uses [Hashicorp Vault](https://www.hashicorp.com/products/vault/) (as an example back-end) to generate and store the certificates required to verify the Trusted Firmware on Cortex A (TF-A) boot chain.

The Vault secrets model uses 'paths' to 'mount' secrets engines. The 'path' is a REST API endpoint and can be accessed via HTTP requests.

Please see the [Vault secrets engine model](https://www.vaultproject.io/intro/getting-started/secrets-engines#secrets-engines) for more information on how this works.

In the Vault PKI engine, each 'mount' of the secrets engine is usually a root CA or intermediate CA, which can then sign and issue certificates from the endpoints created under the base path. Only one CA is allowed per instance of the PKI engine.

The `signctl` tool uses a CA configured at its own mount to represent the private key for each node in the certificate chain of trust.
The tool then requests leaf certificates from the appropriate mount path, so the corresponding cert is signed by the correct private key.

For more background on the PKI secrets engine see [the Vault documentation](https://www.vaultproject.io/docs/secrets/pki/index.html#one-ca-certificate-one-secrets-engine).


## Install Prerequisites

Before installing the `signctl` tool, you should set up a local dev instance of Vault. The [Vault website](https://www.vaultproject.io/docs/install/#compiling-from-source) provides background information on this.

A helper shell script is included to install `go` and Vault. The script is in the `signctl` dir and is named `setup-vault.sh`. If you don't want to use the shell script (maybe you already have `go` installed), the script automates the following steps:

<span class="notes">**Note:** If you have an existing `go` installation you want to use, ensure it is version 1.11 or higher.</span>

<span class="notes">**Note:** The script (and the following instructions) assume you have `wget`, `git` and `tar` installed and available in your `PATH`.</span>

1. Install `go`
```
$ wget https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz
$ tar -C /usr/local -xzf go1.12.7.linux-amd64.tar.gz
```

2. Set `GOPATH`
```
export GOPATH=$HOME/go
```

3. Add the `go` installation dir to `PATH`
```
$ export PATH=$PATH:/usr/local/go/bin
```

4. Use Go 1.11 modules (required by vault's bootstrapping process)
```
$ export GO111MODULE=on
```

5. Add the `GOPATH/bin` dir to `PATH`
```
$ export PATH=$PATH:$GOPATH/bin
```

6. Clone the Vault repository into your `GOPATH`
```
$ mkdir -p $GOPATH/src/github.com/hashicorp && cd $_
```
```
$ git clone https://github.com/hashicorp/vault.git
```
```
$ cd vault
```

7. Check out the revision of Vault the patch was created on top of.
```
$ git checkout -b atf-pki-engine-changes 7f5e7818fd784ae0b7baa906f2c76cafdc5c28b0
```

The following steps must be performed manually even if you used the helper script.

<span class="notes">**Note:** If you installed using the script you may need to reload your shell for the environment variables to take effect (the script writes the variables to `$HOME/.bashrc`). If you set the env variables manually in the existing session, and didn't save them in your `.bashrc`, do not restart the shell or they will be lost.

```
$ exec $SHELL
```
</span>

1. Apply the git patch (replacing `/path/to` with the actual path to the `signctl` dir).
```
$ git am /path/to/signctl/0001-Add-x509v3-extensions-and-signature-alg-parameters.patch
```

2. Bootstrap Vault's dependencies
```
$ make bootstrap
```

3. Build Vault
```
$ make dev
```

The Vault CLI should now be available. Test it by running the following command:
```
$ vault --help
Usage: vault <command> [args]

Common commands:
    read        Read data and retrieves secrets
    write       Write data, configuration, and secrets
    delete      Delete secrets and configuration
    list        List data or secrets
    login       Authenticate locally
    agent       Start a Vault agent
    server      Start a Vault server
    status      Print seal and HA status
    unwrap      Unwrap a wrapped secret

Other commands:
    audit          Interact with audit devices
    auth           Interact with auth methods
    kv             Interact with Vault's Key-Value storage
    lease          Interact with leases
    namespace      Interact with namespaces
    operator       Perform operator-specific tasks
    path-help      Retrieve API help for paths
    plugin         Interact with Vault plugins and catalog
    policy         Interact with policies
    print          Prints runtime configurations
    secrets        Interact with secrets engines
    ssh            Initiate an SSH session
    token          Interact with tokens

```

## Installing the Signing Tool

Ubuntu 16.04: You must install some packages before following the installation procedure.

```
$ apt-get install git make u-boot-tools build-essential libssl-dev libffi-dev
```

First you should create a Python virtual environment following the steps below. This [tutorial](https://docs.python.org/3/tutorial/venv.html) explains more about Python virtual environments.


<span class="notes">**Note:** If you don't want to create a virtual environment, you can possibly install with `pip --user`. Don't ever install packages into the Ubuntu "system" Python `site-packages`.
Installing outside a virtual environment is not recommended, tested or supported.</span>


1. Create the virtual environment, this example uses Ubuntu system `python3` as the 'base' installation to create the environment:

```
$ python3 -m venv /path/to/venv-folder
```
<span class="notes">**Note:** The venv folder will be created by the `venv` module. It does not need to exist before running the venv command.</span>

2. "Activate" the environment.
```
$ source /path/to/venv/bin/activate
```

3. If you used the Ubuntu system python as the base as shown in the example command you must upgrade the pip installation in the venv. This is because the version of pip that comes with Ubuntu 16.04 doesn't have support for Python wheels.

```
$ python -m pip install --upgrade pip
```

4. Navigate to the `meta-mbl/openembedded-core-mbl/scripts/signing/signctl` folder.

Install from source using `pip`.
```
$ pip install .
```

## Signing Tool Command Line Interface
```
usage: signctl [-h] [--backend-url BACKEND_URL] {generate,sign-tfa} ...

positional arguments:
  {generate,sign-tfa}
    generate            Generate a keychain and store it in the storage
                        backend.
    sign-tfa            Sign TF-A BL and FIP.

optional arguments:
  -h, --help            show this help message and exit
  --backend-url BACKEND_URL
```
```
usage: signctl generate [-h] [--cot-keys] [--ca-ttl CA_TTL]
                        [--cert-ttl CERT_TTL] [--hab-srks]
                        [--output-dir OUTPUT_DIR]

optional arguments:
  -h, --help            show this help message and exit
  --cot-keys            Generate a TF-A chain of trust keychain, store the
                        private keys.
  --ca-ttl CA_TTL       Issuer TTL.
  --cert-ttl CERT_TTL   End entity certificate TTL.
  --hab-srks            Generate super root public keys for NXP HAB.
  --output-dir OUTPUT_DIR
                        The output directory for the HAB SRKs (public part).
```
```
usage: signctl sign-tfa [-h] [--rpi-armstub8 RPI_ARMSTUB8] --fip FIP [FIP ...]
                        [--patch-rotkey] [--output-dir OUTPUT_DIR]

optional arguments:
  -h, --help            show this help message and exit
  --rpi-armstub8 RPI_ARMSTUB8
                        Path to the armstub8.bin
  --fip FIP [FIP ...]   Path to one or more FIPs to be signed.
  --patch-rotkey        Patch root of trust public key hash in to BL1 and BL2.
  --output-dir OUTPUT_DIR
                        Output dir for signed images and the original fip
                        components.
```

## Generating Chain of Trust (CoT) Keychain

You can generate the keychain used for the TF-A CoT using the `signctl generate --cot-keys` command.

Currently the `generate --cot-keys` command creates all of the required CAs up to the root of trust. The private keys are stored in the Vault.

In the release version, the `signctl` tool will support generating individual keypairs in the keychain, allowing for key revocation and access restriction to high security keys.

To use the generate command follow these steps:

1. Ensure your Vault server is running. To run a local dev server use the Vault CLI, `vault server -dev`.
2. Add a file named `.signctl.conf` in your user's home directory. This file should contain only the URL and port of the Vault server, in the form `url:port`. Alternatively you can pass the url and port of the Vault server on the command line, when running the `generate` command, by adding the `--backend-url URL` flag.
3. Run the following command
```
$ signctl generate --cot-keys
```

<span class="notes">**Note:** If using the `--backend-url` flag, it should be entered before the command. For example:

```
$ signctl --backend-url 127.0.0.1:8200 generate --cot-keys
```
</span>

The keys should be shown as generated in the Vault server output. If the `signctl` tool returns with no output it means the keys were successfully generated.

## Signing RPi3 Boot Components

After the keys have been generated and stored in Vault, you can use them to sign the certificates needed to verify the FIP.

To produce the signed leaf certificates and pack them into a FIP use the `signctl sign-tfa` command.

If you saved your Vault server URL in a `.signctl.conf` file as described in the previous section, the `signctl` tool will automatically connect to the Vault server. If not you will have to pass the server URL again on the command line.

You can also patch the root of trust public keys into BL1 and BL2 by using the `--patch-rotkeys` command. The background for this is described in the [the basic signing flow document][mbl-basic-signing-flow].

To sign the FIP, and patch BL1 and BL2, follow the steps below:

1. Locate `armstub8.bin` and `fip2.bin` in the build deploy directory.
2. Enter the following comand
```
$ signctl sign-tfa --rpi-armstub8 /path/to/armstub8.bin --fip /path/to/fip2.bin --patch-rotkey --output-dir /path/to/output/dir/
```

Several folders will be created in your output directory:

```
├── armstub8_components
│   ├── bl1_new.bin
│   └── fip1_new.bin
├── fip_components
│   ├── nt-fw.bin
│   ├── nt-fw-cert.bin
│   ├── nt-fw-key-cert.bin
│   ├── soc-fw.bin
│   ├── soc-fw-cert.bin
│   ├── soc-fw-key-cert.bin
│   ├── tb-fw.bin
│   ├── tb-fw-cert.bin
│   ├── tos-fw.bin
│   ├── tos-fw-cert.bin
│   ├── tos-fw-extra1.bin
│   ├── tos-fw-extra2.bin
│   ├── tos-fw-key-cert.bin
│   └── trusted-key-cert.bin
├── new_certs
│   ├── nt-fw-cert.bin
│   ├── nt-fw-key-cert.bin
│   ├── soc-fw-cert.bin
│   ├── soc-fw-key-cert.bin
│   ├── tb-fw-cert.bin
│   ├── tos-fw-cert.bin
│   ├── tos-fw-key-cert.bin
│   └── trusted-key-cert.bin
└── signed_images
    ├── armstub8_new.bin
    ├── fip1_new.bin
    └── fip2.bin
```

The signed_images directory contains the signed `armstub8.bin` and `fip2.bin`.

## Writing the Signed Components to the SD Card

Connect your SD card, containing an Mbed Linux OS Raspberry PI Image, to your pc. Ensure the partitions are unmounted.

Write `fip2.bin` to a "raw partition" on the flash.
Assuming your SD card is located at `/dev/sdc` run the following command.

```
$ sudo dd if=signed_images/fip2.bin of=/dev/sdc bs=512 seek=2048
1650+1 records in
1650+1 records out
845177 bytes (845 kB, 825 KiB) copied, 0.148319 s, 5.7 MB/s
```

Mount the boot partition and copy `armstub8_new.bin` to it.

```
$ udisksctl mount -b /dev/sdc1
Mounted /dev/sdc1 at /media/<user>/boot.
```
```
$ cp signed_imgs/armstub8_new.bin /media/<user>/boot/armstub8.bin
```
```
$ sync
```
```
$ udisksctl unmount -b /dev/sdc1
Unmounted /dev/sdc1.
```

You can now place the SD card in your RPi3 and it will verify and load the FIP image.
If you're using an Mbed Linux OS distribution it will boot and load Mbed Linux OS.


[mbl-basic-signing-flow]: ../../../docs/basic-signing-flow.md
