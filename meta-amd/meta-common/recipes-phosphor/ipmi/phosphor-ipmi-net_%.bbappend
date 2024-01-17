FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-change-defaults-for-SOL-buffering.patch \
            file://0002-Fixed-the-Console-Socket-path-for-IPMI-Sol.patch \
           "

ALT_RMCPP_IFACE = "eth1"
SYSTEMD_SERVICE_${PN} += " \
    ${PN}@${ALT_RMCPP_IFACE}.service \
     ${PN}@${ALT_RMCPP_IFACE}.socket \
     "
