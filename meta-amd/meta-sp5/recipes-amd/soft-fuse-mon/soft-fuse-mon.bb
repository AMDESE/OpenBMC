SUMMARY = "AMD Soft fuse montior"
DESCRIPTION = "Daemon to monitor soft-fusing completion"


LICENSE = "CLOSED"

#DEPENDS += "libgpiod"

inherit systemd
SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_${PN} = "soft-fuse-mon.service"

SRC_URI += " \
        file://soft-fuse-mon.sh \
        file://soft-fuse-mon.service \
        "
RDEPENDS_${PN} += "bash"
S="${WORKDIR}"


do_install() {
  install -d ${D}/${sbindir}
  install -m 0755 ${S}/soft-fuse-mon.sh ${D}/${sbindir}/

  install -d ${D}${systemd_unitdir}/system
  install -c -m 0644 ${WORKDIR}/soft-fuse-mon.service ${D}/${systemd_unitdir}/system
}

FILES_${PN} += "${systemd_unitdir}/system/soft-fuse-mon.service"

