SUMMARY = "AMD FPGA Diagnostic Scripts"
DESCRIPTION = "Scripts for dumping HPM FPGA data"

LICENSE = "CLOSED"

SRC_URI += " \
           file://onyx-fpga-dump.sh \
           file://titanite-fpga-dump.sh \
           file://amd-plat-info \
           "

RDEPENDS_${PN} += "bash"
S="${WORKDIR}"

do_install() {
  install -d ${D}/${sbindir}
  install -m 0755 ${S}/*.sh ${D}/${sbindir}/
  install -m 0755 ${S}/amd-plat-info ${D}/${sbindir}/
}

