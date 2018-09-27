#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0

"""App manager library."""

import subprocess
import os
import logging
import shutil

__version__ = "1.0.2"


class AppManager(object):
    """App manager class."""

    def __init__(self):
        """Initialize AppManager class."""
        self.logger = logging.getLogger("AppManager")
        self.logger.info("Creating AppManager version {}".format(__version__))
        self.package_info_dic = {}
        self.root_install_dir = "/home/app/"
        # When opkg installs new package while "D" environment variable
        # is defined, opkg will not call ldconfig in rootfs partition
        self.opkg_env = os.environ.copy()
        self.opkg_env["D"] = "1"

    def get_package_dest_dir(self, package_path):
        """
        Return the destination directory name.

        :param package_path: Package path
        :return: Package destination directory
        """
        # Build dictionary from package info
        self._parse_package_info(package_path)
        package_dest_dir = self.package_info_dic["Package"]
        self.logger.info("Destination directory: {}".format(package_dest_dir))
        return package_dest_dir

    def install_package(self, package_path):
        """
        Install package using opkg.

        :param package_path: Package path
        :return: None
        """
        # Command syntax:
        # opkg --add-dest <package_name>:/home/app/<package_name>
        #      install <package_path>
        package_dest_dir = self.get_package_dest_dir(package_path)
        assert (
            package_dest_dir is not None
        ), "Error selecting destination directory"

        add_dest_path = "{0}:{1}{2}".format(
            package_dest_dir, self.root_install_dir, package_dest_dir
        )
        command = [
            "opkg",
            "--add-dest",
            add_dest_path,
            "install",
            package_path,
        ]
        self._run_opkg(command)
        self.logger.info("Install package: {} succeeded.".format(package_path))

    def remove_package(self, package_name):
        """
        Remove package from device using opkg.

        :param package_name: Package name
        :return: None
        """
        # Command syntax:
        # opkg --add-dest <package_name>:/home/app/<package_name>
        #      remove <package_name>
        dest_dir = "{0}{1}".format(self.root_install_dir, package_name)
        if os.path.isdir(dest_dir):
            package_dest_dir = "{0}:{1}".format(package_name, dest_dir)
            command = [
                "opkg",
                "--add-dest",
                package_dest_dir,
                "remove",
                package_name,
            ]
            self._run_opkg(command)
            self.logger.info(
                "Remove package: {} succeeded.".format(package_name)
            )
            shutil.rmtree(dest_dir)
        else:
            self.logger.error(
                "Remove package: {} failed!".format(package_name)
            )

    def force_install_package(self, package_path):
        """
        Force-install package using opkg.

        :param package_path: Package path to install
        :return: None
        """
        # Obtain package name
        package_name = self.get_package_dest_dir(package_path)
        assert package_name is not None, "Error obtaining package name"

        # If was previously installed, remove first
        if os.path.isdir(os.path.join(self.root_install_dir, package_name)):
            self.remove_package(package_name)

        # Finally, install
        self.install_package(package_path)

    def list_installed_packages(self):
        """
        Print installed packages using opkg.

        :return: None
        """
        # Command syntax:
        # opkg --add-dest <package_name>:/home/app/<package_name>
        #      list-installed
        self.logger.info("Installed packages:")
        subdirectories = os.listdir(self.root_install_dir)
        for sub_directory in subdirectories:
            # dir is actually package name as we install packages into
            # a directory with their name
            package_pull_path = os.path.join(
                self.root_install_dir, sub_directory
            )
            if os.path.isdir(package_pull_path):
                package_dest_dir = "{0}:{1}".format(
                    sub_directory, package_pull_path
                )
                command = [
                    "opkg",
                    "--add-dest",
                    package_dest_dir,
                    "list-installed",
                ]
                self._run_opkg(command, False)

    def _parse_package_info(self, package_path):
        """
        Parse package info and fill it into a dictionary.

        :param package_path: Package path
        :return: None
        """
        # Read package info using opkg:
        command = ["opkg", "info", package_path]
        package_info = subprocess.check_output(
            command, env=self.opkg_env
        ).decode("utf-8")
        self.logger.info("Package info:\n {}".format(package_info))

        # All package info fields includes "\n" only once, while description
        # might have several. Since we use the new line as separator in the
        # split operation, we want to get rid off the newline in this field.
        # Assuming description field always come last in package info and
        # afterwards two "\n".
        start = package_info.find("Description: ")
        end = package_info.find("\n\n")
        description_with_newline = package_info[start:end]
        description_no_newline = description_with_newline.replace("\n", "")
        package_info = package_info.replace(
            description_with_newline, description_no_newline
        )

        # pair_list will hold pair strings that will later be used for
        # dictionary key and value
        pair_list = list(package_info.split("\n"))
        # list_for_dictionary holds strings, 1'st string will be used as key,
        # 2'nd as its value, third: key and so on
        list_for_dictionary = list()

        for pair in pair_list:
            if pair:
                split = pair.split(": ")
                list_for_dictionary += split

        # Fill dictionary to look something like:
        # [Package][Package name]
        # [Description][Package description...]
        # [Architecture][...]
        #  and so on.
        for i in range(0, len(list_for_dictionary), 2):
            self.package_info_dic[
                list_for_dictionary[i]
            ] = list_for_dictionary[i + 1]

    def _run_opkg(self, command, print_command=True):
        """
        Execute opkg with input command.

        :param command: Command
        :param print_command: If true - prints input command. Even in verbose
               mode we still want to control these prints as we don't want it
               during list-installed-packages
        :return: None
        """
        if print_command:
            self.logger.debug(
                "Executing opkg command: {}".format(" ".join(command))
            )
        subprocess.check_call(command, env=self.opkg_env)
