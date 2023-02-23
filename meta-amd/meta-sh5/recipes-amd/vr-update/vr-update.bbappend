SUMMARY = "VR config files for SH5"

do_install_append() {
    install -m 0755 ${S}/config/sh5-vr.json ${D}/${sbindir}/
}
