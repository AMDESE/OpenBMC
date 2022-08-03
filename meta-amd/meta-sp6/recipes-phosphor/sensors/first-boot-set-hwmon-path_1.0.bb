SUMMARY = "Setting Hwmon config path"
DESCRIPTION = "Setup Hwmon soft link for current platform"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit allarch systemd

SYSTEMD_SERVICE_${PN} = "first-boot-set-hwmon-path.service"

SRC_URI = "file://${BPN}.sh file://${BPN}.service"

S = "${WORKDIR}"

do_install() {
    sed "s/{MACHINE}/${MACHINE}/" -i ${BPN}.sh
    install -d ${D}${bindir} ${D}${systemd_system_unitdir}
    install ${BPN}.sh ${D}${bindir}/
    install -m 644 ${BPN}.service ${D}${systemd_system_unitdir}/
}