# Introduction to mbed Linux (mbl) OpenEmbedded Layer meta-mbl 

This is the mbed Linux OpenEmbedded (OE) distribution layer for creating mbed linux IoT file system images.
mbed linux provides the software stack for a secure trusted execution environment for applications. This is 
built using the following main components:
- The bootloader chain (Broadcom bootloader and/or u-boot for example).
- Optee (https://github.com/OP-TEE/optee_os).
- Docker

meta-mbl provides the recipes for building the above software by leveraging the Yocto-OE-Bitbake ecosystem.    
The main components of the layer are: 
- meta-mbl/conf/mbl.conf. This is the OE distribution configuration for creating an mbed linux distribution.
- meta-mbl/recipes-core/images/mbl-console-image.bb. This is the OE recipe for creating a minimal image. 

See Appendix 1 for more detailed information on distribution and image composition.


# Instructions for Building Images

### Overview

This section describes how to build mbed linux distribution images for the RaspberryPi3 and to perform 
a basic sanity test verifying the image is working. This is accomplished by working through
the following steps:

1. Review prerequisites and install required tools and packages e.g. the repo tool. 
2. Create a workspace for the mbed-linux project: https://github.com/ARMmbed/mbl-manifest (using the repo tool).
3. Setup the environment and configure the build {machine=raspberrypi3, distro=mbl} by sourcing the setup_environment script.
4. Build the mbl-console-image with the bitbake tool.
5. Flash the image onto an SDCard.
6. Boot the image and check the system works by running a sanity test.
7. Review miscellaneous tips and guidance.

Each step is described in the sections that follow.

### Step 1: Review Prerequisites

Check whether the repo tool is installed:

	$ repo
	usage: repo COMMAND [ARGS]
	The most commonly used repo commands are:
	  ...
	  init           Initialize repo in the current directory
	  ...
	  sync           Update working tree to the latest revision
	  <output removed to save space >

If not then install the tool as follows:

	mkdir ~/bin
	PATH=~/bin:$PATH
	
	curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
	chmod a+x ~/bin/repo

Check that the following packages are installed:
- curl. This is required for retrieving the repo tool, for example.
- git. This is used by the repo tool.
- chrpath. This is needed by bitbake.
- texinfo. This is needed by bitbake which needs the included package makeinfo.		  
- whiptail. This is used by the mbl-manifiest repository setup-environment script if 
  the MACHINE and DISTRO variables are not set on the command line (see later).

For example, on an Ubuntu 16.04 bash terminal you can do this: 

	$ apt list --installed > installed.txt && for i in curl git chrpath texinfo whiptail; do grep -ne ^$i -r installed.txt; done && rm installed.txt

and receive output like this if the packages are installed:

	110:curl/xenial-security,xenial-updates,now 7.47.0-1ubuntu2.2 amd64 [installed]
	306:git/xenial-security,xenial-updates,now 1:2.7.4-0ubuntu1.2 amd64 [installed]
	307:git-man/xenial-security,xenial-security,xenial-updates,xenial-updates,now 1:2.7.4-0ubuntu1.2 all [installed,automatic]
	308:gitk/xenial-security,xenial-security,xenial-updates,xenial-updates,now 1:2.7.4-0ubuntu1.2 all [installed]
	79:chrpath/xenial,now 0.16-1 amd64 [installed]
	1855:texinfo/xenial,now 6.1.0.dfsg.1-5 amd64 [installed]
	1967:whiptail/xenial,now 0.52.18-1ubuntu2 amd64 [installed]

if not then install the missing package e.g. 

	sudo apt-get install curl


### Step 2: Create the Workspace

Create a work space directory (e.g. mblws) and cd into it. Then initialise the workspace with repo init from mbl-manifest:

	repo init -u https://github.com/armmbed/mbl-manifest.git -b master -m pinned-manifest.xml

where: 

- The -b option specifies the branch to check out.
- The -m option specifies the manifest. The pinned-manifest.xml has specific revisions (git commit SHA ids) of
  the repositories to select a working set.

The mblws/.repo/manifests/pinned-manifest.xml specifies revisions for OE layers used to build the project workspace. 
Edit the armmbed/meta-mbl revision="4e0bea5..." to be the latest 
commit ID for the armmbed/meta-mbl repo (see the line after the openembedded/openembedded-core line):

	  <project name="openembedded/openembedded-core" path="layers/openembedded-core" remote="github" revision="598e5da5a2af2bd93ad890687dd32009e348fc85" upstream="master"/>
	  <project name="armmbed/meta-mbl" path="layers/meta-mbl" remote="github" revision="4e0bea5faf8559db69e9da145c3bb5cfa4cf1015" upstream="master"/>
	</manifest>

Next get repo to retrieve the git projects specified in the manifest:

	repo sync

This fetches the sources from the repositories specified in the manifest file (including the meta-mbl layer) and builds the workspace.
The meta-mbl sources will appear at mblws/layers/meta-mbl, for example.

Note: if you want to update the mblws/layers/meta-mbl sources to be a later commit, edit the pinned-manifest.xml file to set the desired
revision and then repo sync. This will bring down the newly specified revision of the sources.  


### Step 3: Setup the Build Environment

Next, initialise the environment by sourcing the setup-environment script. Sourced without arguments or environment variables the script will prompt for machine and distro to build but these can be specified directly on the command line:

	MACHINE=raspberrypi3 DISTRO=mbl . setup-environment

This creates a build directory mblws/build-mbl. 


### Step 4: Build the Image

Next build the image:

	bitbake mbl-console-image | tee build_log.txt

This takes about 45mins on an Intel Xeon with 16 cores running at 200GHz and 32GB RAM.


### Step 5: Flash the SDCard with the Image

Prior to inserting the SDCard, get a list of current devices by typing:

	ls -la /dev/sd*
	
Insert the SDCard and repeat the above command to identify the device associated with the card you 
wish to flash. Lets assume that the new card is /dev/sdd.

Your host will likely automount the /dev/sdd partitions. Before copying the image to the SDCard, 
umount those partitions using the following commands:

- Use "mount -l" to give the current mount points.
- Use "sudo umount <mount_point>" for all of the mounts /dev/sdd partitions, so the device is unmounted.
- Use "mount -l" to check that there are no mountpoints on the /dev/sdd device.

Then in the build-mbl dir use the following command to find the location of the SDCard image:

	find tmp*/ -iname "rpb-console-image*sdimg"
	
For example, the reported files should including this one (or similar for different {machine, distro} tuples):

	tmp-rpb-glibc/deploy/images/raspberrypi3/mbl-console-image-raspberrypi3.rpi-sdimg
	<other output removed>
	 
Next flash the SDCard with the following commands:

	cd tmp-rpb-glibc/deploy/images/raspberrypi3/
	sudo dd if=mbl-console-image-raspberrypi3.rpi-sdimg of=/dev/sdd status=progress bs=4M

This should take approximately 15-30s to flash the card (depending on the size of the image). 
If within a couple of seconds it completes (even without reporting an error) then its 
likely an error has occurred flashing the card. Sometimes this is a result of the card still being mounted.

In order to get UART output from the RPi3, add enable_uart=1 to boot/config.txt. Find where /dev/sdd1 is 
mounted in the host system, find config.txt in the mounted directory and append enable_uart=1 to config.txt.  


### Step 6: Sanity Test the Image Works

To check that the image works you can perform the following sanity test:
- Insert the SDCard into a powered off board. 
- Connect the console cable to the RPI header pins, the USB cable to power the RPi3, and
  insert an ethernet cable (giving access to the internet) into the ether port.  

You should be able to connect with a 
terminal application with settings:
- baud 115200 
- 8N1 
- HW & SW flow control off 

and see the boot console trace e.g. by using minicom:

	sudo minicom --device=/dev/ttyUSB0 
	
The board should boot to the login prompt. Use the following login credentials:
- username: root
- password: (emtpy, just type RETURN)

Check that the docker cli is working (independent of the ability to fetch images) by using:

	docker info
	
Then test docker can fetch/run an image correctly:

	docker run armhf/hello-world

On success you'll see the following line in the output:

	Hello from Docker on armhf!
	This message shows that your installation appears to be working correctly.


### Step 7: Miscellaneous Guidance for Building Images

#### Bitbake Tips

Note the following issues experienced by developers using bitbake in the mbl-manifest created workspace:
- WARNING: Do not source the setup-environment script more that once in a terminal session.
  Invoking the script a second time generates incorrect environment variables 
  used for bitbake paths, and then bitbake <target> commands will fail
  in unexptected places which have previously built without problems.
- WARNING: It's possible to create multiple build directories in the mblws workspace at the same level as
  the .repo sub-directory by specifying a directory to the setup-environment script:  

	MACHINE=raspberrypi3 DISTRO=mbl . setup-environment mybuild-dir1

  The *.conf files must then be modified to store the sstate-cache directory in mybuild-dir1
  so as not to be shared with other builds. However, this configuration has found to 
  cause (unspecified) problems.
- Build history including installed packages and image size information can be enabled by
  uncommenting the buildhistory lines in mbl.conf. See mbl.conf for further details.
- WARNING: Do not to use the wget trust_server_names=on option in a .wgetrc file e.g.:

	trust_server_names = on
	

	// Use the last component of a redirection URL for the local file name           
  This results in wget using the last component of a redirection URL (e.g. 1.20170405) 
  for the local file name rather than using the requested URL filename (e.g. 1.20170405.tar.gz).
  This causes problems for the bitbake recipe what can't file the expected file (with
  the .tar.gz extension). 


