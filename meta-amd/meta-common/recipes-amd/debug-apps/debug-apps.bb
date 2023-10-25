SUMMARY = "Aspeed eSPI debug apps"
DESCRIPTION = "Aspeed debug applications to test espi controller"

FILESEXTRAPATHS_prepend := "${THISDIR}:"

LICENSE = "CLOSED"

DEPENDS += "systemd"
RDEPENDS_${PN} += "bash libsystemd"

inherit systemd

SRC_URI = "file://aspeed-espi.h  \
	file://perif-test.c \
	file://vw-test.c \
	file://oob-test.c \
	file://oob-pch-test.c \
	file://safs-test.c \
	file://mafs-test.c \
	file://sm-test.c \
	file://AMI_MG9100_001_Update_CFRU_S16_23_SATA.sh \
	file://mg9100test_RL20220323_1709 \
	file://ubm_fru_update \
	file://AMI_MG9100_001_ALL_PCIE.sh \
	file://get-Lenovo-bp-config.sh \
	file://set-Lenovo-fp-led.sh \
	file://safs-addr-translator.service \
	"

SYSTEMD_SERVICE_${PN} = "safs-addr-translator.service"

S = "${WORKDIR}"
INSANE_SKIP_${PN} += "ldflags already-stripped"

do_compile() {
	${CC} perif-test.c -o perif-test
	${CC} vw-test.c -o vw-test
	${CC} oob-test.c -o oob-test
	${CC} oob-pch-test.c -o oob-pch-test
	${CC} safs-test.c -o safs-test
	${CC} mafs-test.c -o mafs-test
	${CC} sm-test.c -o sm-test
}

do_install() {
	install -d ${D}${bindir}
	install -m 0755 perif-test ${D}${bindir}
	install -m 0755 vw-test ${D}${bindir}
	install -m 0755 oob-test ${D}${bindir}
	install -m 0755 oob-pch-test ${D}${bindir}
	install -m 0755 safs-test ${D}${bindir}
	install -m 0755 mafs-test ${D}${bindir}
	install -m 0755 sm-test ${D}${bindir}
	install -m 0755 AMI_MG9100_001_Update_CFRU_S16_23_SATA.sh ${D}${bindir}
	install -m 0755 mg9100test_RL20220323_1709 ${D}${bindir}
	install -m 0755 ubm_fru_update ${D}${bindir}
	install -m 0755 AMI_MG9100_001_ALL_PCIE.sh ${D}${bindir}
	install -m 0755 get-Lenovo-bp-config.sh ${D}${bindir}
	install -m 0755 set-Lenovo-fp-led.sh ${D}${bindir}
	install -d ${D}${systemd_unitdir}/system
	install -m 0644 ${WORKDIR}/safs-addr-translator.service ${D}${systemd_unitdir}/system
}
