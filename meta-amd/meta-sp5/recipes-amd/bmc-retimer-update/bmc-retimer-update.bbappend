SUMMARY = "Retimer platform specific config files for SP5"

do_install_append() {
    install -d ${D}${sysconfdir}/bmc-retimer-update
    install -m 0755 ${S}/config/titanite-retimer.json ${D}${sysconfdir}/bmc-retimer-update/
}
