SUMMARY = "VR config files for Turin"

do_install_append() {
    install -m 0755 ${S}/config/chalupa-vr.json ${D}/${sbindir}/
    install -m 0755 ${S}/config/galena-vr.json ${D}/${sbindir}/
    install -m 0755 ${S}/config/recluse-vr.json ${D}/${sbindir}/
    install -m 0755 ${S}/config/purico-vr.json ${D}/${sbindir}/
    install -m 0755 ${S}/config/volcano-vr.json ${D}/${sbindir}/
    install -m 0755 ${S}/config/huambo-vr.json ${D}/${sbindir}/
}
