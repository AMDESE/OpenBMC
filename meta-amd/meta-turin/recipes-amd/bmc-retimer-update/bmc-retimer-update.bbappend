SUMMARY = "Retimer platform specific config files for Turin"

do_install_append() {
    install -d ${D}${sysconfdir}/bmc-retimer-update
    install -m 0755 ${S}/config/volcano-retimer.json ${D}${sysconfdir}/bmc-retimer-update/
}
