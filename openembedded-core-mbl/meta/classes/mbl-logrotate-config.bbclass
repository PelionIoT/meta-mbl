# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Introduction
# ------------
# The mbl-logrotate-config bbclass provides a mechanism to create logrotate
# config files for recipes.
#
# The values of the logrotate config fields are given in variables, and are
# used to write a config file to /etc/logrotate.d. The variables used are:
#
# * MBL_LOGROTATE_CONFIG_LOG_NAMES: a whitespace delimited list of log names
#   for which to write config files. These names are used as filenames under
#   /etc/logrotate.d.
#
# * MBL_LOGROTATE_CONFIG_LOG_PATH[log_name]: the path to the log (on the target
#   device) .
#
# * MBL_LOGROTATE_CONFIG_ROTATE[log_name]: the number of times to "rotate" the
#   log (see logrotate documentation for "rotate").
#
# * MBL_LOGROTATE_CONFIG_SIZE[log_name]: the minimum size a log must be before
#   it is rotated (see logrotate documentation for "size").
#
# * MBL_LOGROTATE_CONFIG_NOARG_OPTS[log_name]: for options with no arguments,
#   for example "missingok", "compress", "copytruncate" etc.
#
# * MBL_LOGROTATE_CONFIG_POSTROTATE[log_name]: a semicolon delimited list of
#   commands to run after a log file has been rotated (see logrotate
#   documentation for "postrotate")
#
# If a recipe only specifies a single log name in
# MBL_LOGROTATE_CONFIG_LOG_NAMES or the same value is appropriate for all log
# names then the [log_name] variable flag specifier for a variable can be
# omitted.
#
# Support for more logrotate config fields can be added in
# mbl_logrotate_config_get_fields() below.
#
# This class adds a new package, ${PN}-logrotate-config, to the recipe that
# inherits it. ${PN} will RDEPEND on the ${PN}-logrotate-config and
# ${PN}-logrotate-config will RDEPEND on logrotate.
#
# Example (from mbl-cloud-client.bb)
# ----------------------------------
#
# MBL_LOGROTATE_CONFIG_LOG_NAMES = "mbl-cloud-client"
# MBL_LOGROTATE_CONFIG_LOG_PATH[mbl-cloud-client] = "/var/log/mbl-cloud-client.log"
# MBL_LOGROTATE_CONFIG_SIZE[mbl-cloud-client] ?= "2M"
# MBL_LOGROTATE_CONFIG_ROTATE[mbl-cloud-client] ?= "5"
# MBL_LOGROTATE_CONFIG_POSTROTATE[mbl-cloud-client] = "/usr/bin/killall -HUP mbl-cloud-client"
# MBL_LOGROTATE_CONFIG_NOARG_OPTS[mbl-cloud-client] = "missingok"
# inherit mbl-logrotate-config
#

PACKAGES =+ "${PN}-logrotate-config"
RDEPENDS_${PN} += "${PN}-logrotate-config"
RDEPENDS_${PN}-logrotate-config += "logrotate"

python() {
    # Add logrotate config files to FILES_${PN}-logrotate-config

    log_names = mbl_logrotate_config_get_var(d, "LOG_NAMES").split()
    config_paths = [mbl_logrotate_config_get_path(d, log_name) for log_name in log_names]
    files_append_str = " {}".format(" ".join(config_paths))

    pn = d.getVar("PN")
    d.appendVar("FILES_{}-logrotate-config".format(pn), files_append_str)
}


def mbl_logrotate_config_get_dir(d):
    """
    Get the directory where logrotate config files live
    """

    return "{}/logrotate.d".format(d.getVar("sysconfdir", True))


def mbl_logrotate_config_get_path(d, log_name):
    """
    Get the path to the logrotate config file for the log with the given name
    """

    return "{}/{}.conf".format(mbl_logrotate_config_get_dir(d), log_name)


