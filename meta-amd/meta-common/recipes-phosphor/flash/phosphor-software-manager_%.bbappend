FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://bios-update.sh \
            file://scm-fpga-update.sh \
            file://hpm-fpga-update.sh \
            file://amd-reset-u-boot-env.sh \
            file://0001-Add-support-for-SCM-FPGA-firmware-update.patch \
            file://0002-Add-support-for-HPM-FPGA-firmware-update.patch \
            file://0003-save-version-to-persistent-store.patch \
            file://0004-change-backup-version-as-invalid-after-activation.patch \
            file://0005-fix-image-updater-crash-on-invalid-version.patch \
            file://0006-delete-stale-objects-after-activation.patch \
            file://0007-phosphor-software-manager-Add-LCD-write-for-FW-ver.patch \
            file://0008-phosphor-software-manager-Delete-LCD-extra-char.patch \
            file://0009-recipes-phosphor-software-manager-Adding-service.in.patch \
            file://0010-recipes-phosphor-software-manager-Fixing-activation.patch \
            file://0011-add-support-for-retimer-update.patch \
            file://0012-read-HPM-FPGA-version-from-FPGA-i2c-slave.patch \
            file://0013-add-host-factory-reset-to-resetAll-handler.patch \
            file://0014-phosphor-software-manager-Modify-to-call-u-boot-env-script.patch \
            "
DEPENDS += "amd-lcd-lib"

TARGET_LDFLAGS += " -llcdlib32"

PACKAGECONFIG_append = " flash_bios flash_scm_fpga flash_hpm_fpga flash_vr flash_retimer"
RDEPENDS_${PN} += "bash"

do_install_append() {
    install -d ${D}/${sbindir}
    install -m 0755 ${WORKDIR}/bios-update.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/scm-fpga-update.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/hpm-fpga-update.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/amd-reset-u-boot-env.sh ${D}/${sbindir}/
}
