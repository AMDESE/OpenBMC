SUMMARY = "AMD EPYC System Management Interface Library"
DESCRIPTION = "AMD EPYC System Management Interface Library for user space APML implementation"

FILESEXTRAPATHS_prepend := "${THISDIR}:"

LICENSE = "CLOSED"

DEPENDS += "i2c-tools"

SRC_URI += "file://esmi-lib-1.0.0.tar.gz"

S="${WORKDIR}"

inherit cmake

do_install () {
        install -d ${D}${libdir}
        cp --preserve=mode,timestamps -R ${B}/libesmi_oob* ${D}${libdir}/

        install -d ${D}${bindir}
        install -m 0755 ${B}/esmi_oob_ex ${D}${bindir}/
        install -m 0755 ${B}/esmi_oob_tool ${D}${bindir}/

        install -d ${D}${includedir}
        install -m 0644 ${S}/include/esmi_oob/* ${D}${includedir}/
}
