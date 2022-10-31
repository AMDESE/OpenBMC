RDEPENDS_${PN} += "${VIRTUAL-RUNTIME_base-utils} \
                          e2fsprogs-mke2fs"

IMAGE_INSTALL_append = " e2fsprogs-mke2fs"
