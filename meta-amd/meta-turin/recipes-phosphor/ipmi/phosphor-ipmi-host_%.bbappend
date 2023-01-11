DEPENDS_append_turin = " turin-yaml-config"

EXTRA_OECONF_turin = " \
    GALENA_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/galena-ipmi-sensors.yaml \
    GALENA_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/galena-ipmi-fru-read.yaml \
    GALENA_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/galena-ipmi-inventory-sensors.yaml \
    CHALUPA_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/chalupa-ipmi-sensors.yaml \
    CHALUPA_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/chalupa-ipmi-fru-read.yaml \
    CHALUPA_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/chalupa-ipmi-inventory-sensors.yaml \
    PURICO_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/purico-ipmi-sensors.yaml \
    PURICO_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/purico-ipmi-fru-read.yaml \
    PURICO_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/purico-ipmi-inventory-sensors.yaml \
    VOLCANO_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/volcano-ipmi-sensors.yaml \
    VOLCANO_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/volcano-ipmi-fru-read.yaml \
    VOLCANO_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/turin-yaml-config/volcano-ipmi-inventory-sensors.yaml \
    enable_i2c_whitelist_check=no \
    "
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-turin-host-platform-changes.patch"
