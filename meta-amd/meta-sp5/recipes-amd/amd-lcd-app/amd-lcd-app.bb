SUMMARY = "AMD LCD Display Application"
DESCRIPTION = "AMD LCD display Application"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

LICENSE = "CLOSED"

DEPENDS += "amd-lcd-lib"

SRC_URI += "file://amd-lcd-app.c \
            file://amd-lcd.service \
            "

inherit systemd
SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_${PN} = "amd-lcd.service"


TARGET_LDFLAGS = " -llcdlib32"

S="${WORKDIR}"

do_compile () {
  $CC ${CFLAGS} ${LDFLAGS} ${WORKDIR}/amd-lcd-app.c -o amd-lcd-app
}
do_install () {
  install -d ${D}${bindir}
  install -m 0755 ${B}/amd-lcd-app ${D}${bindir}/
  install -d ${D}${systemd_unitdir}/system
  install -c -m 0644 ${WORKDIR}/amd-lcd.service ${D}/${systemd_unitdir}/system
}

FILES_${PN} += "${systemd_unitdir}/system/amd-lcd.service"