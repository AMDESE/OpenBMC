SUMMARY = "Infineon VR Update app"
DESCRIPTION = "Used for performing VR updates through BMC"

FILESEXTRAPATHS_prepend := "${THISDIR}:"

LICENSE = "CLOSED"

DEPENDS += "i2c-tools"

SRC_URI = "file://infineon-vr-update.h \
           file://infineon-vr-update.cpp \
          "

S = "${WORKDIR}"
INSANE_SKIP_${PN} += "ldflags"

do_compile() {
    ${CXX} infineon-vr-update.cpp -li2c -o infineon-vr-update
}

do_install() {
        install -d ${D}${bindir}
        install -m 0755 infineon-vr-update ${D}${bindir}
}
