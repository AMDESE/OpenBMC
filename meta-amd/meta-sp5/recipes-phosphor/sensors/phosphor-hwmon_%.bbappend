FILESEXTRAPATHS_prepend_sp5 := "${THISDIR}/${PN}:"
EXTRA_OECONF_append_sp5 = " --enable-negative-errno-on-fail"

# Onyx specific sensors
CHIPS_ONYX = " \
        bus@1e78a000/i2c-bus@180/sbtsi@4c \
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
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/core0socvrm@40 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/iovrm@41 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/core1vrm@42 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/vdd11susvrm@70 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/vdd33dualvrm@16 \
        bus@1e78a000/i2c-bus@300/i2cswitch@71/i2c@0/vdd18dualvrm@17 \
        "

# Quartz specific sensors
CHIPS_QUARTZ = " \
        bus@1e78a000/i2c-bus@180/sbtsi@4c \
        bus@1e78a000/i2c-bus@200/sbtsi@48 \
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
        "

# Ruby specific sensors
CHIPS_RUBY = " \
        bus@1e78a000/i2c-bus@180/sbtsi@4c \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@0/emc2305@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@48 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@49 \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4a \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4b \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4c \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4d \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4e \
        bus@1e78a000/i2c-bus@500/i2cswitch@70/i2c@5/lm75a@4f \
        "

# Titanite specific sensors
CHIPS_TITANITE = " \
        bus@1e78a000/i2c-bus@180/sbtsi@4c \
        bus@1e78a000/i2c-bus@200/sbtsi@48 \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@0/i2cswitch@77/i2c@0/amd_cpld@28 \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@0/i2cswitch@77/i2c@3/lm75a@4b \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@1/lm75a@48 \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@1/lm75a@49 \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@1/lm75a@4a \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@1/lm75a@4b \
        bus@1e78a000/i2c-bus@500/i2cswitch@71/i2c@1/lm75a@4c \
        "
ITEMSFMT = "ahb/apb/{0}.conf"
ITEMS_ONYX = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_ONYX')}"
ITEMS_QUARTZ = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_QUARTZ')}"
ITEMS_RUBY = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_RUBY')}"
ITEMS_TITANITE = "${@compose_list(d, 'ITEMSFMT', 'CHIPS_TITANITE')}"


ENVS_ONYX = "obmc/hwmon_onyx/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_sp5 += " ${@compose_list(d, 'ENVS_ONYX', 'ITEMS_ONYX')}"
ENVS_QUARTZ = "obmc/hwmon_quartz/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_sp5 += " ${@compose_list(d, 'ENVS_QUARTZ', 'ITEMS_QUARTZ')}"
ENVS_RUBY = "obmc/hwmon_ruby/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_sp5 += " ${@compose_list(d, 'ENVS_RUBY', 'ITEMS_RUBY')}"
ENVS_TITANITE = "obmc/hwmon_titanite/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_sp5 += " ${@compose_list(d, 'ENVS_TITANITE', 'ITEMS_TITANITE')}"
