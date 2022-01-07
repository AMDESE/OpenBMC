FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-phosphor-post-code-manager-Add-LCD-write-POST-CODE.patch \
            file://0002-phosphor-post-code-manager-Del-POST-Index-from-LCD.patch \
           "

DEPENDS += "amd-lcd-lib"

TARGET_LDFLAGS = " -llcdlib32"

S = "${WORKDIR}/git"
