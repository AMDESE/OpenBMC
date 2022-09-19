SUMMARY = "YAML configuration for Siena"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit allarch

SRC_URI = " \
    file://shale-ipmi-sensors.yaml \
    file://shale-ipmi-fru.yaml \
    file://shale-ipmi-fru-properties.yaml \
    file://shale-ipmi-inventory-sensors.yaml \
    file://cinnabar-ipmi-sensors.yaml \
    file://cinnabar-ipmi-fru.yaml \
    file://cinnabar-ipmi-fru-properties.yaml \
    file://cinnabar-ipmi-inventory-sensors.yaml \
    file://sunstone-ipmi-sensors.yaml \
    file://sunstone-ipmi-fru.yaml \
    file://sunstone-ipmi-fru-properties.yaml \
    file://sunstone-ipmi-inventory-sensors.yaml \
    "

S = "${WORKDIR}"

do_install() {
    cat shale-ipmi-fru.yaml > fru-read.yaml
    install -m 0644 -D shale-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/shale-ipmi-extra-properties.yaml
    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/shale-ipmi-fru-read.yaml
    install -m 0644 -D shale-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/shale-ipmi-sensors.yaml
    install -m 0644 -D shale-ipmi-inventory-sensors.yaml \
        ${D}${datadir}/${BPN}/shale-ipmi-inventory-sensors.yaml
    cat cinnabar-ipmi-fru.yaml > fru-read.yaml
    install -m 0644 -D cinnabar-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/cinnabar-ipmi-extra-properties.yaml
    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/cinnabar-ipmi-fru-read.yaml
    install -m 0644 -D cinnabar-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/cinnabar-ipmi-sensors.yaml
    install -m 0644 -D cinnabar-ipmi-inventory-sensors.yaml \
        ${D}${datadir}/${BPN}/cinnabar-ipmi-inventory-sensors.yaml
    cat sunstone-ipmi-fru.yaml > fru-read.yaml
    install -m 0644 -D sunstone-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/sunstone-ipmi-extra-properties.yaml
    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/sunstone-ipmi-fru-read.yaml
    install -m 0644 -D sunstone-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/sunstone-ipmi-sensors.yaml
    install -m 0644 -D sunstone-ipmi-inventory-sensors.yaml \
        ${D}${datadir}/${BPN}/sunstone-ipmi-inventory-sensors.yaml

}

FILES_${PN}-dev = " \
    ${datadir}/${BPN}/shale-ipmi-sensors.yaml \
    ${datadir}/${BPN}/shale-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/shale-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/shale-ipmi-inventory-sensors.yaml \
    ${datadir}/${BPN}/cinnabar-ipmi-sensors.yaml \
    ${datadir}/${BPN}/cinnabar-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/cinnabar-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/cinnabar-ipmi-inventory-sensors.yaml \
    ${datadir}/${BPN}/sunstone-ipmi-sensors.yaml \
    ${datadir}/${BPN}/sunstone-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/sunstone-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/sunstone-ipmi-inventory-sensors.yaml \
    "

ALLOW_EMPTY_${PN} = "1"
