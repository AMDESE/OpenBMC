DEPENDS_append_sp5 = " sp5-yaml-config"

EXTRA_OECONF_sp5 = " \
    ONYX_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/onyx-ipmi-sensors.yaml \
    ONYX_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/onyx-ipmi-fru-read.yaml \
    ONYX_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/onyx-ipmi-inventory-sensors.yaml \
    QUARTZ_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/quartz-ipmi-sensors.yaml \
    QUARTZ_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/quartz-ipmi-fru-read.yaml \
    QUARTZ_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/quartz-ipmi-inventory-sensors.yaml \
    RUBY_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/ruby-ipmi-sensors.yaml \
    RUBY_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/ruby-ipmi-fru-read.yaml \
    RUBY_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/ruby-ipmi-inventory-sensors.yaml \
    TITANITE_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/titanite-ipmi-sensors.yaml \
    TITANITE_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/titanite-ipmi-fru-read.yaml \
    TITANITE_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/titanite-ipmi-inventory-sensors.yaml \
    enable_i2c_whitelist_check=no \
    "
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-set-BIOS-boot-type-to-EFI.patch \
            file://0002-script-changes-for-mako-templates-and-platforms.patch \
            file://0003-platformization-changes-for-sp5-platforms.patch \
            file://0004-Add-Set-Sensor-threshold-IPMI-command.patch \
            "

