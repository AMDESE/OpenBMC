FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://bios-update.sh \
            file://scm-fpga-update.sh \
            file://0001-Add-support-for-SCM-FPGA-firmware-update.patch \
            "

PACKAGECONFIG_append = " flash_bios flash_scm_fpga"
RDEPENDS_${PN} += "bash"

do_install_append() {
    install -d ${D}/${sbindir}
    install -m 0755 ${WORKDIR}/bios-update.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/scm-fpga-update.sh ${D}/${sbindir}/
}
