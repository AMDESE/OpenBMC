FILESEXTRAPATHS_prepend_sp5 := "${THISDIR}/${PN}:"
EXTRA_OECONF_append_sp5 = " --enable-negative-errno-on-fail"


CHIPS_ONYX = " \
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

ENVS_ONYX = "obmc/hwmon_onyx/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_sp5 += " ${@compose_list(d, 'ENVS_ONYX', 'ITEMS_ONYX')}"

#TODO: add dynamic linking on future platform additions
do_install_append_sp5() {
  SOURCEDIR="${WORKDIR}/obmc/hwmon_onyx"
  DESTDIR="${D}${sysconfdir}/default/obmc/hwmon"
  install -d ${DESTDIR}
  cp -r ${SOURCEDIR}/* ${DESTDIR}
}
