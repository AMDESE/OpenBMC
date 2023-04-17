FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

OBMC_CONSOLE_HOST_TTY = "ttyS0"

SRC_URI_remove = "file://${BPN}.conf"
SRC_URI += "file://server.ttyS0.conf \
            file://0001-Route-io1-to-uart1.patch \
            file://client.2200.conf \
            "
EXTRA_OECONF_append = " --enable-concurrent-servers"
SYSTEMD_SERVICE_${PN}_remove = "obmc-console-ssh.socket"
SYSTEMD_SERVICE_${PN}_append = " obmc-console-ssh@2200.service obmc-console-ssh@2201.service"
REGISTERED_SERVICES_${PN}_append = " obmc_console_host0:tcp:2200: obmc_console_host1:tcp:2201:"
FILES_${PN}_remove = "/lib/systemd/system/obmc-console-ssh@.service.d/use-socket.conf"

do_install_append() {
	# Remove upstream-provided configuration
	rm -rf ${D}${sysconfdir}/${BPN}

	# Install the server configuration
	install -m 0755 -d ${D}${sysconfdir}/${BPN}
	install -m 0644 ${WORKDIR}/*.conf ${D}${sysconfdir}/${BPN}/
}
