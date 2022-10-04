SUMMARY = "YAML configuration for sp5"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit allarch

SRC_URI = " \
    file://quartz-ipmi-sensors.yaml \
    file://quartz-ipmi-fru.yaml \
    file://quartz-ipmi-fru-properties.yaml \
    file://quartz-ipmi-inventory-sensors.yaml \
    file://onyx-ipmi-sensors.yaml \
    file://onyx-ipmi-fru.yaml \
    file://onyx-ipmi-fru-properties.yaml \
    file://onyx-ipmi-inventory-sensors.yaml \
    file://ruby-ipmi-sensors.yaml \
    file://ruby-ipmi-fru.yaml \
    file://ruby-ipmi-fru-properties.yaml \
    file://ruby-ipmi-inventory-sensors.yaml \
    file://titanite-ipmi-sensors.yaml \
    file://titanite-ipmi-fru.yaml \
    file://titanite-ipmi-fru-properties.yaml \
    file://titanite-ipmi-inventory-sensors.yaml \
    "

S = "${WORKDIR}"

do_install() {
    cat onyx-ipmi-fru.yaml > fru-read.yaml
    install -m 0644 -D onyx-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/onyx-ipmi-extra-properties.yaml
    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/onyx-ipmi-fru-read.yaml
    install -m 0644 -D onyx-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/onyx-ipmi-sensors.yaml
    install -m 0644 -D onyx-ipmi-inventory-sensors.yaml \
        ${D}${datadir}/${BPN}/onyx-ipmi-inventory-sensors.yaml
    cat quartz-ipmi-fru.yaml > fru-read.yaml
    install -m 0644 -D quartz-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/quartz-ipmi-extra-properties.yaml
    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/quartz-ipmi-fru-read.yaml
    install -m 0644 -D quartz-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/quartz-ipmi-sensors.yaml
    install -m 0644 -D quartz-ipmi-inventory-sensors.yaml \
        ${D}${datadir}/${BPN}/quartz-ipmi-inventory-sensors.yaml
    cat ruby-ipmi-fru.yaml > fru-read.yaml
    install -m 0644 -D ruby-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/ruby-ipmi-extra-properties.yaml
    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/ruby-ipmi-fru-read.yaml
    install -m 0644 -D ruby-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/ruby-ipmi-sensors.yaml
    install -m 0644 -D ruby-ipmi-inventory-sensors.yaml \
        ${D}${datadir}/${BPN}/ruby-ipmi-inventory-sensors.yaml
    cat titanite-ipmi-fru.yaml > fru-read.yaml
    install -m 0644 -D titanite-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/titanite-ipmi-extra-properties.yaml
    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/titanite-ipmi-fru-read.yaml
    install -m 0644 -D titanite-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/titanite-ipmi-sensors.yaml
    install -m 0644 -D titanite-ipmi-inventory-sensors.yaml \
        ${D}${datadir}/${BPN}/titanite-ipmi-inventory-sensors.yaml

}

FILES_${PN}-dev = " \
    ${datadir}/${BPN}/onyx-ipmi-sensors.yaml \
    ${datadir}/${BPN}/onyx-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/onyx-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/onyx-ipmi-inventory-sensors.yaml \
    ${datadir}/${BPN}/quartz-ipmi-sensors.yaml \
    ${datadir}/${BPN}/quartz-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/quartz-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/quartz-ipmi-inventory-sensors.yaml \
    ${datadir}/${BPN}/ruby-ipmi-sensors.yaml \
    ${datadir}/${BPN}/ruby-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/ruby-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/ruby-ipmi-inventory-sensors.yaml \
    ${datadir}/${BPN}/titanite-ipmi-sensors.yaml \
    ${datadir}/${BPN}/titanite-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/titanite-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/titanite-ipmi-inventory-sensors.yaml \
    "

ALLOW_EMPTY_${PN} = "1"
