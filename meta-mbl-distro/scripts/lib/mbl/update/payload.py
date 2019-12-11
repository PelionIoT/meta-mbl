# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""Module for creating update payloads."""

import logging
import pathlib
import subprocess
import tempfile

import mbl.update.payloadbuilder as payloadbuilder
import mbl.update.testinfo as testinfo
import mbl.util.tinfoilutil as tutil

CURRENT_PAYLOAD_FORMAT_VERSION = 4


class UpdatePayload:
    """Class for creating update payloads and metadata."""

    def __init__(
        self,
        payload_format_version,
        tinfoil,
        bootloader_components=None,
        kernel=False,
        rootfs=False,
        apps=None,
    ):
        """
        Create an UpdatePayload object.

        Args:
        * payload_format_version int: version of payload format to use.
        * tinfoil Tinfoil: BitBake Tinfoil object.
        * bootloader_components list<str>: names of bootloader components to
          add to the payload. I.e. a sublist of ["1", "2"].
        * kernel bool: True if the kernel component should be added to the
          payload.
        * rootfs bool: True if the rootfs component should be added to the
          payload.
        * apps list<str|Path>: list of apps (ipk files) to add to the payload.

        """
        if bootloader_components is None:
            bootloader_components = []
        if apps is None:
            apps = []

        self.builder = payloadbuilder.PayloadBuilder(
            payload_format_version, tinfoil
        )
        self.images = []
        if bootloader_components:
            bootloader_components_copy = bootloader_components.copy()
            if _bootloader_one_with_kernel(bootloader_components, tinfoil):
                if not kernel:
                    logging.warning(
                        "On this target the bootloader 1 component and kernel "
                        "must be updated together. "
                        "Adding kernel to payload..."
                    )
                    self.images.append(self.builder.create_boot_image())

                bootloader_components_copy.remove("1")

            for bootloader_slot_number in bootloader_components_copy:
                slot_name = "WKS_BOOTLOADER{}".format(bootloader_slot_number)
                self.images.append(
                    self.builder.create_wks_bootloader_slot_image(slot_name)
                )

        if kernel:
            if _kernel_with_bootloader_one(bootloader_components, tinfoil):
                if "1" not in bootloader_components:
                    bb.warn(
                        "On this target the bootloader 1 component and kernel "
                        "must be updated together. "
                        "Adding bootloader 1 component to payload..."
                    )
            self.images.append(self.builder.create_boot_image())

        if apps:
            self.images.append(self.builder.create_apps_image(apps))

        if rootfs:
            self.images.append(self.builder.create_rootfs_image(rootfs))

    def create_payload_file(self, output_path):
        """
        Create an update payload.

        Args:
        * output_path Path: path where we output the payload.

        """
        self.builder.create_archiver().create_payload_file(
            self.images, output_path
        )

    def create_testinfo_file(self, output_path):
        """
        Create a "testinfo" file for the update payload.

        Args:
        * output_path Path: path where we output the testinfo file.

        """
        testinfo.create_testinfo_file(self.images, output_path)


def _is_part_skipped(part_name, tinfoil):
    return (
        tutil.get_bitbake_conf_var(
            "MBL_{}_SKIP".format(part_name), tinfoil, missing_ok=True
        )
        == "1"
    )


def _bootloader_one_with_kernel(bootloader_components, tinfoil):
    return (
        _is_part_skipped("WKS_BOOTLOADER1", tinfoil)
        and "1" in bootloader_components
    )


def _kernel_with_bootloader_one(bootloader_components, tinfoil):
    return _is_part_skipped("WKS_BOOTLOADER1", tinfoil)
