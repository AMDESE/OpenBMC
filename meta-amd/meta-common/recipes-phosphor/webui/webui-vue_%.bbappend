FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRCREV = "aaff26ef8262df7d6b5bfdd5da52b75a158a4ec5"

SRC_URI += "file://0001-webvue-ui-Support-HPM-and-SCM-FPGA-firmware-updates.patch \
            file://0002-poll-for-firmware-update-progress-and-completion.patch \
            file://0003-order-sensor-array-by-new-values.patch \
            file://0004-SOL-console-shows-disconnected-when-opened-with-Open.patch \
            file://0005-Enable-AMD-power-cap-application.patch \
            file://0006-VR-webui-changes.patch \
            file://0007-add-support-for-retimer-firmware-update.patch \
            file://0008-add-POST-timestamp-as-sortable-field.patch \
            file://0009-add-delete-all-button-to-POST-code-page.patch \
            file://0010-show-recent-200-post-codes.patch \
            file://0011-webUI-changes-to-display-CPU-information.patch \
            file://0012-increase-firmware-update-max-timeout.patch \
            file://0013-allow-zero-as-power-limit-value.patch \
            file://0014-webui-vue-Session-Timeout-text-box-in-BMC-GUI.patch \
            file://0015-webui-vue-Removed-CPU-info-from-Overview-Page.patch \
            file://0016-Added-Processor-info-in-Hardware-Inventory-page.patch \
            file://0017-webui-changes-to-support-vrbundle-update.patch \
            file://0018-Fixed-skip-count-logic-in-webui-vue.patch \
            file://0019-webui-vue-Add-FPGA-image-update-notification.patch \
            file://0020-enable-checkbox-for-firmware-inventory-reset.patch \
            file://0021-Status-message-update-for-VR-update.patch \
            file://0022-webui-vue-Corrected-Factory-reset-message.patch \
            file://0023-web-vue-add-support-for-Retimer-Bundle-firmware-upda.patch \
            "
