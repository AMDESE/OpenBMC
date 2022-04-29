DEPENDS_append_sp5 = " sp5-yaml-config"

EXTRA_OECONF_sp5 = " \
    SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/ipmi-sensors.yaml \
    FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/ipmi-fru-read.yaml \
    INVSENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/sp5-yaml-config/ipmi-inventory-sensors.yaml \
    enable_i2c_whitelist_check=no \
    "
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-set-BIOS-boot-type-to-EFI.patch"

