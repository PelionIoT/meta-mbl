# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""
This implements the 'non-rootfs-subdir' source plugin class for 'wic'.

The plugin is to create a partition whose contents are a directory that isn't a
subdirectory of the root file system.
"""

import logging
import os
import shutil

from wic import WicError
from wic.pluginbase import SourcePlugin
from wic.misc import get_bitbake_var

logger = logging.getLogger("wic")


class NonRootFsSubdirPlugin(SourcePlugin):
    """Populate partition content from a given directory."""

    name = "non-rootfs-subdir"

    @classmethod
    def do_prepare_partition(
        cls,
        part,
        source_params,
        cr,
        cr_workdir,
        oe_builddir,
        bootimg_dir,
        kernel_dir,
        dir_dict,
        native_sysroot,
    ):
        """Populate a partition given directory with files."""
        img_link_name = get_bitbake_var("IMAGE_LINK_NAME")
        signed_base64_root_hash_suffix = ".root_hash.txt.sha256.base64"
        img_deploy_dir = get_bitbake_var("IMGDEPLOYDIR")

        try:
            subdir = source_params["subdir"]
        except KeyError:
            raise WicError(
                "Required source parameter 'subdir' not found, exiting"
            )

        subdir_src = os.path.join(img_deploy_dir, subdir)
        subdir_dst = os.path.join(cr_workdir, subdir)

        logger.debug("Subdir source dir: {}".format(subdir_src))
        logger.debug("Subdir dest dir: {}".format(subdir_dst))

        shutil.copytree(subdir_src, subdir_dst)

        part.prepare_rootfs(
            cr_workdir, oe_builddir, subdir_dst, native_sysroot, False
        )
