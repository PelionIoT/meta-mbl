# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""Provides an abstract factory for creating objects for building payloads."""

import abc
import pathlib

import mbl.update.appsimage as ai
import mbl.update.bootimage as bi
import mbl.update.payloadarchiver as pa
import mbl.update.rootfsimage as ri
import mbl.update.wksbootloaderslotimage as wi
import mbl.util.tinfoilutil as tutil


class PayloadBuilder:
    """Factory for objects used to build payloads."""

    _payload_format_specs = {
        1: {
            pa.MBL_PAYLOAD_ARCHIVER_ID: pa.PayloadArchiverV1,
            wi.MBL_WKS_BOOTLOADER1_ID: wi.WksBootloader1ImageV1,
            wi.MBL_WKS_BOOTLOADER2_ID: wi.WksBootloader2ImageV1,
            bi.MBL_BOOT_ID: bi.BootImageV1,
            ri.MBL_ROOTFS_ID: ri.RootfsImageV1,
            ai.MBL_APPS_ID: ai.AppsImageV1,
        },
        3: {
            pa.MBL_PAYLOAD_ARCHIVER_ID: pa.PayloadArchiverV3,
            wi.MBL_WKS_BOOTLOADER1_ID: wi.WksBootloader1ImageV3,
            wi.MBL_WKS_BOOTLOADER2_ID: wi.WksBootloader2ImageV3,
            bi.MBL_BOOT_ID: bi.BootImageV3,
            ri.MBL_ROOTFS_ID: ri.RootfsImageV3,
            ai.MBL_APPS_ID: ai.AppsImageV3,
        },
        4: {
            pa.MBL_PAYLOAD_ARCHIVER_ID: pa.PayloadArchiverV3,
            wi.MBL_WKS_BOOTLOADER1_ID: wi.WksBootloader1ImageV3,
            wi.MBL_WKS_BOOTLOADER2_ID: wi.WksBootloader2ImageV3,
            bi.MBL_BOOT_ID: bi.BootImageV3,
            ri.MBL_ROOTFS_ID: ri.RootfsImageV4,
            ai.MBL_APPS_ID: ai.AppsImageV3,
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
        return self._format_spec[name](*args, **kwargs)

    def create_archiver(self):
        """Create a PayloadArchiver."""
        return self._create_versioned_class(
            pa.MBL_PAYLOAD_ARCHIVER_ID, self._payload_format_version
        )

    def create_wks_bootloader_slot_image(self, slot_name):
        """Create a PayloadImage for a bootloader slot."""
        return self._create_versioned_class(
            slot_name, self._deploy_dir, self._tinfoil
        )

    def create_boot_image(self):
        """Create a PayloadImage for a boot/blfs partition."""
        return self._create_versioned_class(
            bi.MBL_BOOT_ID, self._deploy_dir, self._tinfoil
        )

    def create_apps_image(self, apps):
        """Create a PayloadImage for a set of apps."""
        return self._create_versioned_class(ai.MBL_APPS_ID, apps)

    def create_rootfs_image(self, image_name):
        """Create a PayloadImage for a rootfs."""
        return self._create_versioned_class(
            ri.MBL_ROOTFS_ID, image_name, self._deploy_dir, self._tinfoil
        )
