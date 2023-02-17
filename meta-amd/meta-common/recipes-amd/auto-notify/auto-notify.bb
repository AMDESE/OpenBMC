SUMMARY = "Notify Automation Scripts"
DESCRIPTION = "Scripts for notifying automation servers"

LICENSE = "CLOSED"

inherit systemd

SRC_URI = "git://git@github.com:/AMDESE/notify-automation.git;branch=main;protocol=ssh;tag=v0.0.1"

RDEPENDS_${PN} += " bash curl"
S="${WORKDIR}/git"
SYSTEMD_SERVICE_${PN} = "auto-notify.service"

do_install() {
  install -d ${D}/${sbindir}
  install -m 0755 ${S}/*.sh ${D}/${sbindir}/
  install -d ${D}${systemd_system_unitdir}
  install -m 0644 ${S}/auto-notify.service ${D}${systemd_system_unitdir}
}
