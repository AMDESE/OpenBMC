FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"
SRC_URI_append = " file://blocklist.json "

do_install_append() {
     rm -f ${D}/usr/share/entity-manager/configurations/*.json
     install -d ${D}/usr/share/entity-manager/configurations
     install -m 0444 ${WORKDIR}/blocklist.json ${D}/usr/share/entity-manager/configurations
}
