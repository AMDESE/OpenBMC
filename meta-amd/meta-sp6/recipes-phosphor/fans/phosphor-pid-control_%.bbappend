FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

EXTRA_OECONF_append = " --enable-configure-dbus=yes"

SRC_URI_append += " file://shale96-stepwise-config.json \
                    file://shale64-stepwise-config.json \
                    file://cinnabar-stepwise-config.json \
                    file://sunstone-stepwise-config.json \
                    file://set-platform-json-config.sh \
                    file://phosphor-pid-control.service \
                    file://0001-phosphor-pid-control-Add-CPU-Temp-simulation-code.patch \
                    file://0002-phosphor-pid-control-Modify-Sensor-based-Temp-simulation.patch \
                  "

FILES_${PN}_append = " ${datadir}/swampd/shale96-stepwise-config.json \
                       ${datadir}/swampd/shale64-stepwise-config.json \
                       ${datadir}/swampd/cinnabar-stepwise-config.json \
                       ${datadir}/swampd/sunstone-stepwise-config.json \
                       ${bindir}/set-platform-json-config.sh \
                     "

RDEPENDS_${PN} += "bash"

SYSTEMD_SERVICE_${PN}_append = " phosphor-pid-control.service"

do_install_append() {
    install -d ${D}/${bindir}
    install -m 0755 ${WORKDIR}/set-platform-json-config.sh ${D}/${bindir}

    install -d ${D}${datadir}/swampd
    install -m 0644 -D ${WORKDIR}/shale96-stepwise-config.json \
        ${D}${datadir}/swampd/shale96-stepwise-config.json
    install -m 0644 -D ${WORKDIR}/shale64-stepwise-config.json \
        ${D}${datadir}/swampd/shale64-stepwise-config.json
    install -m 0644 -D ${WORKDIR}/cinnabar-stepwise-config.json \
        ${D}${datadir}/swampd/cinnabar-stepwise-config.json
    install -m 0644 -D ${WORKDIR}/sunstone-stepwise-config.json \
        ${D}${datadir}/swampd/sunstone-stepwise-config.json

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/phosphor-pid-control.service \
        ${D}${systemd_system_unitdir}
    mkdir -p thermal.d ${D}/etc/thermal.d
    touch ${D}/etc/thermal.d/tuning
}

FILES_${PN} += "/etc/thermal.d/tuning"


