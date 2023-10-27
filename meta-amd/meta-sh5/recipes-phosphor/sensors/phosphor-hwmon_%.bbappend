FILESEXTRAPATHS_prepend_sh5 := "${THISDIR}/${PN}:"
EXTRA_OEMESON_append_sh5 = " -Dupdate-functional-on-fail=true -Dnegative-errno-on-fail=false"

SRC_URI += "file://0001-Add-power-on-monitor-mechanism.patch \
           "
# Onyx specific sensors
CHIPS_ONYX = " \
        bus@1e7a0000/i3c4@6000/sbtsi@4c,22400000001 \
        bus@1e7a0000/i3c4@6000/sbrmi@3c,22400000002 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@0/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@1/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@2/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@3/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@48 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@49 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4a \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4b \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4c \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4e \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4f \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@7/tmp468@48 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/core0socvrm@40 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/iovrm@41 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/core1vrm@42 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/vdd11susvrm@70 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/vdd33dualvrm@16 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/vdd18dualvrm@17 \
        "

# SH5D807 specific sensors
CHIPS_SH5D807 = " \
        bus@1e7a0000/i3c4@6000/sbtsi@4c,22400000001 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/vddcr_soc@36 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/vddcr_vdd0@3f \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/vddcr_vdd3@3c \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/vddcr_11_hbm_b@41 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/vdd_075_hbm_b@44 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@1/vddcr_vdd1@33 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@1/vddcr_vdd2@39 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@1/vddcr_11_hbm_d@47 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@1/vdd_075_hbm_d@4a \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@0/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@1/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@2/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@48 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@49 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4a \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4b \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4c \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4e \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4f \
         "
ITEMSFMT = "ahb/apb/{0}.conf"
ITEMS_ONYX = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_ONYX')}"
ITEMS_ONYX += "iio-hwmon-adc121c.conf"
ITEMS_SH5D807 = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_SH5D807')}"
ITEMS_SH5D807 += "iio-hwmon-adc121c.conf"

ENVS_ONYX = "obmc/hwmon_onyx/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_sh5 += " ${@compose_list(d, 'ENVS_ONYX', 'ITEMS_ONYX')}"
ENVS_SH5D807 = "obmc/hwmon_sh5d807/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_sh5 += " ${@compose_list(d, 'ENVS_SH5D807', 'ITEMS_SH5D807')}"
