SUMMARY = "AMD application to handle Turin Lenovo Backplane"
DESCRIPTION = "The applications runs after AC Cycle and configure Lenovo Backplane"

LICENSE = "CLOSED"

FILESEXTRAPATHS_prepend := "${THISDIR}:"

inherit cmake pkgconfig systemd

def get_service(d):
    return "com.amd.ubm.service"

SYSTEMD_SERVICE_${PN} = "${@get_service(d)}"
SRC_URI = "git://git@github.com:/AMDESE/amd-bmc-ubm.git;branch=main;protocol=ssh"
SRCREV_pn-amd-bmc-ubm = "${AUTOREV}"

S = "${WORKDIR}/git"

DEPENDS += " \
    i2c-tools \
    phosphor-dbus-interfaces \
    phosphor-logging \
    sdbusplus \
    boost \
    "

FILES_${PN} += "${systemd_unitdir}/system/com.amd.ubm.service"
