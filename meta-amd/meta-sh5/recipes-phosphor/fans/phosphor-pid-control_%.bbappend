FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

EXTRA_OECONF_append = " --enable-configure-dbus=yes"

SRC_URI_append += " file://onyx-stepwise-config.json \
                    file://quartz-stepwise-config.json \
                    file://ruby-stepwise-config.json \
                    file://titanite-stepwise-config.json \
                    file://set-platform-json-config.sh \
                    file://phosphor-pid-control.service \
                    file://phosphor-pid-control.path \
                    file://0001-phosphor-pid-control-Add-CPU-Temp-simulation-code.patch \
                    file://0002-phosphor-pid-control-Modify-Sensor-based-Temp-simulation.patch \
                  "

FILES_${PN}_append = " ${datadir}/swampd/onyx-stepwise-config.json \
                       ${datadir}/swampd/quartz-stepwise-config.json \
                       ${datadir}/swampd/ruby-stepwise-config.json \
                       ${datadir}/swampd/titanite-stepwise-config.json \
                       ${bindir}/set-platform-json-config.sh \
                     "

RDEPENDS_${PN} += "bash"

SYSTEMD_SERVICE_${PN}_append = " phosphor-pid-control.service phosphor-pid-control.path"

do_install_append() {
    install -d ${D}/${bindir}
    install -m 0755 ${WORKDIR}/set-platform-json-config.sh ${D}/${bindir}

    install -d ${D}${datadir}/swampd
    install -m 0644 -D ${WORKDIR}/onyx-stepwise-config.json \
        ${D}${datadir}/swampd/onyx-stepwise-config.json
    install -m 0644 -D ${WORKDIR}/quartz-stepwise-config.json \
        ${D}${datadir}/swampd/quartz-stepwise-config.json
    install -m 0644 -D ${WORKDIR}/ruby-stepwise-config.json \
        ${D}${datadir}/swampd/ruby-stepwise-config.json
    install -m 0644 -D ${WORKDIR}/titanite-stepwise-config.json \
        ${D}${datadir}/swampd/titanite-stepwise-config.json

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/phosphor-pid-control.service \
        ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/phosphor-pid-control.path \
        ${D}${systemd_system_unitdir}
    mkdir -p thermal.d ${D}/etc/thermal.d
    touch ${D}/etc/thermal.d/tuning
}

FILES_${PN} += "/etc/thermal.d/tuning"


