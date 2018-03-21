# Troubleshooting

**Work in progress - this document is currently just some notes taken from
README.md that didn't belong there any more.**

## Bitbake issues
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
