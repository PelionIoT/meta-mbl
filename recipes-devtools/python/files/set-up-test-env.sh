# The next environment variables are overridden locally while running pip3/python3/virtualenv.
# This is done in order to minimize the conflicts (shared object loading and binary execute conflicts) and mistakes done while working on targets 
#  with an existing Python installation on root.
# The libc6 libraries are still loaded from the root folders ,and are shared between the installations.

export PATH=__REPLACE_ME_WITH_MBL_APP_DIR__/__REPLACE_ME_WITH_OE_USR_BIN_DIR__
export LD_LIBRARY_PATH=__REPLACE_ME_WITH_MBL_APP_DIR__/__REPLACE_ME_WITH_OE_USR_LIB_DIR__
export PYTEST_ADDOPTS="__REPLACE_ME_WITH_MBL_APP_DIR__/__REPLACE_ME_WITH_OE_USR_BIN_DIR__"

