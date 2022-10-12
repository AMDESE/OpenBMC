FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

EXTRA_OEMESON_append_sp5 = " \
    -Dredfish-dump-log=enabled \
    -Dredfish-bmc-journal=enabled \
    -Dredfish-cpu-log=enabled \
    "
SRC_URI += "file://0001-Reset-server-settings-only-changes-to-invoke-CMOS.patch \
            file://0002-show-only-latest-boot-entries.patch \
            file://0003-added-cpuInfo-in-Redfish-API.patch \
            file://0004-increase-update-task-timeouts.patch \
            file://0005-Add-DIMM-info-to-Redfish-API.patch \
            file://0006-recipes-phosphor-bmcweb-Use-Amd-crashdump-interface.patch \
            file://0007-enable-power-cap-based-on-limit-value.patch \
            "

