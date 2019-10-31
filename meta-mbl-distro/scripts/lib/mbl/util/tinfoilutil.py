# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""Utility functions for using BitBake Tinfoil."""


def get_bitbake_conf_var(var_name, tinfoil, missing_ok=False):
    """
    Get the value of a BitBake variable.

    If missing_ok is False then an error is raised if the variable does not
    exist.
    If missing_ok is True then None is returned if the variable does not exist.
    """
    val = tinfoil.config_data.getVar(var_name)
    if val is not None:
        return val.strip()
    if missing_ok:
        return None
    bb.fatal(
        'The "{}" BitBake variable is not set. Please check that you have set '
        "up a valid BitBake environment.".format(var_name)
    )
