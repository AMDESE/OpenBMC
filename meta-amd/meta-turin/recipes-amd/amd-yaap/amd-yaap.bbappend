SUMMARY = "AMD YAAPd Jtag server Application CoolReset Files for Turin"

TARGET_CFLAGS += " -DJTAG_MODE_BMC_ONLY "

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
        file://yaapd.service \
        "
RDEPENDS_${PN} += "bash"

do_install_append() {
  install -m 0644 ${S}/Data/Turin/1P/* ${D}${sysconfdir}/${BPN}/1P/
  install -m 0644 ${S}/Data/Turin/2P/* ${D}${sysconfdir}/${BPN}/2P/
}

do_configure_append() {
  cp -f ${WORKDIR}/yaapd.service ${S}/
}
