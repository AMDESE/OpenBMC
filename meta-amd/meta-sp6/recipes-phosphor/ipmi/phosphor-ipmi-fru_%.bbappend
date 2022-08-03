inherit obmc-phosphor-systemd

DEPENDS_append_sp6 = " sp6-yaml-config"

EXTRA_OECONF_sp6 = " \
    SHALE96_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/shale96-ipmi-fru-read.yaml \
    SHALE96_PROP_YAML=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/shale96-ipmi-extra-properties.yaml \
    SHALE64_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/shale64-ipmi-fru-read.yaml \
    SHALE64_PROP_YAML=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/shale64-ipmi-extra-properties.yaml \
    CINNABAR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/cinnabar-ipmi-fru-read.yaml \
    CINNABAR_PROP_YAML=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/cinnabar-ipmi-extra-properties.yaml \
    SUNSTONE_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/sunstone-ipmi-fru-read.yaml \
    SUNSTONE_PROP_YAML=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/sunstone-ipmi-extra-properties.yaml \
    "
FILESEXTRAPATHS_prepend_sp6 := "${THISDIR}/${PN}:"

EEPROM_NAMES = "motherboard"

#EEPROMFMT = "system/{0}"
#EEPROM_ESCAPEDFMT = "system-{0}"

EEPROMFMT = "system/chassis/{0}"
EEPROM_ESCAPEDFMT = "system-chassis-{0}"
EEPROMS = "${@compose_list(d, 'EEPROMFMT', 'EEPROM_NAMES')}"
EEPROMS_ESCAPED = "${@compose_list(d, 'EEPROM_ESCAPEDFMT', 'EEPROM_NAMES')}"

ENVFMT = "obmc/eeproms/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_sp6 := "${@compose_list(d, 'ENVFMT', 'EEPROMS')}"

TMPL = "obmc-read-eeprom@.service"
TGT = "multi-user.target"
INSTFMT = "obmc-read-eeprom@{0}.service"
FMT = "../${TMPL}:${TGT}.wants/${INSTFMT}"

SYSTEMD_LINK_${PN}_append_sp6 := "${@compose_list(d, 'FMT', 'EEPROMS_ESCAPED')}"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-python-template-changes-for-sp6.patch file://0002-platformization-changes-for-sp6-fru.patch"

