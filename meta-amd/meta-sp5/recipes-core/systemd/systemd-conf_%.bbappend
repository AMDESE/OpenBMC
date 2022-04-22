FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://00-bmc-eth0.network \
    file://00-bmc-eth1.network \
"

do_install_append() {
    install -m 0644 \
        ${WORKDIR}/00-bmc-eth0.network \
        ${WORKDIR}/00-bmc-eth1.network \
        -D -t ${D}${sysconfdir}/systemd/network
}

FILES_${PN}_append = " \
    ${sysconfdir}/systemd/network/00-bmc-eth0.network \
    ${sysconfdir}/systemd/network/00-bmc-eth1.network \
"
