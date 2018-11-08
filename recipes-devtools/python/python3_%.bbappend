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

# Add the missing venv module to pyvenv to allow creation of virtual environments.
#
# The inclusion of the venv module is done via the python3-pyvenv package
# because there is currently no self-contained venv package.
# As ensurepip is not available, virtual envs have to be created without pip
# so the creation of virtual environments can complete sucessfully.
#
# Install python3-pip on the system to make it accessible to virtual environments.
#
# Create virtual environments as follows:
# e.g $ python3 -m venv my_venv --without-pip --system-site-packages
# After activating the virtual environment ($ source my_venv/bin/activate);
# pip is accessed using:
# e.g (my_venv)$ python3 -m pip --version OR
#     (my_venv)$ pip3 --version
FILES_${PN}-pyvenv += "${libdir}/python${PYTHON_MAJMIN}/venv"

# Create the python3-ntpath package as the ntpath module is a dependency of
# Pytest. The module is not normally included in python3-core and the
# file cannot simply be appended to it because the python3-core package is
# generated dynamically at build time by a script thus overwritting whatever
# modification done in this bbappend file.
# There is not much point upstreaming a fix because python3-pytest is a package
# provided by OE and it has all required dependencies.
# The below is only necessary because Pytest is installed on a system running
# MBL OS only for the purpose of running system tests. Thus Pytest expect all
# dependencies to be present on the OS image already.
# It appears that the dependency on ntpath for Pytest has been resolved in
# Python 3.6 (and later versions). This python3-npath package can be removed
# when MBL is upgraded from Python 3.5.
PACKAGES =+ "${PN}-ntpath"
FILES_${PN}-ntpath += "${libdir}/python${PYTHON_MAJMIN}/ntpath.py"
