SUMMARY = "AMD YAAPd Jtag server Application CoolReset Files for SP6"

do_install_append() {
  install -m 0644 ${S}/Data/SP6/1P/* ${D}${sysconfdir}/${BPN}/1P/
  install -m 0644 ${S}/Data/SP6/2P/* ${D}${sysconfdir}/${BPN}/2P/
}
