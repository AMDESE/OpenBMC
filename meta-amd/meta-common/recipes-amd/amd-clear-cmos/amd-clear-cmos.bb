SUMMARY = "AMD Clear BIOS CMOS application"
DESCRIPTION = "Script for clearing BIOS CMOS data"

LICENSE = "CLOSED"

SRC_URI += " \
        file://amd-clear-cmos.sh \
        "
RDEPENDS_${PN} += "bash"
S="${WORKDIR}"

do_install() {
  install -d ${D}/${sbindir}
  install -m 0755 ${S}/amd-clear-cmos.sh ${D}/${sbindir}/

}

