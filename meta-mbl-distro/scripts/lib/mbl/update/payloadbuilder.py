# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""Provides an abstract factory for creating objects for building payloads."""

import abc
import pathlib

import mbl.update.appsimage as appsimage
import mbl.update.bootimage as bootimage
import mbl.update.payloadarchiver as payloadarchiver
import mbl.update.rootfsimage as rootfsimage
import mbl.update.wksbootloaderslotimage as wksbootloaderslotimage
import mbl.util.tinfoilutil as tutil


class PayloadBuilder(abc.ABC):
    """Abstract factory for creating objects used when buliding payloads."""

    def __init__(self, tinfoil):
        """
        Construct a PayloadBuilder object.

        This should only be called by subclasses and is a utility for saving
        data required when instantiating the objects that the factory provides.

        Args:
        * tinfoil Tinfoil: BitBake Tinfoil object.

        """
        self._tinfoil = tinfoil
        self._deploy_dir = pathlib.Path(
            tutil.get_bitbake_conf_var("DEPLOY_DIR_IMAGE", tinfoil)
        )

    @staticmethod
    def for_format_version(payload_format_version, tinfoil):
        """
        Create a PayloadBuilder object.

        The returned object is a factory that provides objects to create
        payloads of the given payload format version.

        Args:
        * payload_format_version int: payload format version for which the
          objects created by the factory should build.
        * tinfoil Tinfoil: BitBake Tinfoil object.

        """
        if payload_format_version == 1:
            return PayloadBuilderV1(tinfoil)
        elif payload_format_version == 3:
            return PayloadBuilderV3(tinfoil)
        else:
            bb.fatal(
                'Unsupported payload format version "{}"'.format(
                    payload_format_version
                )
            )

    @abc.abstractmethod
    def create_archiver(self):
        """Create a PayloadArchiver."""

    @abc.abstractmethod
    def create_wks_bootloader_slot_image(self, slot_name):
        """Create a PayloadImage for a bootloader slot."""

    @abc.abstractmethod
    def create_boot_image(self):
        """Create a PayloadImage for a boot/blfs partition."""

    @abc.abstractmethod
    def create_apps_image(self, apps):
        """Create a PayloadImage for a set of apps."""

    @abc.abstractmethod
    def create_rootfs_image(self, image_name):
        """Create a PayloadImage for a rootfs."""


class PayloadBuilderV3(PayloadBuilder):
    """Factory for creating objects used to build v3 payloads."""

    def __init__(self, tinfoil):
        """
        Construct a PayloadBuilderV3 object.

        Args:
        * tinfoil Tinfoil: BitBake Tinfoil object.

        """
        super().__init__(tinfoil)

    def create_archiver(self):
        """Implement method from PayloadBuilder ABC."""
        return payloadarchiver.SwupdateArchiver()

    def create_wks_bootloader_slot_image(self, slot_name):
        """Implement method from PayloadBuilder ABC."""
        return wksbootloaderslotimage.XzWksBootloaderSlotImage(
            slot_name, self._deploy_dir, self._tinfoil
        )

    def create_boot_image(self):
        """Implement method from PayloadBuilder ABC."""
        return bootimage.TarXzBootImage(self._deploy_dir, self._tinfoil)

    def create_apps_image(self, apps):
        """Implement method from PayloadBuilder ABC."""
        return appsimage.TarXzAppsImage(apps)

    def create_rootfs_image(self, image_name):
        """Implement method from PayloadBuilder ABC."""
        return rootfsimage.TarXzRootfsImage(
            image_format_version=3,
            archived_path=pathlib.Path("ROOTFSv3.tar.xz"),
            image_name=image_name,
            deploy_dir=self._deploy_dir,
            tinfoil=self._tinfoil,
        )


class PayloadBuilderV1(PayloadBuilder):
    """Factory for creating objects used to build v1 payloads."""

    def __init__(self, tinfoil):
        """
        Construct a PayloadBuilderV1 object.

        Args:
        * tinfoil Tinfoil: BitBake Tinfoil object.

        """
        super().__init__(tinfoil)

    def create_archiver(self):
        """Implement method from PayloadBuilder ABC."""
        return payloadarchiver.TarWithVersionFileArchiver(
            payload_format_version=1
        )

    def create_wks_bootloader_slot_image(self, slot_name):
        """Implement method from PayloadBuilder ABC."""
        return wksbootloaderslotimage.TarXzWksBootloaderSlotImage(
            slot_name, self._deploy_dir, self._tinfoil
        )

    def create_boot_image(self):
        """Implement method from PayloadBuilder ABC."""
        return bootimage.TarXzWithBootSubdirBootImage(
            self._deploy_dir, self._tinfoil
        )

    def create_apps_image(self, apps):
        """Implement method from PayloadBuilder ABC."""
        return appsimage.IndividualIpksAppsImage(apps)

    def create_rootfs_image(self, image_name):
        """Implement method from PayloadBuilder ABC."""
        return rootfsimage.TarXzRootfsImage(
            image_format_version=1,
            archived_path=pathlib.Path("rootfs.tar.xz"),
            image_name=image_name,
            deploy_dir=self._deploy_dir,
            tinfoil=self._tinfoil,
        )
