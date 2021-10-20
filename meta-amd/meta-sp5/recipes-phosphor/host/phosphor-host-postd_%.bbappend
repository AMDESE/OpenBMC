FILESEXTRAPATHS_prepend := "${THISDIR}/phosphor-host-postd:"

S = "${WORKDIR}/git"

SNOOP_DEVICE = "aspeed-lpc-pcc"
POST_CODE_BYTES = "8"

SRC_URI += "file://0001-espi-post-code-capture-handler.patch"

