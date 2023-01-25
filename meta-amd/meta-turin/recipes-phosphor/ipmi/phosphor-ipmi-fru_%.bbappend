inherit obmc-phosphor-systemd

DEPENDS_append_turin = "turin-yaml-config"

EXTRA_OECONF_turin = " \
    GALENA_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/galena-ipmi-fru-read.yaml \
    GALENA_PROP_YAML=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/galena-ipmi-extra-properties.yaml \
    RECLUSE_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/recluse-ipmi-fru-read.yaml \
    RECLUSE_PROP_YAML=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/recluse-ipmi-extra-properties.yaml \
    CHALUPA_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/chalupa-ipmi-fru-read.yaml \
    CHALUPA_PROP_YAML=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/chalupa-ipmi-extra-properties.yaml \
    PURICO_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/purico-ipmi-fru-read.yaml \
    PURICO_PROP_YAML=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/purico-ipmi-extra-properties.yaml \
    VOLCANO_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/volcano-ipmi-fru-read.yaml \
    VOLCANO_PROP_YAML=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/volcano-ipmi-extra-properties.yaml \
    HUAMBO_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/huambo-ipmi-fru-read.yaml \
    HUAMBO_PROP_YAML=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/huambo-ipmi-extra-properties.yaml \
    "
FILESEXTRAPATHS_prepend_turin := "${THISDIR}/${PN}:"

EEPROM_NAMES = "motherboard"

#EEPROMFMT = "system/{0}"
#EEPROM_ESCAPEDFMT = "system-{0}"

EEPROMFMT = "system/chassis/{0}"
EEPROM_ESCAPEDFMT = "system-chassis-{0}"
EEPROMS = "${@compose_list(d, 'EEPROMFMT', 'EEPROM_NAMES')}"
EEPROMS_ESCAPED = "${@compose_list(d, 'EEPROM_ESCAPEDFMT', 'EEPROM_NAMES')}"

ENVFMT = "obmc/eeproms/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_turin := "${@compose_list(d, 'ENVFMT', 'EEPROMS')}"

TMPL = "obmc-read-eeprom@.service"
TGT = "multi-user.target"
INSTFMT = "obmc-read-eeprom@{0}.service"
FMT = "../${TMPL}:${TGT}.wants/${INSTFMT}"

SYSTEMD_LINK_${PN}_append_turin := "${@compose_list(d, 'FMT', 'EEPROMS_ESCAPED')}"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-turin-fru-changes.patch"

