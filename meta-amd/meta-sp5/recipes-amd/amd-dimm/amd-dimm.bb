SUMMARY = "AMD DIMM SPD and PMIC access"
DESCRIPTION = "Script for reading DIMM SPD and PMIC Registers"


LICENSE = "CLOSED"

SRC_URI += " \
        file://dimm-spd-data.sh  \
        file://dimm-pmic-data.sh \
        file://dimm-re-bind.sh   \
        file://dimm-pmic-temp.sh \
        "
RDEPENDS_${PN} += "bash"
S="${WORKDIR}"


do_install() {
  install -d ${D}/${sbindir}
  install -m 0755 ${S}/dimm-spd-data.sh ${D}/${sbindir}/
  install -m 0755 ${S}/dimm-pmic-data.sh ${D}/${sbindir}/
  install -m 0755 ${S}/dimm-pmic-temp.sh ${D}/${sbindir}/
  install -m 0755 ${S}/dimm-re-bind.sh ${D}/${sbindir}

}

