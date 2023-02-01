DEPENDS_append_sh5 = " sh5-yaml-config"

EXTRA_OECONF_sh5 = " \
    ONYX_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sh5-yaml-config/onyx-ipmi-sensors.yaml \
    ONYX_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sh5-yaml-config/onyx-ipmi-fru-read.yaml \
    ONYX_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sh5-yaml-config/onyx-ipmi-inventory-sensors.yaml \
    SH5D807_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sh5-yaml-config/sh5d807-ipmi-sensors.yaml \
    SH5D807_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sh5-yaml-config/sh5d807-ipmi-fru-read.yaml \
    SH5D807_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sh5-yaml-config/sh5d807-ipmi-inventory-sensors.yaml \
    enable_i2c_whitelist_check=no \
    "
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-script-changes-for-mako-templates-and-platforms.patch \
            file://0002-phosphor-ipmi-host-Modify-platformization-changes-for-sh5.patch \
            "

