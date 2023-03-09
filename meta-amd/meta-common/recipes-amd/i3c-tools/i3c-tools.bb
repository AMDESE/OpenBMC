SUMMARY = "Aspeedtech I3C tools adapted by AMD"
DESCRIPTION = "To build I3C tools"
FILESEXTRAPATHS_prepend := "${THISDIR}:"

#Code pulled from https://github.com/vitor-soares-snps/i3c-tools.git
#which does not have a license, so using "closed" for now
LICENSE = "CLOSED"

SRC_URI = "git://git@github.com/AspeedTech-BMC/i3c-tools.git;protocol=https"
SRCREV = "${AUTOREV}"

S="${WORKDIR}/git"

inherit meson

do_install () {
        install -d ${D}${bindir}
        install -m 0755 ${B}/i3ctransfer ${D}${bindir}/

}
