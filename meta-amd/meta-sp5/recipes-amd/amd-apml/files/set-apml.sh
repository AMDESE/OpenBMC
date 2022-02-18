#!/bin/bash

# i2c BUS
DEV_I2C_2="/dev/i2c-2"
DEV_I2C_3="/dev/i2c-3"
I2C_BUS=2
I2C_MUX=0x70

# i3c bus
I3C_TOOL="/usr/bin/i3ctransfer"

# Set i2c APML
set_i2c_apml()
{
    echo "Setting I2C-2 Mux for CPU APML "
    i2cset -f -y $I2C_BUS $I2C_MUX 0x46 0x01 || retval=$?
    if [[ "$retval" -ne 0 ]]; then
        echo "Error: Setting I2C Mux Reg 0x46"
    fi
    i2cset -f -y $I2C_BUS $I2C_MUX 0x40 0x40 || retval=$?
    if [[ "$retval" -ne 0 ]]; then
        echo "Error: Setting I2C Mux Reg 0x40"
    fi
    i2cset -f -y $I2C_BUS $I2C_MUX 0x41 0x40 || retval=$?
    if [[ "$retval" -ne 0 ]]; then
        echo "Error: Setting I2C Mux Reg 0x46"
    fi
    if [ -a "$DEV_I2C_3" ]
    then
        echo "Setting I2C-3 Mux for CPU APML "
        I2C_BUS=3
        i2cset -f -y $I2C_BUS $I2C_MUX 0x46 0x01 || retval=$?
        if [[ "$retval" -ne 0 ]]; then
            echo "Error: Setting I2C Mux Reg 0x46"
        fi
        i2cset -f -y $I2C_BUS $I2C_MUX 0x40 0x40 || retval=$?
        if [[ "$retval" -ne 0 ]]; then
            echo "Error: Setting I2C Mux Reg 0x40"
        fi
        i2cset -f -y $I2C_BUS $I2C_MUX 0x41 0x40 || retval=$?
        if [[ "$retval" -ne 0 ]]; then
            echo "Error: Setting I2C Mux Reg 0x46"
        fi
    fi
}

# Set i3c APML
set_i3c_apml()
{
    echo "Setting I3C Mux for CPU APML "
}

# Main()
#---------

# check for i2c vs i3c
if [ -a "$DEV_I2C_2" ]
then
    set_i2c_apml
else
    set_i3c_apml
fi
