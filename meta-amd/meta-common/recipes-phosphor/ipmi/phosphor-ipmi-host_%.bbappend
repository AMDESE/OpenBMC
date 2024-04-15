FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"


SRC_URI += "file://0001-set-BIOS-boot-type-to-EFI.patch \
            file://0002-Add-Set-Sensor-threshold-IPMI-command.patch \
            file://0003-Add-support-for-persistent-only-settings.patch \
            file://0004-Add-support-for-boot-initiator-mailbox.patch \
           "
