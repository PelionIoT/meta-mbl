# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""
Registry for keeping track of classes that represent versions of things.

Each thing has a name and classes that represent different versions of that
thing are identified by that name and an integer version.
"""

_registry = {}


def register_versioned_class(name, version, cls):
    """
    Register a class as representing a version of a thing.

    Args:
    * name str: name of the thing that cls represents.
    * version int: version of the thing that cls represents.
    * cls class: class that represents the thing.
    """
    if name not in _registry:
        _registry[name] = {}

    assert version not in _registry[name]
    _registry[name][version] = cls


def get_versioned_class(name, version):
    """
    Get a class that represents a version of a thing.

    Args:
    * name str: name of the thing.
    * version int: version of the thing.
    """
    assert name in _registry
    assert version in _registry[name]
    return _registry[name][version]


def create(name, version, *args, **kwargs):
    """
    Create a thing of a given version.

    Args:
    * name str: name of the thing to create.
    * version int: version of the thing to create.
    * *args/**kwargs: args to pass to the thing's __init__ method.
    """
    return get_versioned_class(name, version)(*args, **kwargs)
