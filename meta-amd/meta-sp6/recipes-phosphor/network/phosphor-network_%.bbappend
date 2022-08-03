FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
 
SRC_URI += "file://0001-phosphor-network-Add-LCD-write-for-BMC-IP.patch \
            "
DEPENDS += "amd-lcd-lib"

TARGET_LDFLAGS += " -llcdlib32"

S = "${WORKDIR}/git"
