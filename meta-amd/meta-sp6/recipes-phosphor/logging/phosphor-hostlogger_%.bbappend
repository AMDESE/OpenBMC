FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# Default service instance to install (single-host mode)
DEFAULT_INSTANCE = "ttyS0"

SRC_URI_remove = "file://${BPN}.conf"
SRC_URI += "file://ttyS0.conf \
            file://0001-start-logger-on-different-uart-based-on-board-id.patch \
            "
SRC_URI += "file://ttyVUART0.conf"
