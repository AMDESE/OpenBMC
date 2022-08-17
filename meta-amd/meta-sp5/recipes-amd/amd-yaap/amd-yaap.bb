SUMMARY = "AMD YAAPd Jtag server Application"
DESCRIPTION = "Yet Another AMD Protocol for Jtag communication with main Processor"

LICENSE = "CLOSED"

SRC_URI  = "git://git@github.com/AMDESE/YAAP.git;branch=sp5;protocol=ssh"

SRCREV = "${AUTOREV}"

S="${WORKDIR}/git"

PV = "1.0+git${SRCPV}"

# linux-libc-headers guides this way to include custom uapi headers
#CFLAGS_append = " -I ${STAGING_KERNEL_DIR}/include"
#CXXFLAGS_append = " -I ${STAGING_KERNEL_DIR}/include"
#do_configure[depends] += "virtual/kernel:do_shared_workdir"

do_compile() {
  make
}

do_install() {
  install -d ${D}${bindir}
  cp --preserve=mode,timestamps -R ${S}/Source/Linux/bmc/yaapd ${D}${bindir}/
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${S}/yaapd.service ${D}/${systemd_unitdir}/system
  install -d ${D}${sysconfdir}/${BPN}/SP5/1P
  install -d ${D}${sysconfdir}/${BPN}/SP5/2P
  install -d ${D}${sysconfdir}/${BPN}/SH5/1P
  install -d ${D}${sysconfdir}/${BPN}/SH5/2P
  install -d ${D}${sysconfdir}/${BPN}/SP6/1P
  install -d ${D}${sysconfdir}/${BPN}/SP6/2P
  install -m 0644 ${S}/Data/SP5/1P/* ${D}${sysconfdir}/${BPN}/SP5/1P/
  install -m 0644 ${S}/Data/SP5/2P/* ${D}${sysconfdir}/${BPN}/SP5/2P/
  install -m 0644 ${S}/Data/SH5/1P/* ${D}${sysconfdir}/${BPN}/SH5/1P/
  install -m 0644 ${S}/Data/SH5/2P/* ${D}${sysconfdir}/${BPN}/SH5/2P/
  install -m 0644 ${S}/Data/SP6/1P/* ${D}${sysconfdir}/${BPN}/SP6/1P/
  install -m 0644 ${S}/Data/SP6/2P/* ${D}${sysconfdir}/${BPN}/SP6/2P/.
}

inherit systemd
SYSTEMD_SERVICE_${PN} += "yaapd.service \
                          "

DEPENDS += "libgpiod"
DEPENDS += "boost"
