FILESEXTRAPATHS_prepend_sp6 := "${THISDIR}/${PN}:"
EXTRA_OECONF_append_sp6 = " --enable-negative-errno-on-fail"

SRC_URI += "file://0001-Add-power-on-monitor-mechanism.patch \
	   "
# Shale96 specific sensors
CHIPS_SHALE96 = " \
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
        "

# Shale64 specific sensors
CHIPS_SHALE64 = " \
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
        "

# Cinnabar specific sensors
CHIPS_CINNABAR = " \
        bus@1e7a0000/i3c4@6000/sbtsi@4c,22400000001 \
        bus@1e7a0000/i3c4@6000/sbrmi@3c,22400000002 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@0/emc2305_1_ap@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@48 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@49 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4a \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4b \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4c \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4e \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4f \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/p0_vdd_11_sus@62 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/p0_vdd_18_dual@64 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/p0_vdd_33_dual@65 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/p0_vdd_soc_run@61 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/p0_vdd_vddio_run@63 \
        "

# Sunstone specific sensors
CHIPS_SUNSTONE = " \
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
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/p0_vdd_soc_run@40 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/p0_vdd_vddio_run@41 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/p0_vdd_11_sus@42 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/p0_vdd_18_dual@17 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/p0_vdd_33_dual@16 \
        "

ITEMSFMT = "ahb/apb/{0}.conf"
ITEMS_SHALE96 = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_SHALE96')}"
ITEMS_SHALE96 += "iio-hwmon-adc121c.conf"
ITEMS_SHALE64 = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_SHALE64')}"
ITEMS_SHALE64 += "iio-hwmon-adc121c.conf"
ITEMS_CINNABAR = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_CINNABAR')}"
ITEMS_CINNABAR += "iio-hwmon-adc121c.conf"
ITEMS_SUNSTONE = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_SUNSTONE')}"
ITEMS_SUNSTONE += "iio-hwmon-adc121c.conf"

ENVS_SHALE96 = "obmc/hwmon_shale96/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_sp6 += " ${@compose_list(d, 'ENVS_SHALE96', 'ITEMS_SHALE96')}"
ENVS_SHALE64 = "obmc/hwmon_shale64/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_sp6 += " ${@compose_list(d, 'ENVS_SHALE64', 'ITEMS_SHALE64')}"
ENVS_CINNABAR = "obmc/hwmon_cinnabar/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_sp6 += " ${@compose_list(d, 'ENVS_CINNABAR', 'ITEMS_CINNABAR')}"
ENVS_SUNSTONE = "obmc/hwmon_sunstone/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_sp6 += " ${@compose_list(d, 'ENVS_SUNSTONE', 'ITEMS_SUNSTONE')}"

