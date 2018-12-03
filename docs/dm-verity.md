## dm-verity

Copyright © 2018 Arm Limited.

### Introduction
[dm-verity](https://gitlab.com/cryptsetup/cryptsetup/wikis/DMVerity) provides transparent integrity checking of read only block devices using a cryptographic digest provided by the kernel crypto API.
dm-verity is implemented using a pre-calculated hash tree which includes the hashes of all device blocks. 
The leaf nodes of the tree include hashes of physical device blocks, while intermediate nodes are hashes of their child nodes (hashes of hashes). 
The root node is called the root hash and is based on all hashes in lower levels.

### Current dm-verity development state

Integration of dm-veirty is in progress but its not yet completed. Here is the current status of the integration:

#### InitRamFs

InitRamFs and InitRamFs init script is used to verify the signature of the root hash and to activate dm-verity.
Relevant recipie and init script can be found here:
* ```meta-mbl/recipes-core/images/mbl-console-image-initramfs.bb```
* ```meta-mbl/recipes-core/mbl-initramfs-init/files/initramfs-init-script.sh```

Currently the InitRamFs init script is not yet activating dm-verity and it is just mounting the active roofs and continue with the boot sequence.

#### Partitions for dm-veriant artifacts
In order to activate dm-verity for rootfs image, the following metadata is needed:

* dm-verity hash tree 
* root hash
* root hash signature

This metadata is included in a separate read-only partition and will be available to initramfs init script for mounting and reading the metadata. 
There are two rootfs partitions, one partition per bank, and for each one of them there is a corresponding dm-verity metadata partition.

#### dm-verity private keys
dm-verity root hash is intended to be signed and verified during boot. We temporary store a private key in [meta-mbl repo](https://github.com/ARMmbed/meta-mbl) for development purposes only, and later on the private key will be removed and signing mechanism will be re-designed.
The private key is located at: ```/layers/meta-mbl/verity_keys/verity_rootfs_root_hash_private.pem```
