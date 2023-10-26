#!/bin/bash

set -e

# Fan Controller Dev ID
EMC2305_DEV=0x4D

#Speed Limit 20% (Range 0x0 to 0xFF)
SPEED_LIMIT=0x32

#Fan speed control Regs, for 1-5 fans
FAN_SET_REG=("0x30" "0x40" "0x50" "0x60" "0x70")
num_of_fans=${#FAN_SET_REG[@]}

# Read i2c bus list from i2cdetect cmd
mapfile -t i2c_bus_array < <(find /sys/bus/i2c/drivers | grep emc2301 | grep 004d | cut -d"/" -f 7 | cut -d"-" -f 1 | sort)

# Get the number of emc2305 controllers
num_of_emc2305_controller=${#i2c_bus_array[@]}

#existing no of emc2305 controller
curr_emc2305_ctrl=0;

# Set all Fans speeds at argument passed by user
set_emc2305_fan_speed()
{
    echo "Number of emc2305 controller = ${num_of_emc2305_controller}"
    # Write speed value to emc2305 controller Regs.
    echo "Setting all Fan speeds to $speed_val pwm"
    for ((i=0; i<${num_of_emc2305_controller}; i++));
    do
        for (( j=0; j <${num_of_fans}; j++));
        do
            i2cset -f -y ${i2c_bus_array[i]} $EMC2305_DEV ${FAN_SET_REG[j]} $speed_val || retval=$?
        if [[ "$retval" -ne 0 ]]; then
            echo "Error: Setting fan speed failed or there is no Fan connected..."
            break
        fi
        done
    done

    curr_emc2305_ctrl=${i}
}

# Set all Pump fans at full speed
set_emc2305_pump_fan_speed()
{
   speed_val=0xFF
   if [[ $curr_emc2305_ctrl -eq 3 ]]; then
        # Set SH5 pump fan speed
        # Pump fan is on emc2305 controller# 3
        echo "Setting SH5 Pump Fans at full speed...."
        i2cset -f -y ${i2c_bus_array[2]} $EMC2305_DEV ${FAN_SET_REG[1]} $speed_val
        if [ $? -ne 0 ]; then
            echo "Error: Setting Pump fan speed failed.."
        fi
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

# Call functions to set EMC2305  Fan speeds
set_emc2305_fan_speed
set_emc2305_pump_fan_speed
