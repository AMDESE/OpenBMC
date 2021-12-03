FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-Reset-server-settings-only-changes-to-invoke-CMOS.patch \
            file://0002-show-only-latest-boot-entries.patch \
            "