#### Sanity Testing Tips

If you don't see terminal output, check that your settings are similar to these for minicom:

	CTRL-A Z/ O (cOnfigure minicom)/Serial Port Setup
		Serial device         : /dev/ttyUSB0
		Lockfile location     : /var/lock
		Callin Program        :
		Callout Program       :
		Bps/Par/Bits          : 115200 8N1
		Hardware Flow Control : No
		Software Flow Control : No
	
	CTRL-A Z/ O (cOnfigure minicom)/Screen and Keyboard
	    <some setting removed>
		Add Line Feed         : No
		Local Echo            : No
		Add carriage return   : No
	    

# The mbed linux Project 

### Policies

The project has adopted the following policies:

- Images are as small as possible by default.
- Image are secure by default.


### Contributing

Please use github for pull requests: https://github.com/armmbed/meta-mbl/pulls


### Reporting bugs

The github issue tracker (https://github.com/armmbed/meta-mbl/issues) is being used to keep track of bugs.


### Maintainers

* Jonathan Haigh <jonathan.haigh@arm.com>
* Simon Hughes <simon.hughes@arm.com>
* Marcus Shawcroft <marcus.shawcroft@arm.com>


# Appendix 1: mbl-console-image Dependency, Package and Size Information

### packagegroup-core-boot Packages 

These are the packages included in packagegroup-core-boot:
- base-files base-passwd busybox busybox-syslog busybox-udhcpc 
- eudev
- init-ifupdown initscripts-functions initscripts
- kbd keymaps
- libattr1 libblkid1 libc6 libkmod2 libuuid1 libz1
- modutils-initscripts
- netbase
- run-postinsts
- shadow-base shadow-securetty shadow sysvinit-inittab sysvinit-pidof sysvinit
- udev-cache update-alternatives-opkg update-rc.d util-linux-sulogin

### Docker Packages

These are the packages needed to make docker work:
- docker
- iptables
- kernel-modules

### Image Size Information 

The image size information (without docker) is as follows:
- size of bcm2835-bootfiles (uboot?): ~12MB
- size of kernel Image: ~13MB
- size of rootfs: ~12MB (approx 8MB files actually present).
- size of SDCard image: ~56MB (system is ~33MB where boot partition is ~25MB (kernel+uboot) and rootfs partition is ~8MB).

Including docker changes:
- size of rootfs: ~166MB (due to including the docker package which requires meta-virtualization, meta-networking etc.).

### Dependencies

The meta-mbl layer depends on:

	URI: git://git.openembedded.org/openembedded-core
	layers: meta

	URI: git://git.openembedded.org/meta-openembedded
	layers: meta-oe
	branch: master


