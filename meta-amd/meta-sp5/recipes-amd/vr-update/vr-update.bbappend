SUMMARY = "VR config files for SP5"

do_install_append() {
    install -m 0755 ${S}/config/onyx-vr.json ${D}/${sbindir}/
    install -m 0755 ${S}/config/quartz-vr.json ${D}/${sbindir}/
    install -m 0755 ${S}/config/ruby-vr.json ${D}/${sbindir}/
    install -m 0755 ${S}/config/titanite-vr.json ${D}/${sbindir}/
}
