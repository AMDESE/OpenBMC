FILESEXTRAPATHS_prepend := "${THISDIR}/phosphor-dbus-interfaces:"

S = "${WORKDIR}/git"

SRC_URI += "file://0001-recipes-phosphor-dbus-Add-enumeration-SCM_FPGA-for-v.patch \
            file://0002-recipes-phosphor-dbus-Add-enumeration-HPM_FPGA-for.patch \
            file://0003-recipe-phosphor-dbus-interfaces-Adding-VR-Support.patch \
            file://0004-add-retimer-fw-update-support.patch \
            "

