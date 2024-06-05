SUMMARY = "AMD Scandump application to perform the MDC SDU flow"
DESCRIPTION = "The application performs the MDC SDU flow over \
               existing Management Interfaces(i.e APML)"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

FILESEXTRAPATHS_prepend := "${THISDIR}:"

inherit meson
inherit pkgconfig
inherit systemd
inherit phosphor-mapper

def get_service(d):
    return "xyz.openbmc_project.Sdu.service"

SYSTEMD_SERVICE_${PN} = "${@get_service(d)}"
SRC_URI = "git://git@github.com:/AMDESE/bmc-mdc-sdutool.git;branch=main;protocol=ssh"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

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

FILES_${PN} += "${systemd_unitdir}/system/xyz.openbmc_project.Sdu.service"
