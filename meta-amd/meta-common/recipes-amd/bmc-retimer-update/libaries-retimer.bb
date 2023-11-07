SUMMARY = "Aries retimer update"
DESCRIPTION = "Update application to program Aries PCIe retimer firmware"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

inherit meson

LICENSE = "CLOSED"
DEPENDS += "i2c-tools"

# Include aries sdk as-is with retimer-updater
SRC_URI="git://git@github.com:/AMDESE/bmc-retimer-update.git;branch=main;protocol=ssh"
SRCREV = "${AUTOREV}"
S="${WORKDIR}/git/libaries"
