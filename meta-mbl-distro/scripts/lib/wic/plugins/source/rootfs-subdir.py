# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""
This implements the 'rootfs-subdir' source plugin class for 'wic'.

The plugin is to create a partition whose contents are a subdirectory of the
root file system.
"""


import logging
import os
import shutil

from wic import WicError
from wic.pluginbase import SourcePlugin
from wic.misc import exec_cmd

logger = logging.getLogger("wic")


class RootFsSubdirPlugin(SourcePlugin):
    """Populate partition content from a subdirector of the root directory."""

    name = "rootfs-subdir"

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
        rootfs_dir_dict,
        native_sysroot,
    ):
        """Populate a partition from a subdirectory of the root file system."""
        try:
            rootfs_dir = rootfs_dir_dict["ROOTFS_DIR"]
        except KeyError:
            raise WicError("Couldn't find rootfs dir, exiting")

        try:
            subdir = source_params["subdir"].strip("/")
        except KeyError:
            raise WicError(
                "Required source parameter 'subdir' not found, exiting"
            )

        subdir_src = os.path.join(rootfs_dir, subdir)
        subdir_dst = os.path.join(cr_workdir, subdir)

        logger.debug("Rootfs dir: {}".format(rootfs_dir))
        logger.debug("Subdir source dir: {}".format(subdir_src))
        logger.debug("Subdir dest dir: {}".format(subdir_dst))

        shutil.copytree(subdir_src, subdir_dst)

        part.prepare_rootfs(
            cr_workdir, oe_builddir, subdir_dst, native_sysroot
        )
