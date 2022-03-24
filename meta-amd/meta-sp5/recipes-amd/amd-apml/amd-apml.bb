SUMMARY = "AMD EPYC System Management Interface Library"
DESCRIPTION = "AMD EPYC System Management Interface Library for user space APML implementation"

FILESEXTRAPATHS_prepend := "${THISDIR}:"

LICENSE = "CLOSED"

DEPENDS += "i2c-tools"
DEPENDS += "i3c-tools"
RDEPENDS_${PN} += "bash"

SRC_URI += "git://gerrit-git.amd.com:29418/SYS-MGMT/er/HPC/e_sb_smi_lib;branch=amd-dev;protocol=ssh"
SRC_URI += "file://0001-amd-apml-Enable-esmi-oob-library-with-i3c.patch \
            "
SRCREV_pn-amd-apml = "6e0c40b57db70168bb7ca215df910bd35333d4a9"

S="${WORKDIR}/git"

inherit cmake

do_install () {
        install -d ${D}${libdir}
        cp --preserve=mode,timestamps -R ${B}/libesmi_oob* ${D}${libdir}/

        install -d ${D}${bindir}
        install -m 0755 ${B}/esmi_oob_ex ${D}${bindir}/
        install -m 0755 ${B}/esmi_oob_tool ${D}${bindir}/
        install -m 0755 ${S}/scripts/set-apml.sh ${D}${bindir}/

        install -d ${D}${includedir}
        install -m 0644 ${S}/include/esmi_oob/* ${D}${includedir}/
}
