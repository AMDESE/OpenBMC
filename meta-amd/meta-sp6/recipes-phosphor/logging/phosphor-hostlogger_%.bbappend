FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://0001-start-logger-on-different-uart-based-on-board-id.patch"
SRC_URI += "file://ttyVUART0.conf"
