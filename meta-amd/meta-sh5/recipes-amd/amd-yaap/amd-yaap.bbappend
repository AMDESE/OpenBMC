SUMMARY = "AMD YAAPd Jtag server Application CoolReset Files for SH5"

do_install_append() {
  install -m 0644 ${S}/Data/SH5/1P/* ${D}${sysconfdir}/${BPN}/1P/
  install -m 0644 ${S}/Data/SH5/2P/* ${D}${sysconfdir}/${BPN}/2P/
}


