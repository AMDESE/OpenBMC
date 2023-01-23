#!/bin/bash

I2C_BUS=10
BP_MUX0=0x75
BP_MUX1=0x70
BP_MUX2=0x71
BP_PSOC=0x60

function i2c_set_mux()
{
    local I2C_ADDR=$1
    local I2C_DATA=$2
    i2cset -f -y $I2C_BUS $I2C_ADDR $I2C_DATA || retval=$?
    if [[ "$retval" -ne 0 ]]; then
        echo "Error: Setting I2C Addr= "  $I2C_ADDR
        exit 0
    fi
}

function i2c_set()
{
    local I2C_ADDR=$1
    local I2C_OFFSET=$2
    local I2C_DATA=$3
    i2cset -f -y $I2C_BUS $I2C_ADDR $I2C_OFFSET $I2C_DATA || retval=$?
    if [[ "$retval" -ne 0 ]]; then
        echo "Error: Setting I2C Addr= "  $I2C_ADDR
        exit 0
    fi
}

function i2c_get_psoc()
{
    local I2C_OFFSET=$1
    data=$(i2cget -f -y $I2C_BUS $BP_PSOC $I2C_OFFSET)
    printf "    Reg 0x%02x = %s \n" $I2C_OFFSET $data
}

i2c_set_mux $BP_MUX0 0x08

for port in 1 2 4
do
    echo "-------------------"
    echo "PSOC Registers for Port  " $port
    echo "-------------------"
    i2c_set_mux $BP_MUX1 $port

    i2c_set_mux $BP_MUX2 0x01
    for reg in {14..32}
    do
        i2c_get_psoc $reg
    done

    echo "-------------------"
    i2c_set_mux $BP_MUX2 0x02

    for reg in {14..32}
    do
        i2c_get_psoc $reg
    done
done
exit 0
