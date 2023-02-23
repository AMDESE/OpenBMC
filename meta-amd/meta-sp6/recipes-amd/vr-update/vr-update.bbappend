SUMMARY = "VR config files for SP6"

do_install_append() {
    install -m 0755 ${S}/config/shale-vr.json ${D}/${sbindir}/
    install -m 0755 ${S}/config/cinnabar-vr.json ${D}/${sbindir}/
    install -m 0755 ${S}/config/sunstone-vr.json ${D}/${sbindir}/
}
