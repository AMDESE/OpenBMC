SUMMARY = "AMD Front Panel LED application to handle System Front Panel Buttons and LEDs"
DESCRIPTION = "The application Monitor Front Panel Buttons and turn proper LED On or Off"

LICENSE = "CLOSED"

FILESEXTRAPATHS_prepend := "${THISDIR}:"

inherit meson
inherit pkgconfig
inherit systemd
inherit phosphor-mapper

def get_service(d):
    return "com.amd.fpled.service"

SYSTEMD_SERVICE_${PN} = "${@get_service(d)}"
SRC_URI = "git://git@github.com:/AMDESE/bmc-fp-led.git;branch=main;protocol=ssh"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

DEPENDS += " \
    i2c-tools \
    phosphor-dbus-interfaces \
    phosphor-logging \
    sdbusplus \
    libgpiod \
    boost \
    nlohmann-json \
    "

FILES_${PN} += "${systemd_unitdir}/system/com.amd.fpled.service"
