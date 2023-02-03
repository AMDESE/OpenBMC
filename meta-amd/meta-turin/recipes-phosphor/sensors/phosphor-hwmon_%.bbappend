FILESEXTRAPATHS_prepend_turin := "${THISDIR}/${PN}:"
EXTRA_OEMESON_append_turin = " -Dupdate-functional-on-fail=true -Dnegative-errno-on-fail=false"

SRC_URI += "file://0001-Add-power-on-monitor-mechanism.patch \
	   "
# Galena specific sensors
CHIPS_GALENA = " \
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

# Recluse specific sensors
CHIPS_RECLUSE = " \
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

# Chalupa specific sensors
CHIPS_CHALUPA = " \
        bus@1e7a0000/i3c4@6000/sbtsi@4c,22400000001 \
        bus@1e7a0000/i3c5@7000/sbtsi@48,22400000001 \
        bus@1e7a0000/i3c4@6000/sbrmi@3c,22400000002 \
        bus@1e7a0000/i3c5@7000/sbrmi@38,22400000002 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@0/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@1/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@2/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@3/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@4/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@48 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@49 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4a \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4b \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4c \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4e \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4f \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/p0_vdd_core0_run@60 \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/p0_vdd_core1_run@61 \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/p0_vdd_vddio_run@62 \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/p0_vdd_11_sus@63 \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/p0_vdd_18_dual@64 \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/p0_vdd_33_dual@65 \
        bus@1e78a000/i2c-bus@380/i2cswitch@70/i2c@0/p1_vdd_core0_run@60 \
        bus@1e78a000/i2c-bus@380/i2cswitch@70/i2c@0/p1_vdd_core1_run@61 \
        bus@1e78a000/i2c-bus@380/i2cswitch@70/i2c@0/p1_vdd_vddio_run@62 \
        bus@1e78a000/i2c-bus@380/i2cswitch@70/i2c@0/p1_vdd_11_sus@63 \
        bus@1e78a000/i2c-bus@380/i2cswitch@70/i2c@0/p1_vdd_18_dual@64 \
        bus@1e78a000/i2c-bus@380/i2cswitch@70/i2c@0/p1_vdd_33_dual@65 \
        "

# Purico specific sensors
CHIPS_PURICO = " \
        bus@1e7a0000/i3c4@6000/sbtsi@4c,22400000001 \
        bus@1e7a0000/i3c4@6000/sbrmi@3c,22400000002 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@0/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@48 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@49 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4a \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4b \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4c \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4e \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4f \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/vddcr_core0_soc@61 \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/vddcr_core1_11@62 \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/vddcr_vddio_33@63 \
        "

# Huambo specific sensors
CHIPS_HUAMBO = " \
        bus@1e7a0000/i3c4@6000/sbtsi@4c,22400000001 \
        bus@1e7a0000/i3c5@7000/sbtsi@48,22400000001 \
        bus@1e7a0000/i3c4@6000/sbrmi@3c,22400000002 \
        bus@1e7a0000/i3c5@7000/sbrmi@38,22400000002 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@0/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@1/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@2/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@3/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@4/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@48 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@49 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4a \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4b \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4c \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4e \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4f \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/p0_vdd_core0_run@60 \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/p0_vdd_core1_run@61 \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/p0_vdd_vddio_run@62 \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/p0_vdd_11_sus@63 \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/p0_vdd_18_dual@64 \
        bus@1e78a000/i2c-bus@300/i2cswitch@70/i2c@0/p0_vdd_33_dual@65 \
        bus@1e78a000/i2c-bus@380/i2cswitch@70/i2c@0/p1_vdd_core0_run@60 \
        bus@1e78a000/i2c-bus@380/i2cswitch@70/i2c@0/p1_vdd_core1_run@61 \
        bus@1e78a000/i2c-bus@380/i2cswitch@70/i2c@0/p1_vdd_vddio_run@62 \
        bus@1e78a000/i2c-bus@380/i2cswitch@70/i2c@0/p1_vdd_11_sus@63 \
        bus@1e78a000/i2c-bus@380/i2cswitch@70/i2c@0/p1_vdd_18_dual@64 \
        bus@1e78a000/i2c-bus@380/i2cswitch@70/i2c@0/p1_vdd_33_dual@65 \
        "

# Volcano specific sensors
CHIPS_VOLCANO = " \
        bus@1e7a0000/i3c4@6000/sbtsi@4c,22400000001 \
        bus@1e7a0000/i3c5@7000/sbtsi@48,22400000001 \
        bus@1e7a0000/i3c4@6000/sbrmi@3c,22400000002 \
        bus@1e7a0000/i3c5@7000/sbrmi@38,22400000002 \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@0/nct7362@20 \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@7/nct7362@20 \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@1/lm75a@48 \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@1/lm75a@49 \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@1/lm75a@4a \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@1/lm75a@4b \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@1/lm75a@4c \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@6/lm75a@4a \
        bus@1e78a000/i2c-bus@300/pvdd11_s3_p0@63 \
        bus@1e78a000/i2c-bus@300/pvddcr_soc_p0@61 \
        bus@1e78a000/i2c-bus@300/pvddio_p0@62 \
        bus@1e78a000/i2c-bus@380/pvdd11_s3_p1@74 \
        bus@1e78a000/i2c-bus@380/pvddcr_soc_p1@72 \
        bus@1e78a000/i2c-bus@380/pvddio_p1@75 \
        "

ITEMSFMT = "ahb/apb/{0}.conf"
ITEMS_GALENA = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_GALENA')}"
ITEMS_GALENA += "iio-hwmon-adc121c.conf"
ITEMS_RECLUSE = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_RECLUSE')}"
ITEMS_RECLUSE += "iio-hwmon-adc121c.conf"
ITEMS_CHALUPA = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_CHALUPA')}"
ITEMS_CHALUPA += "iio-hwmon-adc121c.conf"
ITEMS_PURICO = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_PURICO')}"
ITEMS_PURICO += "iio-hwmon-adc121c.conf"
ITEMS_HUAMBO = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_HUAMBO')}"
ITEMS_HUAMBO += "iio-hwmon-adc121c.conf"
ITEMS_VOLCANO = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_VOLCANO')}"
ITEMS_VOLCANO += "iio-hwmon-adc121c.conf"

ENVS_GALENA = "obmc/hwmon_galena/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_turin += " ${@compose_list(d, 'ENVS_GALENA', 'ITEMS_GALENA')}"
ENVS_RECLUSE = "obmc/hwmon_recluse/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_turin += " ${@compose_list(d, 'ENVS_RECLUSE', 'ITEMS_RECLUSE')}"
ENVS_CHALUPA = "obmc/hwmon_chalupa/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_turin += " ${@compose_list(d, 'ENVS_CHALUPA', 'ITEMS_CHALUPA')}"
ENVS_PURICO = "obmc/hwmon_purico/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_turin += " ${@compose_list(d, 'ENVS_PURICO', 'ITEMS_PURICO')}"
ENVS_HUAMBO = "obmc/hwmon_huambo/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_turin += " ${@compose_list(d, 'ENVS_HUAMBO', 'ITEMS_HUAMBO')}"
ENVS_VOLCANO = "obmc/hwmon_volcano/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_turin += " ${@compose_list(d, 'ENVS_VOLCANO', 'ITEMS_VOLCANO')}"

