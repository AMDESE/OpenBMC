FILESEXTRAPATHS_prepend := "${THISDIR}/phosphor-dbus-interfaces:"

S = "${WORKDIR}/git"

SRC_URI += "file://0001-recipes-phosphor-dbus-Add-enumeration-SCM_FPGA-for-v.patch \
            file://0002-recipes-phosphor-dbus-Add-enumeration-HPM_FPGA-for.patch \
            file://0003-recipe-phosphor-dbus-interfaces-Adding-VR-Support.patch \
            file://0004-add-retimer-fw-update-support.patch \
            file://0005-New-DBus-property-has-been-added-for-CPU-info.patch \
            file://0006-recipes-phosphor-dbus-Add-DIMM-Info-param.patch \
            file://0007-recipe-phosphor-dbus-Added-processor-DBus-property.patch \
            file://0008-phosphor-dbus-interfaces-Added-PPIN-entry.patch \
            file://0009-Power-cap-CPUID1-and-CPUID2-will-not-be-used-for-CPU.patch \
            file://0010-Added-configuration-for-VR-Bundle-Update.patch \
            file://0011-add-support-for-bp-fw-update.patch \
            file://0012-Added-Present-property-to-check-processor-present.patch \
            file://0013-Add-a-new-Post-Package-Repair-Interface.patch \
            file://0014-phosphor-dbus-interfaces-Made-PprData-to-return-Arra.patch \
            "

do_configure_append() {
  cd ${S}/gen && ./regenerate-meson
}
