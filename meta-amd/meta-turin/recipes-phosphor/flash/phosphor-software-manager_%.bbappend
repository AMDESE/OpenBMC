FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://vr-update.sh \
            file://bios-update.sh \
            file://hpm-fpga-update.sh \
            file://scm-fpga-update.sh \
            "

RDEPENDS_${PN} += "bash"

do_install_append() {
    install -d ${D}/${sbindir}
    install -m 0755 ${WORKDIR}/vr-update.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/bios-update.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/hpm-fpga-update.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/scm-fpga-update.sh ${D}/${sbindir}/
}
