SUMMARY = "Infineon VR Update app"
DESCRIPTION = "Used for performing VR updates through BMC"

FILESEXTRAPATHS_prepend := "${THISDIR}:"

LICENSE = "CLOSED"

DEPENDS += "i2c-tools"

SRC_URI = "file://common.h \
           file://main.cpp \
           file://infineon-vr-update.h \
           file://infineon-vr-update.cpp \
           file://infineon-vr-update.sh \
           file://renesas-vr-update.h  \
           file://renesas-vr-update.cpp \
           file://renesas-vr-update.sh \
          "

S = "${WORKDIR}"

INSANE_SKIP_${PN} += "ldflags"
RDEPENDS_${PN} += "bash"

do_compile() {
    ${CXX} -li2c main.cpp infineon-vr-update.cpp renesas-vr-update.cpp -o vr-update
}

do_install() {
        install -d ${D}${bindir}
        install -m 0755 infineon-vr-update.sh ${D}${bindir}
        install -m 0755 vr-update ${D}${bindir}
        install -m 0755 ${S}/renesas-vr-update.sh ${D}${bindir}

}
