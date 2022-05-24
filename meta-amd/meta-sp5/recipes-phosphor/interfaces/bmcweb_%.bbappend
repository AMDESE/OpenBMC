FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

EXTRA_OEMESON_append_sp5 = " \
    -Dredfish-dump-log=enabled \
    -Dredfish-bmc-journal=enabled \
    "
SRC_URI += "file://0001-Reset-server-settings-only-changes-to-invoke-CMOS.patch \
            file://0002-show-only-latest-boot-entries.patch \
            file://0003-added-cpuInfo-in-Redfish-API.patch \
            "

