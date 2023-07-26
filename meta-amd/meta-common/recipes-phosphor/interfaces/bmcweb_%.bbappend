FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

EXTRA_OEMESON_append = " \
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
            file://0008-To-display-Processors-information-using-redfish-API.patch \
            file://0009-bmcweb-Added-support-for-PPIN.patch \
            file://0010-recipes-bmcweb-Add-redfish-implementation-of-RAS-con.patch \
            file://0011-bmcweb-Removed-Power-cap-code-to-populate-CPU-Info.patch \
            file://0012-Redfish-Interface-for-crashdump-signature-ID.patch \
            file://0013-bmcweb-changes-to-support-vrbundle-update.patch \
            file://0014-Fixed-PostCodes-Entries-API-to-return-latest-Post-co.patch \
            file://0015-Add-socket-id-for-multi-host-support.patch \
            file://0016-Redfish-support-for-PCIe-Device.patch \
            file://0017-bmcweb-bmcweb-changes-to-return-error-message.patch \
            file://0018-bmcweb-Fixed-bmcweb-build-issue.patch \
            file://0019-redfish-ras-runtime-error-configuration.patch \
            "