def mbl_logrotate_config_get_var(d, var_name, log_name = None, mandatory = True, pattern = None):
    """
    Get the value of an MBL_LOGROTATE_CONFIG variable

    If log_name is given and the variable has a flag for the log name then the
    value of that flag is returned, otherwise the normal variable value is
    returned.

    If mandatory is True then an error is raised if a value cannot be obtained.

    If pattern is given and the obtained value doesn't match the given pattern
    then an error is raised.
    """

    import re

    full_var_name = "MBL_LOGROTATE_CONFIG_{}".format(var_name)

    value = None
    if log_name:
        value = d.getVarFlag(full_var_name, log_name, True)

    if not value:
        value = d.getVar(full_var_name, True)

    if mandatory and not value:
        bb.fatal("ERROR: {} value for log {} is unset".format(full_var_name, log_name))

    if value and pattern and not re.match(pattern, value):
        bb.fatal("ERROR: {} value for log {} is invalid".format(full_var_name, log_name))

    return value


def mbl_logrotate_config_get_fields(d, log_name):
    """
    Get fields to write to logrotate config file

    Returns a tuple (normal_fields, script_fields) where each element is a
    dictionary that maps field names to values.

    The values in the normal_fields dictionary are just strings.

    The values in the script_fields dictionary are lists of strings (commands).
    """

    normal_fields = {}
    script_fields = {}

    normal_fields["rotate"] = mbl_logrotate_config_get_var(
        d, "ROTATE", log_name=log_name, pattern=r'^\d+$'
    ).strip()

    normal_fields["size"] = mbl_logrotate_config_get_var(
        d, "SIZE", log_name=log_name, pattern=r'^\d+[kMG]$'
    ).strip()


    noarg_opt = mbl_logrotate_config_get_var(
        d, "NOARG_OPTS", log_name=log_name, mandatory=False
    )
    if noarg_opt:
        normal_fields["noarg_opt"] = str(noarg_opt).strip().split(' ')

    postrotate = mbl_logrotate_config_get_var(
        d, "POSTROTATE", log_name=log_name, mandatory=False
    )
    if postrotate:
        script_fields["postrotate"] = postrotate.strip().split(";")

    return (normal_fields, script_fields)


def mbl_logrotate_config_write(d, log_name):
    """
    Install a logrotate config file for the log with the given name
    """

    import os
    import stat

    log_path = mbl_logrotate_config_get_var(d, "LOG_PATH", log_name=log_name)
    normal_fields, script_fields = mbl_logrotate_config_get_fields(d, log_name)

    dest_path = d.getVar("D", True)
    sysconf_path = d.getVar("sysconfdir", True)
    config_path = "{}{}".format(dest_path, mbl_logrotate_config_get_path(d, log_name))
    indent = " "*4

    with open(config_path, mode="w") as file:
        file.write(log_path)
        file.write(" {\n")

        for key, value in normal_fields.items():
            if key == 'noarg_opt':
                for noarg_opt in value:
                    file.write("{}{}\n".format(indent, noarg_opt))
            else:
                file.write("{}{} {}\n".format(indent, key, value))

        for key, value in script_fields.items():
            file.write("{}{}\n".format(indent, key))
            for cmd in value:
                file.write("{}{}\n".format(indent*2, cmd))
            file.write("{}endscript\n".format(indent))

        file.write("}\n")

    # user:rw, group:r, other:r
    os.chmod(config_path, stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IROTH)
    # user = root, group = root
    os.chown(config_path, 0, 0)

# We're writing to ${D} here so must use fakeroot to get the owners and groups
# of the config files correct
#
# Add a new task rather than using e.g. do_install_append() because I can't
# append Python code to a do_install() implemented in Shell.
fakeroot python do_write_logrotate_configs() {
    import os

    config_dir = "{}{}".format(d.getVar("D"), mbl_logrotate_config_get_dir(d))
    if not os.path.exists(config_dir):
        os.makedirs(config_dir)

    log_names = mbl_logrotate_config_get_var(d, "LOG_NAMES").split()
    for log_name in log_names:
        mbl_logrotate_config_write(d, log_name)
}
addtask write_logrotate_configs after do_install do_deploy before do_package do_populate_sysroot
