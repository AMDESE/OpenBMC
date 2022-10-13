FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
PACKAGECONFIG_append = " associations"
EXTRA_OECONF_append = " --enable-associations=yes"
SRC_URI_append = " file://galena-associations.json \
                   file://recluse-associations.json \
                   file://purico-associations.json \
                   file://chalupa-associations.json \
                   file://huambo-associations.json \
                   file://volcano-associations.json \
                 "

DEPENDS_append = " phosphor-inventory-manager-chassis"

do_install_append() {
    install -d ${D}${base_datadir}
    install -m 0755 ${WORKDIR}/galena-associations.json ${D}${base_datadir}/galena-associations.json
    install -m 0755 ${WORKDIR}/recluse-associations.json ${D}${base_datadir}/recluse-associations.json
    install -m 0755 ${WORKDIR}/purico-associations.json ${D}${base_datadir}/purico-associations.json
    install -m 0755 ${WORKDIR}/chalupa-associations.json ${D}${base_datadir}/chalupa-associations.json
    install -m 0755 ${WORKDIR}/huambo-associations.json ${D}${base_datadir}/huambo-associations.json
    install -m 0755 ${WORKDIR}/volcano-associations.json ${D}${base_datadir}/volcano-associations.json
}
