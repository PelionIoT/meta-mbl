# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Purpose: 
# Convert the license.manifest files output from license_image.bbclass
# to JSON format. 
# This is to make it easier for scripts to create automated license reports.


python generate_rootfs_licenses_json() {
    generate_licenses_json(d, "license.manifest")
}

# The functions to populate the rootfs license manifest are prepended to
# ROOTFS_POSTPROCESS_COMMAND in image_license.bbclass. We need
# to ensure generate_rootfs_licenses_json runs after the license.manifest
# file has been created.
ROOTFS_POSTPROCESS_COMMAND_append = "generate_rootfs_licenses_json; "

# A task is defined in image_license.bbclass to create the license manifest
# for deployed files. We can just append the JSON generation function to that
# task directly.
python do_populate_lic_deploy_append() {
    generate_licenses_json(d, 'image_license.manifest')
}


def generate_licenses_json(d, file_name):
    import os
    import json

    path = os.path.join(
        d.getVar('LICENSE_DIRECTORY'), d.getVar('IMAGE_NAME'), file_name
    )
    data_dict = _from_manifest(path)
    with open("{}.json".format(path), "w") as mjson:
        mjson.write(json.dumps(data_dict))


def _from_manifest(fpath):
    """Parses a license manifest file to a dictionary.

    :params str fpath: file path of the manifest file to parse.
    :returns OrderedDict: license data dict {pkg_name:{license_data:value}}
    """
    from collections import OrderedDict

    output = OrderedDict()
    with open(fpath) as mfile:
        d = mfile.read().split("\n\n")
        for pkgd in d:
            if not pkgd:
                continue
            data = OrderedDict()
            for pline in pkgd.split("\n"):
                if not pline:
                    continue
                key, *val = pline.split(":")
                data[key.strip()] = " ".join(val).strip()
            output[data["RECIPE NAME"]] = data
        return output
