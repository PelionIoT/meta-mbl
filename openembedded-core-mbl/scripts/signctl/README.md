# Mbed Linux OS Signing Tool

## Overview

This signing tool is an early release and is still under development. It has the following restrictions:
* The tool has been tested with the Raspberry Pi 3B+, PICO PI with IMX7D SoM, PICO-PI with IMX6UL SoM and NXP 8M Mini EVK devices.
* The tool uses Hashicorp Vault as an example backend for the private key storage and signing operations.
* The tool only supports signing for a single device at the moment. Although a multi-device flow is possible if you configure a separate Vault instance for each device.

The release version of the tool will provide full support for multiple devices; we will also provide documentation and guidance for setting access control policies in Vault and for locking down the Vault machine for production use. **The current flow is only for development use.**

The `signctl` tool automates the signing flow for Trusted Firmware on Cortex A (TF-A) BL2 and FIP images. For more information on the background and details of the signing operations see [the basic signing flow document][mbl-basic-signing-flow].

The signing tool uses [Hashicorp Vault](https://www.hashicorp.com/products/vault/) (as an example backend) to generate and store the certificates required to verify the TF-A boot chain.

The Vault secrets model uses 'paths' to 'mount' secrets engines. The 'path' is a REST API endpoint and can be accessed via HTTP requests.

See the [Vault secrets engine model](https://www.vaultproject.io/intro/getting-started/secrets-engines#secrets-engines) for more information on how this works.

In the Vault PKI engine, each 'mount' of the secrets engine is usually a root CA or intermediate CA, which can then sign and issue certificates from the endpoints created under the base path. Only one CA is allowed per instance of the PKI engine.

The `signctl` tool uses a CA, configured at a Vault PKI mount, to represent the private key for each node in the certificate chain of trust.
The tool then requests leaf certificates from the appropriate mount path, so the corresponding cert is signed by the correct private key.

For more background on the PKI secrets engine see [the Vault documentation](https://www.vaultproject.io/docs/secrets/pki/index.html#one-ca-certificate-one-secrets-engine).

For more information on the TF-A boot flow see the [trusted board boot documentation](https://github.com/ARM-software/arm-trusted-firmware/blob/master/docs/design/trusted-board-boot.rst).

## Install Prerequisites

Before installing the `signctl` tool, you should set up a local dev instance of Vault. You must also apply the git patch included in this directory to Vault. The patch changes the Vault interface to support the TF-A public key infrastructure. The [Vault website](https://www.vaultproject.io/docs/install/#compiling-from-source) provides background information on the Vault installation.

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

1. Apply the git patch (replacing `/path/to` with the path to the `signctl` dir).
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
usage: signctl [-h] [--backend-url BACKEND_URL] {generate,sign} ...         
                                                                            
positional arguments:                                                       
  {generate,sign}                                                           
    generate            Generate a keychain and store it in the storage     
                        backend.                                            
    sign                Sign TF-A bootloader components.                    
                                                                            
optional arguments:                                                         
  -h, --help            show this help message and exit                     
  --backend-url BACKEND_URL                                                 

```
```
usage: signctl sign [-h] [--rpi-vc4-fw PATH | --bl2 PATH]                          
                    [--fip PATH [PATH ...]]                                        
                                                                                   
optional arguments:                                                                
  -h, --help            show this help message and exit                            
  --rpi-vc4-fw PATH     Path to a Raspberry-PI 3 VC4 firmware image (e.g           
                        armstub8.bin) to be signed. Note, TF-A BL2 is also in      
                        the VC4 firmware image. To sign BL2 on raspberrypi3        
                        use this option, not the --bl2 option.                     
  --bl2 PATH            Path to a TF-A BL2 image to be signed.                     
  --fip PATH [PATH ...]                                                            
                        Path to one or more FIPs to be signed.                     

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
  --hab-srks            Generate super root keys for NXP HAB.                    
  --output-dir OUTPUT_DIR                                                        
                        The output directory for the HAB SRKs (public part).     
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

You can also use the root-of-trust (ROT) key generated earlier to patch BL2 (which is contained in the VC4 firmware binary) with the ROT public key, which is also required for the certificate verification.

To produce the signed leaf certificates and pack them into a FIP use the `signctl sign` command.

If you saved your Vault server URL in a `.signctl.conf` file as described in the previous section, the `signctl` tool will automatically connect to the Vault server. If not you will have to pass the server URL again on the command line.

To sign the FIP and patch the ROT public key into the VC4 firmware, follow the steps below:

1. Locate the VC4 binary (`armstub8.bin`) and `fip2.bin` in the build deploy directory.
2. Execute the `sign` command
   
```
$ signctl sign --rpi-vc4-fw /path/to/armstub8.bin --fip /path/to/fip2.bin
```

The images will be signed in-place; the output path for the signed image will be the same as the input path.

## Signing NXP IMX Boot Components

As above, you can use the keys generated earlier to sign the certificates needed to verify the FIP.

You also must to patch BL2 with the ROT public key, as TF-A uses this to verify the root of the certificate chain.

To sign the FIP, and patch BL2, follow the steps below:

1. Locate `bl2.bin.imx` and `fip.bin` in the build deploy directory.
2. Execute the `sign` command

```
$ signctl sign --bl2 /path/to/bl2.bin --fip /path/to/fip.bin
```

<span class="notes">**Note:** On NXP 8M Mini EVK devices, BL2 is contained in `imx-boot-imx8mmevk-mbl-sd.bin-flash_evk` the path of which should be passed to the `--bl2` option instead of `bl2.bin.imx`.</span>

## Create an update payload using the signed images

Use the `create-update-payload` script as described in the [updating a device document](https://os.mbed.com/docs/mbed-linux-os/latest/update/updating-an-mbl-image.html).

You can follow the steps in the update document to update the component on your device.

<span class="notes">**Note:** BL2 is referred to as "boot component 1" and the FIP is "boot component 2" in our update flow.</span>

[mbl-basic-signing-flow]: ../../../docs/basic-signing-flow.md
