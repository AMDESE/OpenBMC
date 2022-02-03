FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRCREV = "aaff26ef8262df7d6b5bfdd5da52b75a158a4ec5"

SRC_URI += "file://0001-webvue-ui-Support-HPM-and-SCM-FPGA-firmware-updates.patch \
            file://0002-poll-for-firmware-update-progress-and-completion.patch \
            file://0003-order-sensor-array-by-new-values.patch \
            file://0004-SOL-console-shows-disconnected-when-opened-with-Open.patch \
            file://0005-Enable-AMD-power-cap-application.patch \
            file://0006-VR-webui-changes.patch \
            file://0007-add-support-for-retimer-firmware-update.patch \
            "
