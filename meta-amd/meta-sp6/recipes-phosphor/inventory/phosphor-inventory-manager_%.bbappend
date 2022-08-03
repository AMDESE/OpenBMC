FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
PACKAGECONFIG_append = " associations"
EXTRA_OECONF_append = " --enable-associations=yes"
SRC_URI_append = " file://shale96-associations.json \
                   file://shale64-associations.json \
                   file://cinnabar-associations.json \
                   file://sunstone-associations.json \
                 "

DEPENDS_append = " phosphor-inventory-manager-chassis"

do_install_append() {
    install -d ${D}${base_datadir}
    install -m 0755 ${WORKDIR}/shale96-associations.json ${D}${base_datadir}/shale96-associations.json
    install -m 0755 ${WORKDIR}/shale64-associations.json ${D}${base_datadir}/shale64-associations.json
    install -m 0755 ${WORKDIR}/cinnabar-associations.json ${D}${base_datadir}/cinnabar-associations.json
	install -m 0755 ${WORKDIR}/sunstone-associations.json ${D}${base_datadir}/sunstone-associations.json
}
