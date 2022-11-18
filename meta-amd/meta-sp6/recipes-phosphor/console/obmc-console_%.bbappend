FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"


SRC_URI += "file://0001-Start-console-server-based-on-board-id.patch"
SRC_URI += "file://server.ttyVUART0.conf"

do_install_append() {
	# Remove upstream-provided configuration
	rm -rf ${D}${sysconfdir}/${BPN}

	# Install the server configuration
	install -m 0755 -d ${D}${sysconfdir}/${BPN}
	install -m 0644 ${WORKDIR}/*.conf ${D}${sysconfdir}/${BPN}/
}
