#!/bin/bash

set -e

# Controller Dev ID
EMC2305_DEV=0x4D

#Fan speed control Reg
FAN1_SET_REG=0x30
FAN2_SET_REG=0x40
FAN3_SET_REG=0x50
FAN4_SET_REG=0x60
FAN5_SET_REG=0x70

# Speed Limit
SPEED_LIMIT=0x80

# Check host power status
power_status() {
    st=$(busctl get-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis CurrentPowerState | cut -d"." -f6)
    if [[ "$st" == "On\"" ]]; then
        echo "on"
    else
        echo "off"
    fi
}


# Set Fan speeds
set_fan_speed()
{
    # Wrtie speed valu to controller Regs.
    echo "Setting all Fan speeds to $1"
    echo
    for i in 16 17 18 19
    do
        i2cset -y $i $EMC2305_DEV $FAN1_SET_REG $1
        i2cset -y $i $EMC2305_DEV $FAN2_SET_REG $1
        i2cset -y $i $EMC2305_DEV $FAN3_SET_REG $1
        i2cset -y $i $EMC2305_DEV $FAN4_SET_REG $1
        i2cset -y $i $EMC2305_DEV $FAN5_SET_REG $1
    done
    exit 0
}

# Verify input speed is not below Limit val.
if [[ $1 -lt $SPEED_LIMIT ]]; then
        echo "Error : You can not set Fan speed less then 50% (0x80)"
        exit -1
else
        SPEED_VAL=$1
fi


sleep 10
while :
do
    if [[ $(power_status) != "off" ]];
    then
        set_fan_speed
        exit 0
    else
        sleep 10
    fi
done



