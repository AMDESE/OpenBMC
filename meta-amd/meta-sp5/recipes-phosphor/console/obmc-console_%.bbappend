FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RDEPENDS_${PN} += "bash"

SRC_URI_remove = "file://${BPN}.conf"
SRC_URI += "file://server.ttyS0.conf \
            file://0001-remove-local-tty-params.patch \
            file://switch_uart.sh \
            "

do_install_append() {

	# Install the server configuration
	install -m 0755 -d ${D}${sysconfdir}/${BPN}
	install -m 0644 ${WORKDIR}/*.conf ${D}${sysconfdir}/${BPN}/
	install -m 0755 ${WORKDIR}/*.sh ${D}/${sbindir}/
}
