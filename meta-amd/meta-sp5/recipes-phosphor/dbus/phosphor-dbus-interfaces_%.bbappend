FILESEXTRAPATHS_prepend := "${THISDIR}/phosphor-dbus-interfaces:"

S = "${WORKDIR}/git"

SRC_URI += "file://0001-recipes-phosphor-dbus-Add-enumeration-SCM_FPGA-for-v.patch \
	    file://0002-recipes-phosphor-dbus-Add-enumeration-HPM_FPGA-for.patch \
	    "

