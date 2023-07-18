#!/bin/bash

# Read Board ID from u-boot env
boardID=`fw_printenv board_id | sed -n "s/^board_id=//p"`

case $boardID in
    "6A" | "72" | "73")  # purico board_ids
        echo "Purico, set LED "
        I2C_BUS=276
        IOX_ADDR=0x1B
    ;;
    "6B"| "74" | "75")  # volcano board_ids
        echo "Volcano, set LED "
        I2C_BUS=206
        IOX_ADDR=0x1B
    ;;
    *)  # Default exit
        exit
    ;;
esac

# Read Port Enable Register
port_read=$(i2cget -y $I2C_BUS $IOX_ADDR 0x03)
# Read Output Register
rg_read=$(i2cget -y $I2C_BUS $IOX_ADDR 0x01)
echo  "Port " $port_read " Reg " $rg_read

if [[ $1 == "id" ]];then
    portmask=0xFE
    if [[ $2 == "on" ]];then
        echo "ID LED On"
        bitmask=0x0E
    else
        echo "ID LED Off"
        bitmask=0x01
    fi
elif [[ $1 == "power" ]];then
    portmask=0xFD
    if [[ $2 == "on" ]];then
        echo "Power LED On"
        bitmask=0x0D
    else
        echo "Power LED Off"
        bitmask=0x02
    fi
elif [[ $1 == "atten" ]];then
    portmask=0xFB
    if [[ $2 == "on" ]];then
        echo "Attention LED On"
        bitmask=0x0B
    else
        echo "Attention LED Off"
        bitmask=0x04
    fi
elif [[ $1 == "network" ]];then
    portmask=0xF7
    if [[ $2 == "on" ]];then
        echo "Network LED On"
        bitmask=0x07
    else
        echo "Network LED Off"
        bitmask=0x08
    fi
else
    echo "set_fp_led.sh takes 2 strings as input"
    echo "1st string: "
    echo "    id      = set ID LED "
    echo "    power   = set Power LED "
    echo "    atten   = set Attention LED"
    echo "    network = set Network LED"
    echo "2nd string: "
    echo "    on      = Turn LED On "
    echo "    off     = Turn LED Off "
    exit
fi

port_write=$((port_read & portmask))
if [[ $2 == "on" ]];then
    rg_write=$((rg_read & bitmask))
else
    rg_write=$((rg_read | bitmask))
fi

echo "Write  Port " $port_write " Reg " $rg_write

i2cset -y $I2C_BUS $IOX_ADDR 0x03 $port_write
i2cset -y $I2C_BUS $IOX_ADDR 0x01 $rg_write

