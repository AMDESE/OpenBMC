FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

EXTRA_OECONF_append = " --enable-configure-dbus=yes"

SRC_URI_append += " file://galena-stepwise-config.json \
                    file://recluse-stepwise-config.json \
                    file://chalupa-stepwise-config.json \
                    file://purico-stepwise-config.json \
                    file://volcano-stepwise-config.json \
                    file://huambo-stepwise-config.json \
                    file://set-platform-json-config.sh \
                    file://phosphor-pid-control.service \
                    file://0001-phosphor-pid-control-Add-CPU-Temp-simulation-code.patch \
                    file://0002-phosphor-pid-control-Modify-Sensor-based-Temp-simulation.patch \
                  "

FILES_${PN}_append = " ${datadir}/swampd/galena-stepwise-config.json \
                       ${datadir}/swampd/recluse-stepwise-config.json \
                       ${datadir}/swampd/chalupa-stepwise-config.json \
                       ${datadir}/swampd/purico-stepwise-config.json \
                       ${datadir}/swampd/volcano-stepwise-config.json \
                       ${datadir}/swampd/huambo-stepwise-config.json \
                       ${bindir}/set-platform-json-config.sh \
                     "

RDEPENDS_${PN} += "bash"

SYSTEMD_SERVICE_${PN}_append = " phosphor-pid-control.service"

do_install_append() {
    install -d ${D}/${bindir}
    install -m 0755 ${WORKDIR}/set-platform-json-config.sh ${D}/${bindir}

    install -d ${D}${datadir}/swampd
    install -m 0644 -D ${WORKDIR}/galena-stepwise-config.json \
        ${D}${datadir}/swampd/galena-stepwise-config.json
    install -m 0644 -D ${WORKDIR}/recluse-stepwise-config.json \
        ${D}${datadir}/swampd/recluse-stepwise-config.json
    install -m 0644 -D ${WORKDIR}/chalupa-stepwise-config.json \
        ${D}${datadir}/swampd/chalupa-stepwise-config.json
    install -m 0644 -D ${WORKDIR}/purico-stepwise-config.json \
        ${D}${datadir}/swampd/purico-stepwise-config.json
    install -m 0644 -D ${WORKDIR}/volcano-stepwise-config.json \
        ${D}${datadir}/swampd/volcano-stepwise-config.json
    install -m 0644 -D ${WORKDIR}/huambo-stepwise-config.json \
        ${D}${datadir}/swampd/huambo-stepwise-config.json

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/phosphor-pid-control.service \
        ${D}${systemd_system_unitdir}
    mkdir -p thermal.d ${D}/etc/thermal.d
    touch ${D}/etc/thermal.d/tuning
}

FILES_${PN} += "/etc/thermal.d/tuning"


