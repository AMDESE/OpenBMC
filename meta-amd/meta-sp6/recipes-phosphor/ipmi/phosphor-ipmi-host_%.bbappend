DEPENDS_append_sp6 = " sp6-yaml-config"

EXTRA_OECONF_sp6 = " \
    SHALE96_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/shale96-ipmi-sensors.yaml \
    SHALE96_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/shale96-ipmi-fru-read.yaml \
    SHALE96_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/shale96-ipmi-inventory-sensors.yaml \
    SHALE64_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/shale64-ipmi-sensors.yaml \
    SHALE64_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/shale64-ipmi-fru-read.yaml \
    SHALE64_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/shale64-ipmi-inventory-sensors.yaml \
    CINNABAR_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/cinnabar-ipmi-sensors.yaml \
    CINNABAR_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/cinnabar-ipmi-fru-read.yaml \
    CINNABAR_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/cinnabar-ipmi-inventory-sensors.yaml \
    SUNSTONE_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/sunstone-ipmi-sensors.yaml \
    SUNSTONE_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/sunstone-ipmi-fru-read.yaml \
    SUNSTONE_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/sunstone-ipmi-inventory-sensors.yaml \
    enable_i2c_whitelist_check=no \
    "
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-set-BIOS-boot-type-to-EFI.patch \
            file://0002-script-changes-for-mako-templates-and-platforms.patch \
            file://0003-platformization-changes-for-sp6-platforms.patch \
            file://0004-Add-Set-Sensor-threshold-IPMI-command.patch \
            "

