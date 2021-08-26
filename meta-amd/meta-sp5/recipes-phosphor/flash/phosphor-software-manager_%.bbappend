FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://bios-update.sh \
            file://scm-fpga-update.sh \
            file://hpm-fpga-update.sh \
            file://0001-Add-support-for-SCM-FPGA-firmware-update.patch \
            file://0002-Add-support-for-HPM-FPGA-firmware-update.patch \
            file://0003-save-version-to-persistent-store.patch \
            file://0004-change-backup-version-as-invalid-after-activation.patch \
            file://0005-fix-image-updater-crash-on-invalid-version.patch \
            "

PACKAGECONFIG_append = " flash_bios flash_scm_fpga flash_hpm_fpga"
RDEPENDS_${PN} += "bash"

do_install_append() {
    install -d ${D}/${sbindir}
    install -m 0755 ${WORKDIR}/bios-update.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/scm-fpga-update.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/hpm-fpga-update.sh ${D}/${sbindir}/
}
