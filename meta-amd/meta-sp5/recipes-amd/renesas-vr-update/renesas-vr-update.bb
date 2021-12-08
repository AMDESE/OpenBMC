SUMMARY = "Renesas VR update"
DESCRIPTION = "Renesas VR update application to update firmware"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

LICENSE = "CLOSED"
DEPENDS += "i2c-tools"

SRC_URI = "file://renesas-vr-update.h  \
           file://renesas-vr-update.c \
           file://renesas-vr-update.sh \
          "

S="${WORKDIR}"

INSANE_SKIP_${PN} += "ldflags"
RDEPENDS_${PN} += "bash"

do_compile() {
    ${CC} -li2c renesas-vr-update.c -o renesas-vr-update
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 renesas-vr-update ${D}${bindir}
    install -m 0755 ${S}/renesas-vr-update.sh ${D}${bindir}
}
