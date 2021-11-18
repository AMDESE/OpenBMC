FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
PACKAGECONFIG_append = " associations"
EXTRA_OECONF_append = " --enable-associations=yes"
SRC_URI_append = " file://onyx-associations.json \
                   file://quartz-associations.json \
                   file://ruby-associations.json \
                   file://titanite-associations.json \
                 "

DEPENDS_append = " phosphor-inventory-manager-chassis"

do_install_append() {
    install -d ${D}${base_datadir}
    install -m 0755 ${WORKDIR}/onyx-associations.json ${D}${base_datadir}/onyx-associations.json
    install -m 0755 ${WORKDIR}/quartz-associations.json ${D}${base_datadir}/quartz-associations.json
    install -m 0755 ${WORKDIR}/ruby-associations.json ${D}${base_datadir}/ruby-associations.json
	install -m 0755 ${WORKDIR}/titanite-associations.json ${D}${base_datadir}/titanite-associations.json
}
