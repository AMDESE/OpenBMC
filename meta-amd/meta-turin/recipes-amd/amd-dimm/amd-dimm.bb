SUMMARY = "AMD DIMM SPD and PMIC access"
DESCRIPTION = "Script for reading DIMM SPD and PMIC Registers"


LICENSE = "CLOSED"

inherit systemd
SYSTEMD_AUTO_ENABLE = "enable"

SRC_URI += " \
        file://dimm-spd-data.sh  \
        file://dimm-pmic-data.sh \
        file://dimm-pmic-err.sh \
        file://dimm-re-bind.sh   \
        file://dimm-info.sh \
        "
RDEPENDS_${PN} += "bash"
S="${WORKDIR}"


do_install() {
  install -d ${D}/${sbindir}
  install -m 0755 ${S}/dimm-spd-data.sh ${D}/${sbindir}/
  install -m 0755 ${S}/dimm-pmic-data.sh ${D}/${sbindir}/
  install -m 0755 ${S}/dimm-re-bind.sh ${D}/${sbindir}/
  install -m 0755 ${S}/dimm-info.sh ${D}/${sbindir}/
  install -m 0755 ${S}/dimm-pmic-err.sh ${D}/${sbindir}/
}
