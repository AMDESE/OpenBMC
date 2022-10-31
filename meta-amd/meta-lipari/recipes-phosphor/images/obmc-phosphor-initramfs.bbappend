FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

DEPENDS += "kernel-module-liparigpio"
PACKAGE_INSTALL += "kernel-module-liparigpio"

RDEPENDS_${PN} += "e2fsprogs-mke2fs"
IMAGE_INSTALL_append = " e2fsprogs-mke2fs"
