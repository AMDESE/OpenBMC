SUMMARY = "AMD/Lenovo Non Open Source Binaries"
DESCRIPTION = "Binaries to update PSOC on UBM Backplane"

LICENSE = "CLOSED"

DEPENDS = "systemd"

SRC_URI += "file://amd-bmc-bp-update \
            "
S="${WORKDIR}"

do_install() {
  install -d ${D}/${sbindir}
  install -m 0755 ${S}/amd-bmc-bp-update ${D}/${sbindir}/
}
