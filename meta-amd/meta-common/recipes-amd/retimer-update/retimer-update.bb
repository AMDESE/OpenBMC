SUMMARY = "Aries retimer update"
DESCRIPTION = "Update application to program Aries PCIe retimer firmware"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

LICENSE = "CLOSED"
DEPENDS += "i2c-tools"

# Include aries sdk as-is with retimer-updater
SRC_URI = "file://aries-sdk-c.tar.gz"
SRC_URI += "file://retimer_update.c"

S="${WORKDIR}"

INSANE_SKIP_${PN} += "ldflags"

# Include only fw-update related modules from SDK
do_compile() {
    ${CC} -li2c -I examples/include \
                -I include retimer_update.c \
                 examples/source/aspeed.c \
                 source/aries_api.c \
                 source/aries_i2c.c \
                 source/aries_misc.c \
                 source/aries_bifurcation_params.c \
                 examples/source/misc.c \
                 examples/source/parse_ihx_file.c \
                 examples/source/eeprom.c \
                 source/astera_log.c \
                -o retimer_update
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 retimer_update ${D}${bindir}
}

