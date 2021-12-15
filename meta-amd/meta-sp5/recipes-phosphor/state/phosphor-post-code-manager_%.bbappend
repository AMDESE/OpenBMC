FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-phosphor-post-code-manager-Add-LCD-write-POST-CODE.patch \
           "

DEPENDS += "amd-lcd-lib"

TARGET_LDFLAGS = " -llcdlib32"

S = "${WORKDIR}/git"
