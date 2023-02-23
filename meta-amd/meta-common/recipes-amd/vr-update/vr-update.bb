SUMMARY = "VR Update application"
DESCRIPTION = "Used for performing VR updates through BMC"

FILESEXTRAPATHS_prepend := "${THISDIR}:"

LICENSE = "CLOSED"

inherit cmake pkgconfig systemd

DEPENDS += " \
    amd-apml \
    i2c-tools \
    phosphor-dbus-interfaces \
    phosphor-logging \
    sdbusplus \
    libgpiod \
    boost \
    nlohmann-json \
    "

SRC_URI = "git://git@github.com:/AMDESE/vr-firmware-update.git;branch=main;protocol=ssh"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

INSANE_SKIP_${PN} += "ldflags"
RDEPENDS_${PN} += "bash"

do_install() {
        install -d ${D}${sbindir}
        install -m 0755 vr-update ${D}${sbindir}
        install -m 0755 ${S}/config/vr-config-info ${D}/${sbindir}/
}
