#!/bin/sh
source __REPLACE_ME_WITH_MBL_APP_DIR__/__REPLACE_ME_WITH_libdir__/set-up-test-env.sh
exec virtualenv "$@"
