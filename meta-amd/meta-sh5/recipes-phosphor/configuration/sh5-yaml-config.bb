SUMMARY = "YAML configuration for sh5"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit allarch

SRC_URI = " \
    file://onyx-ipmi-sensors.yaml \
    file://onyx-ipmi-fru.yaml \
    file://onyx-ipmi-fru-properties.yaml \
    file://onyx-ipmi-inventory-sensors.yaml \
    file://sh5d807-ipmi-sensors.yaml \
    file://sh5d807-ipmi-fru.yaml \
    file://sh5d807-ipmi-fru-properties.yaml \
    file://sh5d807-ipmi-inventory-sensors.yaml \
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
     cat sh5d807-ipmi-fru.yaml > fru-read.yaml
    install -m 0644 -D sh5d807-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/sh5d807-ipmi-extra-properties.yaml
    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/sh5d807-ipmi-fru-read.yaml
    install -m 0644 -D sh5d807-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/sh5d807-ipmi-sensors.yaml
    install -m 0644 -D sh5d807-ipmi-inventory-sensors.yaml \
        ${D}${datadir}/${BPN}/sh5d807-ipmi-inventory-sensors.yaml
}

FILES_${PN}-dev = " \
    ${datadir}/${BPN}/onyx-ipmi-sensors.yaml \
    ${datadir}/${BPN}/onyx-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/onyx-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/onyx-ipmi-inventory-sensors.yaml \
    ${datadir}/${BPN}/sh5d807-ipmi-sensors.yaml \
    ${datadir}/${BPN}/sh5d807-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/sh5d807-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/sh5d807-ipmi-inventory-sensors.yaml \
    "

ALLOW_EMPTY_${PN} = "1"
