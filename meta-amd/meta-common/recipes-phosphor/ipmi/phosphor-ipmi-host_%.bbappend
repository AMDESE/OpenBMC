FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"


SRC_URI += "file://0001-set-BIOS-boot-type-to-EFI.patch \
            file://0002-Add-Set-Sensor-threshold-IPMI-command.patch \
           "
