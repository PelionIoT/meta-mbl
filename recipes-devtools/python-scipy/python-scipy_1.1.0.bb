# Descriptive Meta-data
SUMMARY = "Python library for mathematics, science, and engineering"
DESCRIPTION = "SciPy (pronounced “Sigh Pie”) is open-source software for
mathematics, science, and engineering. The SciPy library depends on NumPy,
which provides convenient and fast N-dimensional array manipulation. The SciPy
library is built to work with NumPy arrays, and provides many user-friendly and
efficient numerical routines such as routines for numerical integration and
optimization. Together, they run on all popular operating systems, are quick to
install, and are free of charge. NumPy and SciPy are easy to use, but powerful
enough to be depended upon by some of the world’s leading scientists and
engineers. If you need to manipulate numbers on a computer and display or
publish the results, give SciPy a try!"
AUTHOR = "SciPy developers <https://www.scipy.org/>"
HOMEPAGE = "https://www.scipy.org/index.html"

# Package Manager Meta-data
SECTION = "devel/python"
PRIORITY = "optional"

# Licensing Meta-data
LICENSE = " Apache-2.0 & BSD & BSD-2-Clause & BSD-3-Clause & MIT & PSF & Qhull"
LIC_FILES_CHECKSUM = "file://LICENSE.txt;md5=be4a7946a904c1b639bcfe4da4f795b8"

# Inheritance Directives
inherit distutils pypi setuptools

# Build Meta-data
DEPENDS_append = " ${PYTHON_PN}-numpy"
SRCNAME = "scipy"
SRC_URI = "https://github.com/${SRCNAME}/${SRCNAME}/releases/download/v${PV}/${SRCNAME}-${PV}.tar.gz"
SRC_URI[md5sum] = "aa6bcc85276b6f25e17bcfc4dede8718"
SRC_URI[sha256sum] = "878352408424dffaa695ffedf2f9f92844e116686923ed9aa8626fc30d32cfd1"

# Runtime Meta-data
RDEPENDS_${PN} += "${PYTHON_PN}-core \
                   ${PYTHON_PN}-distutils \
                   ${PYTHON_PN}-numpy \
                   ${PYTHON_PN}-setuptools \
"
