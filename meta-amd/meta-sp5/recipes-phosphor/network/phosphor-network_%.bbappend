FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-meta-sp5-Modify-phosphor-network-to-set-host-name.patch \
           "

S = "${WORKDIR}/git"
