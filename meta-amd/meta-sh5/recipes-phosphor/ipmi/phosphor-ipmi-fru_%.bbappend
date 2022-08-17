inherit obmc-phosphor-systemd

DEPENDS_append_sh5 = " sh5-yaml-config"

EXTRA_OECONF_sh5 = " \
    ONYX_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sh5-yaml-config/onyx-ipmi-fru-read.yaml \
    ONYX_PROP_YAML=${STAGING_DIR_HOST}${datadir}/sh5-yaml-config/onyx-ipmi-extra-properties.yaml \
    SH5D807_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sh5-yaml-config/sh5d807-ipmi-fru-read.yaml \
    SH5D807_PROP_YAML=${STAGING_DIR_HOST}${datadir}/sh5-yaml-config/sh5d807-ipmi-extra-properties.yaml \
    "
FILESEXTRAPATHS_prepend_sh5 := "${THISDIR}/${PN}:"

EEPROM_NAMES = "motherboard"

#EEPROMFMT = "system/{0}"
#EEPROM_ESCAPEDFMT = "system-{0}"

EEPROMFMT = "system/chassis/{0}"
EEPROM_ESCAPEDFMT = "system-chassis-{0}"
EEPROMS = "${@compose_list(d, 'EEPROMFMT', 'EEPROM_NAMES')}"
EEPROMS_ESCAPED = "${@compose_list(d, 'EEPROM_ESCAPEDFMT', 'EEPROM_NAMES')}"

ENVFMT = "obmc/eeproms/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_sh5 := "${@compose_list(d, 'ENVFMT', 'EEPROMS')}"

TMPL = "obmc-read-eeprom@.service"
TGT = "multi-user.target"
INSTFMT = "obmc-read-eeprom@{0}.service"
FMT = "../${TMPL}:${TGT}.wants/${INSTFMT}"

SYSTEMD_LINK_${PN}_append_sh5 := "${@compose_list(d, 'FMT', 'EEPROMS_ESCAPED')}"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-python-template-changes-for-sh5.patch \
            file://0002-phosphor-ipmi-fru-Add-platform-based-fru-data-selection.patch \
           "

