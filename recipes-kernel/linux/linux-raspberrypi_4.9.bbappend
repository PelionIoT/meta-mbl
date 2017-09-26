# Use the latest source revision in the repo as we are developing it.
SRCREV = "ba742b52e5099b3ed964e78f227dc96460b5cdc0"

SRC_URI = "git://git@github.com/ARMmbed/mbl-linux.git;protocol=ssh;branch=linaro-4.9-rpi3 \
           file://defconfig"

# Disable version check so that we don't have to edit this recipe every time
# when this development branch bumps the version
KERNEL_VERSION_SANITY_SKIP = "1"
