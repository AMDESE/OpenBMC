#!/bin/bash

# Read board_id from u-boot env
board_id=`/sbin/fw_printenv -n board_id`

set -e

# Fan Controller Dev ID
EMC2305_DEV=0x4D

#Speed Limit 20%
SPEED_LIMIT=0X32

#Fan speed control Regs, for 1-5 fans
FAN_SET_REG=("0x30" "0x40" "0x50" "0x60" "0x70")
num_of_fans=${#FAN_SET_REG[@]}

# Read i2c bus list from i2cdetect cmd
mapfile -t i2c_bus_array < <( i2cdetect -l | grep i2c-9-mux | cut -c 5-6 | sort )

# Count no of i2c buses
num_of_i2c_bus=${#i2c_bus_array[@]}

# Simply Hack it and default to 25 Fans
num_of_emc2305_controller=5

#existing no of emc2305 controller
curr_emc2305_ctrl=0;

fail=0

# Set all Fans speeds at argument passed by user
set_fan_speed()
{
    # Write speed value to emc2305 controller Regs.
    echo "Setting all Fan speeds to $speed_val pwm"
    for ((i=0; i<${num_of_emc2305_controller}; i++));
    do
        for (( j=0; j <${num_of_fans}; j++));
        do
            i2cset -f -y ${i2c_bus_array[i]} $EMC2305_DEV ${FAN_SET_REG[j]} $speed_val || retval=$?
        if [[ "$retval" -ne 0 ]]; then
            echo "Error: Setting fan speed failed or there is no Fan connected..."
            fail=1
            break
        fi
        done
    done
    if [[ $fail -eq 1 ]]; then
       curr_emc2305_ctrl=$((i-1))
    else
       curr_emc2305_ctrl=${i}
    fi

}

# Set all Pump fans at full speed
set_pump_fan_speed()
{
   speed_val=0xFF
   echo "Number of emc2305 controllers: ${curr_emc2305_ctrl}"
   if [[ $curr_emc2305_ctrl -eq 4 ]]; then
        # Set Onyx pump fan speed
        # Pump fan is on emc2305 controller# 3, fan#2
        echo "Setting Onyx Pump Fans at full speed...."
        i2cset -f -y ${i2c_bus_array[2]} $EMC2305_DEV ${FAN_SET_REG[1]} $speed_val
        if [ $? -ne 0 ]; then
            echo "Error: Setting Pump fan speed failed.."
        fi
   elif [[ $curr_emc2305_ctrl -eq 5 ]]; then
        # Set Quartz pump fan speed
        # Pump fan is on emc2305 controller# 5, fan# 4 & 5
        echo "Setting Quartz Pump Fans at full speed...."
        for (( j=3; j < 5; j++ ));
        do
            i2cset -f -y ${i2c_bus_array[4]} $EMC2305_DEV ${FAN_SET_REG[j]} $speed_val
            if [ $? -ne 0 ]; then
                echo "Error: Setting Pump fan speed failed.."
            fi
        done
   fi
}


# Main()
#---------

# Verify that input speed is not below Limit value.
if [[ $1 -lt $SPEED_LIMIT ]]; then
    echo "Error : You can not set Fan speed less then 20% (0x32)"
    exit -1
else
    speed_val=$1
fi

# Call functions to set Fan speeds
set_fan_speed
set_pump_fan_speed
