# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""Provides an abstract factory for creating objects for building payloads."""

import abc
import pathlib

from mbl.update.appsimage import MBL_APPS_ID
from mbl.update.bootimage import MBL_BOOT_ID
from mbl.update.payloadarchiver import MBL_PAYLOAD_ARCHIVER_ID
from mbl.update.rootfsimage import MBL_ROOTFS_ID
import mbl.update.versionedclassregistry as vcr
from mbl.update.wksbootloaderslotimage import (
    MBL_WKS_BOOTLOADER1_ID,
    MBL_WKS_BOOTLOADER2_ID,
)
import mbl.util.tinfoilutil as tutil


class PayloadBuilder:
    """Factory for objects used to build payloads."""

    _payload_format_specs = {
        1: {
            MBL_PAYLOAD_ARCHIVER_ID: 1,
            MBL_WKS_BOOTLOADER1_ID: 1,
            MBL_WKS_BOOTLOADER2_ID: 1,
            MBL_BOOT_ID: 1,
            MBL_ROOTFS_ID: 1,
            MBL_APPS_ID: 1,
        },
        3: {
            MBL_PAYLOAD_ARCHIVER_ID: 3,
            MBL_WKS_BOOTLOADER1_ID: 3,
            MBL_WKS_BOOTLOADER2_ID: 3,
            MBL_BOOT_ID: 3,
            MBL_ROOTFS_ID: 3,
            MBL_APPS_ID: 3,
        },
    }

    def __init__(self, payload_format_version, tinfoil):
        """
        Construct a PayloadBuilder object.

        Args:
        * payload_format_version int: payload format version for which the
        * tinfoil Tinfoil: BitBake Tinfoil object.

        """
        self._tinfoil = tinfoil
        self._deploy_dir = pathlib.Path(
            tutil.get_bitbake_conf_var("DEPLOY_DIR_IMAGE", tinfoil)
        )
        if payload_format_version not in self._payload_format_specs:
            bb.fatal(
                'Unsupported payload format version "{}".'.format(
                    payload_format_version
                )
            )
        self._format_spec = self._payload_format_specs[payload_format_version]
        self._payload_format_version = payload_format_version

    def _create_versioned_class(self, name, *args, **kwargs):
        return vcr.create(name, self._format_spec[name], *args, **kwargs)

    def create_archiver(self):
        """Create a PayloadArchiver."""
        return self._create_versioned_class(
            MBL_PAYLOAD_ARCHIVER_ID, self._payload_format_version
        )

    def create_wks_bootloader_slot_image(self, slot_name):
        """Create a PayloadImage for a bootloader slot."""
        return self._create_versioned_class(
            slot_name, self._deploy_dir, self._tinfoil
        )

    def create_boot_image(self):
        """Create a PayloadImage for a boot/blfs partition."""
        return self._create_versioned_class(
            MBL_BOOT_ID, self._deploy_dir, self._tinfoil
        )

    def create_apps_image(self, apps):
        """Create a PayloadImage for a set of apps."""
        return self._create_versioned_class(MBL_APPS_ID, apps)

    def create_rootfs_image(self, image_name):
        """Create a PayloadImage for a rootfs."""
        return self._create_versioned_class(
            MBL_ROOTFS_ID, image_name, self._deploy_dir, self._tinfoil
        )
