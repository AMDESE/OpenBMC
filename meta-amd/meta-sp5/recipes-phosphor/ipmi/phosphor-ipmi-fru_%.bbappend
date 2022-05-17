inherit obmc-phosphor-systemd

DEPENDS_append_sp5 = " sp5-yaml-config"

EXTRA_OECONF_sp5 = " \
    ONYX_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/onyx-ipmi-fru-read.yaml \
    ONYX_PROP_YAML=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/onyx-ipmi-extra-properties.yaml \
    QUARTZ_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/quartz-ipmi-fru-read.yaml \
    QUARTZ_PROP_YAML=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/quartz-ipmi-extra-properties.yaml \
    RUBY_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/ruby-ipmi-fru-read.yaml \
    RUBY_PROP_YAML=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/ruby-ipmi-extra-properties.yaml \
    TITANITE_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/titanite-ipmi-fru-read.yaml \
    TITANITE_PROP_YAML=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/titanite-ipmi-extra-properties.yaml \
    "
FILESEXTRAPATHS_prepend_sp5 := "${THISDIR}/${PN}:"

EEPROM_NAMES = "motherboard"

#EEPROMFMT = "system/{0}"
#EEPROM_ESCAPEDFMT = "system-{0}"

EEPROMFMT = "system/chassis/{0}"
EEPROM_ESCAPEDFMT = "system-chassis-{0}"
EEPROMS = "${@compose_list(d, 'EEPROMFMT', 'EEPROM_NAMES')}"
EEPROMS_ESCAPED = "${@compose_list(d, 'EEPROM_ESCAPEDFMT', 'EEPROM_NAMES')}"

ENVFMT = "obmc/eeproms/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_sp5 := "${@compose_list(d, 'ENVFMT', 'EEPROMS')}"

TMPL = "obmc-read-eeprom@.service"
TGT = "multi-user.target"
INSTFMT = "obmc-read-eeprom@{0}.service"
FMT = "../${TMPL}:${TGT}.wants/${INSTFMT}"

SYSTEMD_LINK_${PN}_append_sp5 := "${@compose_list(d, 'FMT', 'EEPROMS_ESCAPED')}"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-python-template-changes-for-sp5.patch file://0002-platformization-changes-for-sp5-fru.patch"

