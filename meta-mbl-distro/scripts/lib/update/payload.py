# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

import logging
import pathlib
import subprocess
import tempfile

from update.util import get_bitbake_conf_var
import update.images as images
import update.swdesc as swdesc
import update.testinfo as testinfo

class UpdatePayload:
    def __init__(
        self,
        tinfoil,
        bootloader_components=[],
        kernel=False,
        rootfs=False,
        apps=[],
    ):
        deploy_dir = pathlib.Path(
            get_bitbake_conf_var("DEPLOY_DIR_IMAGE", tinfoil)
        )
        self.images = []
        if bootloader_components:
            bootloader_components_copy = bootloader_components.copy()
            if self._bootloader_one_with_kernel(
                bootloader_components, tinfoil
            ):
                if not kernel:
                    logging.warning(
                        "On this target the bootloader 1 component and kernel must"
                        " be updated together. Adding kernel to payload..."
                    )
                    images.append(images.BootImage(deploy_dir, tinfoil))

                bootloader_components_copy.remove("1")

            for bootloader_slot_number in bootloader_components_copy:
                slot_name = "WKS_BOOTLOADER{}".format(bootloader_slot_number)
                self.images.append(
                    images.WksBootloaderSlotImage(
                        slot_name, deploy_dir, tinfoil
                    )
                )

        if kernel:
            if self._kernel_with_bootloader_one(
                bootloader_components, tinfoil
            ):
                if "1" not in bootloader_components:
                    bb.warn(
                        "On this target the bootloader 1 component and kernel must"
                        " be updated together. Adding bootloader 1 component to "
                        "payload..."
                    )
            self.images.append(images.BootImage(deploy_dir, tinfoil))

        if apps is not None:
            self.images.append(images.AppsImage(apps))

        if rootfs is not None:
            self.images.append(images.RootfsImage(rootfs, deploy_dir, tinfoil))

    def create_payload_file(self, output_path):
        """
        Create an update payload.

        :param output_path Path: path where we output the payload.
        """
        with tempfile.TemporaryDirectory() as staging_dir:
            staging_dir_path = pathlib.Path(staging_dir)
            swdesc_name = "sw-description"
            swdesc.create_swdesc_file(
                self.images, staging_dir_path / swdesc_name
            )
            # swupdate requires that the  sw-description file is first in the
            # payload
            self._append_to_payload(
                staging_dir_path, swdesc_name, output_path, create=True
            )
            for image in self.images:
                image.stage(staging_dir_path)
                self._append_to_payload(
                    staging_dir_path, image.archived_path, output_path
                )

    def create_testinfo_file(self, output_path):
        """
        Create a "testinfo" file, containing information about how to test the
        update payload.
        """
        testinfo.create_testinfo_file(self.images, output_path)

    @staticmethod
    def _is_part_skipped(part_name, tinfoil):
        return (
            get_bitbake_conf_var(
                "MBL_{}_SKIP".format(part_name), tinfoil, missing_ok=True
            )
            == "1"
        )

    @staticmethod
    def _bootloader_one_with_kernel(bootloader_components, tinfoil):
        return (
            UpdatePayload._is_part_skipped("WKS_BOOTLOADER1", tinfoil)
            and "1" in bootloader_components
        )

    @staticmethod
    def _kernel_with_bootloader_one(bootloader_components, tinfoil):
        return UpdatePayload._is_part_skipped("WKS_BOOTLOADER1", tinfoil)

    @staticmethod
    def _append_to_payload(
        staging_dir, archived_path, output_path, create=False
    ):
        cpio_args = [
            "cpio",
            "--format",
            "crc",
            "--quiet",
            "-o",
            "-F",
            str(output_path),
        ]
        if not create:
            cpio_args.append("--append")

        subprocess.check_output(
            cpio_args,
            input=bytes(str(archived_path), "utf-8"),
            cwd=staging_dir,
        )
