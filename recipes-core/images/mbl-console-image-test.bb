###############################################################################
# mbed Linux 
# Copyright (c) 2017 ARM Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
###############################################################################

###############################################################################
# mbl-console-image-test.bb
#   This file is the mbed linux OpenEmbedded recipe for building a minimal 
#   uboot/kernel/filesystem image including test packages. 
###############################################################################

require mbl-console-image.bb

SUMMARY = "Mbed Linux Basic Minimal Image With Test Packages"
DESCRIPTION = "Image with development, debug, SDK and test support."

###############################################################################
# Uncomment the following lines as required to include the feature in the test
# image. Note, there is a maximum image size of ~2.5GB which is exceeded if all
# features are included.
###############################################################################

# IMAGE_FEATURES += " dev-pkgs"
# IMAGE_FEATURES += " ptest-pkgs"
# IMAGE_FEATURES += " tools-sdk"
# IMAGE_FEATURES += " tools-debug"
# IMAGE_FEATURES += " tools-testapps"

IMAGE_INSTALL += " \
	packagegroup-mbl-test \
	"