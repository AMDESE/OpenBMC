SUMMARY = "AMD YAAPd Jtag server Application CoolReset Files for Turin"

do_install_append() {
  install -m 0644 ${S}/Data/Turin/1P/* ${D}${sysconfdir}/${BPN}/1P/
  install -m 0644 ${S}/Data/Turin/2P/* ${D}${sysconfdir}/${BPN}/2P/
}
