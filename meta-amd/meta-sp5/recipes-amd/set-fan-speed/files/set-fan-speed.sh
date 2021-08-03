#!/bin/bash

set -e

# Fan Controller Dev ID
EMC2305_DEV=0x4D

#Speed Limit
SPEED_LIMIT=0X80

#Fan speed control Regs, for 1-5 fans
FAN_SET_REG=("0x30" "0x40" "0x50" "0x60" "0x70")
num_of_fans=${#FAN_SET_REG[@]}


# Read i2c bus list from i2cdetect cmd
mapfile -t i2c_bus_array < <( i2cdetect -l | grep i2c-9-mux | cut -c 5-6 | sort )

# Count no of i2c buses
num_of_i2c_bus=${#i2c_bus_array[@]}

# Read board_id from u-boot env
board_id=`/sbin/fw_printenv -n board_id`

# Onyx board
if [[ "$board_id" == "40" ]] || [[ "$board_id" == "41" ]] || [[ "$board_id" == "42" ]]; then
    num_of_fan_bus=4
elif [[ "$board_id" == "43" ]] || [[ "$board_id" == "44" ]] || [[ "$board_id" == "45" ]]; then
    num_of_fan_bus=5
elif [[ "$board_id" == "46" ]] || [[ "$board_id" == "47" ]] || [[ "$board_id" == "48" ]]; then
    num_of_fan_bus=5
elif [[ "$board_id" == "49" ]] || [[ "$board_id" == "4A" ]] || [[ "$board_id" == "4B" ]]; then
    num_of_fan_bus=5
else
	num_of_fan_bus=5
fi

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
    echo "Setting all Fan speeds to $speed_val"
    echo

    for ((i=0; i<${num_of_fan_bus}; i++));
    do
        for (( j=0; j <${num_of_fans}; j++));
        do
            i2cset -y ${i2c_bus_array[i]} $EMC2305_DEV ${FAN_SET_REG[j]} $speed_val
        done
    done
    exit 0
}

# Verify input speed is not below Limit val.
if [[ $1 -lt $SPEED_LIMIT ]]; then
    echo "Error : You can not set Fan speed less then 50% (0x80)"
    exit -1
else
    speed_val=$1
fi


sleep 10
while :
do
    # Check host power status, if 'off' then wait until power gets 'on'
    if [[ $(power_status) != "off" ]];
    then
        set_fan_speed
        exit 0
    else
        sleep 10
    fi
done
