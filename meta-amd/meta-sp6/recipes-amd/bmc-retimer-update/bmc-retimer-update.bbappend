SUMMARY = "Retimer platform specific config files for SP6"

do_install_append() {
    install -d ${D}${sysconfdir}/bmc-retimer-update
    install -m 0755 ${S}/config/cinnabar-retimer.json ${D}${sysconfdir}/bmc-retimer-update/
    install -m 0755 ${S}/config/sunstone-retimer.json ${D}${sysconfdir}/bmc-retimer-update/
    install -m 0755 ${S}/config/shale-retimer.json ${D}${sysconfdir}/bmc-retimer-update/
}
