SUMMARY = "YAML configuration for turin"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit allarch

SRC_URI = " \
    file://galena-ipmi-sensors.yaml \
    file://galena-ipmi-fru.yaml  \
    file://galena-ipmi-fru-properties.yaml  \
    file://galena-ipmi-inventory-sensors.yaml  \
    file://recluse-ipmi-sensors.yaml  \
    file://recluse-ipmi-fru-properties.yaml  \
    file://recluse-ipmi-fru.yaml   \
    file://recluse-ipmi-inventory-sensors.yaml  \
    file://purico-ipmi-sensors.yaml  \
    file://purico-ipmi-fru.yaml  \
    file://purico-ipmi-fru-properties.yaml  \
    file://purico-ipmi-inventory-sensors.yaml  \
    file://chalupa-ipmi-sensors.yaml  \
    file://chalupa-ipmi-fru-properties.yaml  \
    file://chalupa-ipmi-fru.yaml  \
    file://chalupa-ipmi-inventory-sensors.yaml  \
    file://huambo-ipmi-sensors.yaml  \
    file://huambo-ipmi-fru.yaml  \
    file://huambo-ipmi-fru-properties.yaml  \
    file://huambo-ipmi-inventory-sensors.yaml  \
    file://volcano-ipmi-sensors.yaml  \
    file://volcano-ipmi-fru.yaml  \
    file://volcano-ipmi-fru-properties.yaml  \
    file://volcano-ipmi-inventory-sensors.yaml  \
    "

S = "${WORKDIR}"

do_install() {
    cat galena-ipmi-fru.yaml > fru-read.yaml
    install -m 0644 -D galena-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/galena-ipmi-extra-properties.yaml
    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/galena-ipmi-fru-read.yaml
    install -m 0644 -D galena-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/galena-ipmi-sensors.yaml
    install -m 0644 -D galena-ipmi-inventory-sensors.yaml \
        ${D}${datadir}/${BPN}/galena-ipmi-inventory-sensors.yaml
    cat recluse-ipmi-fru.yaml > fru-read.yaml
    install -m 0644 -D recluse-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/recluse-ipmi-extra-properties.yaml
    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/recluse-ipmi-fru-read.yaml
    install -m 0644 -D recluse-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/recluse-ipmi-sensors.yaml
    install -m 0644 -D recluse-ipmi-inventory-sensors.yaml \
        ${D}${datadir}/${BPN}/recluse-ipmi-inventory-sensors.yaml
    cat purico-ipmi-fru.yaml > fru-read.yaml
    install -m 0644 -D purico-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/purico-ipmi-extra-properties.yaml
    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/purico-ipmi-fru-read.yaml
    install -m 0644 -D purico-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/purico-ipmi-sensors.yaml
    install -m 0644 -D purico-ipmi-inventory-sensors.yaml \
        ${D}${datadir}/${BPN}/purico-ipmi-inventory-sensors.yaml
    cat chalupa-ipmi-fru.yaml > fru-read.yaml
    install -m 0644 -D chalupa-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/chalupa-ipmi-extra-properties.yaml
    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/chalupa-ipmi-fru-read.yaml
    install -m 0644 -D chalupa-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/chalupa-ipmi-sensors.yaml
    install -m 0644 -D chalupa-ipmi-inventory-sensors.yaml \
        ${D}${datadir}/${BPN}/chalupa-ipmi-inventory-sensors.yaml
    cat huambo-ipmi-fru.yaml > fru-read.yaml
    install -m 0644 -D huambo-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/huambo-ipmi-extra-properties.yaml
    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/huambo-ipmi-fru-read.yaml
    install -m 0644 -D huambo-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/huambo-ipmi-sensors.yaml
    install -m 0644 -D huambo-ipmi-inventory-sensors.yaml \
        ${D}${datadir}/${BPN}/huambo-ipmi-inventory-sensors.yaml
    cat volcano-ipmi-fru.yaml > fru-read.yaml
    install -m 0644 -D volcano-ipmi-fru-properties.yaml \
        ${D}${datadir}/${BPN}/volcano-ipmi-extra-properties.yaml
    install -m 0644 -D fru-read.yaml \
        ${D}${datadir}/${BPN}/volcano-ipmi-fru-read.yaml
    install -m 0644 -D volcano-ipmi-sensors.yaml \
        ${D}${datadir}/${BPN}/volcano-ipmi-sensors.yaml
    install -m 0644 -D volcano-ipmi-inventory-sensors.yaml \
        ${D}${datadir}/${BPN}/volcano-ipmi-inventory-sensors.yaml

}

FILES_${PN}-dev = " \
    ${datadir}/${BPN}/galena-ipmi-sensors.yaml \
    ${datadir}/${BPN}/galena-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/galena-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/galena-ipmi-inventory-sensors.yaml \
    ${datadir}/${BPN}/recluse-ipmi-sensors.yaml \
    ${datadir}/${BPN}/recluse-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/recluse-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/recluse-ipmi-inventory-sensors.yaml \
    ${datadir}/${BPN}/purico-ipmi-sensors.yaml \
    ${datadir}/${BPN}/purico-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/purico-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/purico-ipmi-inventory-sensors.yaml \
    ${datadir}/${BPN}/chalupa-ipmi-sensors.yaml \
    ${datadir}/${BPN}/chalupa-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/chalupa-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/chalupa-ipmi-inventory-sensors.yaml \
    ${datadir}/${BPN}/huambo-ipmi-sensors.yaml \
    ${datadir}/${BPN}/huambo-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/huambo-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/huambo-ipmi-inventory-sensors.yaml \
    ${datadir}/${BPN}/volcano-ipmi-sensors.yaml \
    ${datadir}/${BPN}/volcano-ipmi-extra-properties.yaml \
    ${datadir}/${BPN}/volcano-ipmi-fru-read.yaml \
    ${datadir}/${BPN}/volcano-ipmi-inventory-sensors.yaml \
    "

ALLOW_EMPTY_${PN} = "1"
