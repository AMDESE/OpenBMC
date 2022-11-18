FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://vr-update.sh \
            file://retimer-update.sh \
            "
RDEPENDS_${PN} += "bash"

do_install_append() {
    install -d ${D}/${sbindir}
    install -m 0755 ${WORKDIR}/vr-update.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/retimer-update.sh ${D}/${sbindir}/
}
