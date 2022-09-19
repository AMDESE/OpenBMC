DEPENDS_append_sp6 = " sp6-yaml-config"

EXTRA_OECONF_sp6 = " \
    SHALE_SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/shale-ipmi-sensors.yaml \
    SHALE_FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/shale-ipmi-fru-read.yaml \
    SHALE_INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp6-yaml-config/shale-ipmi-inventory-sensors.yaml \
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
            file://0005-Merge-shale64-and-shale96-platforms.patch \
            "

