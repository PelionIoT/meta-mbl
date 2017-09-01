# Introduction to meta-mbl

This is the (Unofficial) mbed Linux (MBL) OpenEmbedded (OE) distribution layer for creating mbed linux IoT file system images.

The main components of the layer are: 
- meta-mbl/conf/mbl.conf. This is the OE distribution configuration for creating an mbed linux distribution.
- meta-mbl/recipes-core/images/mbl-console-image.bb. This is the OE recipe for creating a minimal image. 

The current size information is as follows:
- size of bcm2835-bootfiles (uboot?): ~12MB
- size of kernel Image: ~13MB
- size of rootfs: ~12MB (approx 8MB files actually present).
- size of sdcard image: ~56MB (system is ~33MB where boot partition is ~25MB (kernel+uboot) and rootfs partition is ~8MB).

An indicative list installed packages is as follows:
- base-files base-passwd busybox busybox-syslog busybox-udhcpc 
- eudev
- init-ifupdown initscripts-functions initscripts
- kbd keymaps
- libattr1 libblkid1 libc6 libkmod2 libuuid1 libz1
- modutils-initscripts
- netbase
- packagegroup-core-boot
- run-postinsts
- shadow-base shadow-securetty shadow sysvinit-inittab sysvinit-pidof sysvinit
- udev-cache update-alternatives-opkg update-rc.d util-linux-sulogin

# Dependencies

The meta-mbl layer depends on:

	URI: git://git.openembedded.org/openembedded-core
	layers: meta

	URI: git://git.openembedded.org/meta-openembedded
	layers: meta-oe
	branch: master

# Outstanding Issues

The following is a list of outstanding issues:
- Where should the meta-mbl repository live? (github.com/armmbed/meta-mbl was created for initial convenience). 
  Update this document with new repo location when this is decided.s
- What is the top level repo license file? Its currently Apache 2.0 as this is the github default when creating a repo.
- What instructions do we want to put in here? 
	- Should the section "Instructions for Building Image"  be included in an md file, in a txt file, or 
	  the confluence document updated?
	- We need to update the mbl-manifest repo: 
		- pinned-manifest.xml to include the addition of the meta-mbl repo? 
		- bblayers.conf to include the meta-mbl.conf file be default?
		- Shall I make a PR to the mbl-ci branch?
- What header needs to be on our files? Currently a modified version of the mbedOS file header has been added.
- Docker package needs to be added.

# Instructions for Building Image

The base instructions for building images are here:

https://confluence.arm.com/display/mbedlinux/How+to+Build+a+raspberrypi3+mbl-manifest+SDcard+Image

The instructions need to be updated as follows:

After the repo init command in Step 1, the pinned-manifest.xml needs to be edited to include the armmbed/meta-mbl line
after the openembedded/openembedded-core line:

	  <project name="openembedded/openembedded-core" path="layers/openembedded-core" remote="github" revision="598e5da5a2af2bd93ad890687dd32009e348fc85" upstream="master"/>
	  <project name="armmbed/meta-mbl" path="layers/meta-mbl" remote="github" revision="4e0bea5faf8559db69e9da145c3bb5cfa4cf1015" upstream="master"/>
	</manifest>

Update the revision to be the latest commit ID for the armmbed/meta-mbl repo. Then do repo sync and check that the layers
subdirectory contains meta-mbl.
 

Step 2 should use the following command:
	
	MACHINE=raspberrypi3 DISTRO=mbl . setup-environment
	
Then edit the conf/bblayers.conf file so that BBLAYERS includes the meta-mbl layer i.e.:

	BBLAYERS = " \
	  ${OEROOT}/layers/meta-mbl \
	  ${OEROOT}/layers/meta-rpb \
	  ${BASELAYERS} \
	  ${BSPLAYERS} \
	  ${EXTRALAYERS} \
	  ${OEROOT}/layers/openembedded-core/meta \
	  "
 

Step 3 should use the following command:

	bitbake mbl-console-image | tee build_log.txt
	
Step 4 should use the following command to write the mbl-console-image to sdcard: 

	sudo dd if=mbl-console-image-raspberrypi3-64.rpi-sdimg of=/dev/sdd status=progress bs=4M
	
	

# Contributing

Please use github for pull requests: https://github.com/armmbed/meta-mbl/pulls


# Reporting bugs

The github issue tracker (https://github.com/armmbed/meta-mbl/issues) is being used to keep track of bugs.


# Maintainers

* Simon Hughes <simon.hughes@arm.com>
* Marcus Shawcroft <marcus.shawcroft@arm.com>
