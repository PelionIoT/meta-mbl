#!/bin/sh

# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

HOME_APP=__REPLACE_ME_WITH_MBL_APP_DIR__

# start all installed OCI containers in MBL_APP_DIR directory
echo "Looking for installed containers in $HOME_APP..." 1>&2

# check all subdirectories in MBL_APP_DIR
for dir in "$HOME_APP"/*; do

    if ! [ -d "$dir" ]; then
        # if $dir is not a directory - continue to next entry
        continue
    fi

    # OCi container should have config.json in container's root direcotry
    file=$dir/config.json
    if ! [ -f "$file" ]; then
        # if $dir has no config.json file - continue to next entry
        continue
    fi

    # valid OCI container config.json file should define "ociVersion"
    if grep -Fq "ociVersion" "$file";then

        # try running the application using MBL App Lifecycle Manager now
        # that an OCI container has been found
        app_identifier=${dir##*/}
        echo "Starting $app_identifier app"
        mbl-app-lifecycle-manager --run-container "$app_identifier" --application-id "$app_identifier" --verbose
    fi

done
