SUMMARY = "Mbed Linux Basic Console Image"

IMAGE_FEATURES += "splash package-management debug-tweaks ssh-server-openssh hwcodecs tools-debug"

LICENSE = "MIT"

inherit core-image distro_features_check extrausers

# let's make sure we have a good image..
REQUIRED_DISTRO_FEATURES = "pam systemd"

EXTRA_USERS_PARAMS = "\
useradd -p '' linaro; \
"
