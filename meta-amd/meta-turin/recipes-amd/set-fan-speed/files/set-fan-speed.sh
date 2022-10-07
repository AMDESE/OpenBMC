#!/bin/bash

set -e

# Fan Controller Dev ID
EMC2305_DEV=0x4D
CPLD_DEV=0x28

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
   if [[ $curr_emc2305_ctrl -eq 4 ]]; then
        # Set Turin-1P pump fan speed
        # Pump fan is on emc2305 controller# 3, fan#4
        echo "Setting Turin-1P Pump Fans at full speed.... " $speed_val
        i2cset -f -y ${i2c_bus_array[2]} $EMC2305_DEV ${FAN_SET_REG[3]} $speed_val
        if [ $? -ne 0 ]; then
            echo "Error: Setting Pump fan speed failed.."
        fi
   elif [[ $curr_emc2305_ctrl -eq 5 ]]; then
        # Set Turin-2P pump fan speed
        # Pump fan is on emc2305 controller# 5, fan# 4 & 5
        echo "Setting Turin-2P Pump Fans at full speed.... " $speed_val
        for (( j=3; j < 5; j++ ));
        do
            i2cset -f -y ${i2c_bus_array[4]} $EMC2305_DEV ${FAN_SET_REG[j]} $speed_val
            if [ $? -ne 0 ]; then
                echo "Error: Setting Pump fan speed failed.."
            fi
        done
   fi
}

set_cpld_fan_speed()
{
    #Fan speed control Regs 6 fans
    CPLD_FAN_SET_REG=("0x18" "0x19" "0x1A" "0x1B" "0x1C" "0x1D")
    cpld_num_of_pwms=${#CPLD_FAN_SET_REG[@]}
    echo " Num of pwms = ${cpld_num_of_pwms}"
    # Get the CPLD i2c bus number
    cpld_i2c_bus_num=`find /sys/bus/i2c/drivers | grep cpld| grep 0028 | cut -d"/" -f 7 | cut -d"-" -f 1`
    echo "cpld i2c bus num = ${cpld_i2c_bus_num}"

    # Write speed value to CPLD controller Regs.
    # Set speed to 30% pwm, (CPLD range 0 to 100 %)
    pwm_val=30
    echo "Setting all Huambo Fan speeds to $pwm_val pwm"
    for ((i=0; i<${cpld_num_of_pwms}; i++));
    do
        i2cset -f -y ${cpld_i2c_bus_num} $CPLD_DEV ${CPLD_FAN_SET_REG[i]} $pwm_val || retval=$?
        if [[ "$retval" -ne 0 ]]; then
            echo "Error: Setting fan speed failed or there is no Fan connected..."
            break
        fi
    done
}


# Main()
#---------

# Read board_id from u-boot env
board_id=`fw_printenv board_id | sed -n "s/^board_id=//p"`
echo "board_id = ${board_id}"

if [[ $board_id == "67" ]]; then
    set_cpld_fan_speed
else
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
fi
