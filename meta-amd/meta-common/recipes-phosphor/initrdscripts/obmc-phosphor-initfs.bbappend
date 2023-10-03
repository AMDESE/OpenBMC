FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
         file://amd-whitelist \
         file://obmc-init.sh \
         file://obmc-update.sh \
         "

do_install_append() {
    install -m 0644 ${WORKDIR}/amd-whitelist ${D}/amd-whitelist
}

FILES_${PN} += " /amd-whitelist "

