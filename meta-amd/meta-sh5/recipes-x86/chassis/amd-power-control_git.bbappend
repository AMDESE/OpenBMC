DESCRIPTION_sh5 = "SOL start/stop with Host Power ON/Off for MI300A SH5 platform"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://0001-amd-power-control-modify-SOL-service-start-stop-add.patch"

