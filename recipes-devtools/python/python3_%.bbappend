# python3 doesn't really depend on gdbm - it can use alternative database
# managers like Berkely DB
DEPENDS_remove = "gdbm"

# Now that we've removed gdbm as a dependency we need to add a way to configure
# python3 to actually use gdbm or an alternative DB manager.
#
# python3's configure script automatically finds libraries for optional
# modules, so to "configure" python3 to use gdbm or db (Berkely DB) we could
# just add them to the recipe's DEPENDS so that the configure script will find
# them.  That's not an ideal approach though because it doesn't guarantee that
# the configure script will ignore libraries that we don't want it to use.  The
# configure script also accepts a "--with-dbmliborder=" argument that we can
# use, but OE's default PACKAGECONFIG mechanism doesn't support creating
# configure arguments based on multiple PACKAGECONFIG values so we'll have to
# do some work ourselves.

# Just use OE's mechanism to pull in the right dependencies
PACKAGECONFIG[gdbm] = ",,gdbm"
PACKAGECONFIG[bdb] = ",,db"

# Build the "--with-dbmliborder" argument manually
python() {
    configs = d.getVar('PACKAGECONFIG').split()

    # --with-dbmliborder expects a colon delimited list of database manager
    # library names, e.g. "bdb", "gdbm" or "gdbm:bdb". The order is significant
    # so preserve the order that the items appear in PACKAGECONFIG.
    dbm_libs = [config for config in configs if config in ["gdbm", "bdb"]]
    d.setVar('PYTHON3_DBM_LIBS', ":".join(dbm_libs))
}

EXTRA_OECONF += "--with-dbmliborder=${PYTHON3_DBM_LIBS}"
