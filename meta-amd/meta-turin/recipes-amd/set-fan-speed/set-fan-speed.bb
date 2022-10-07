SUMMARY = "AMD Fan speed setting service"
DESCRIPTION = "Script for setting Turin Fan speeds at boot time"


LICENSE = "CLOSED"

inherit systemd
SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_${PN} = "set-fan-speed.service"

SRC_URI += " \
        file://set-fan-speed.sh \
        file://set-fan-speed.service \
        "
RDEPENDS_${PN} += "bash"
S="${WORKDIR}"


do_install() {
  install -d ${D}/${sbindir}
  install -m 0755 ${S}/set-fan-speed.sh ${D}/${sbindir}/

  install -d ${D}${systemd_unitdir}/system
  install -c -m 0644 ${WORKDIR}/set-fan-speed.service ${D}/${systemd_unitdir}/system
}

FILES_${PN} += "${systemd_unitdir}/system/set-fan-speed.service"

