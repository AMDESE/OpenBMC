#!/bin/bash

set +e

BUS=$1
ADDR=$2
HEX_FILE=$3
MODEL_NUMBER=$4

echo "Renesas VR upgrade started at $(date)"

echo "$BUS $ADDR $HEX_FILE $MODEL_NUMBER "

if [ -e "$HEX_FILE" ];
then
    echo "Renesas VR update image is $HEX_FILE"
    #BUS=`find /sys/bus/i2c/drivers/isl68137/ -name "*$ADDR" -exec basename {} \; | cut -d- -f 1`
    DEVICE_NAME=`find /sys/bus/i2c/drivers/isl68137/ -name "$BUS-00$ADDR" -exec basename {} \;`
    echo "ADDR = $ADDR"
    echo "BUS  = $BUS"
    echo "DEVICE_NAME = $DEVICE_NAME"
    echo $DEVICE_NAME > /sys/bus/i2c/drivers/isl68137/unbind
    /usr/bin/renesas-vr-update $BUS $ADDR $HEX_FILE $MODEL_NUMBER
else
    echo "VR image $HEX_FILE doesn't exist"
fi

echo $DEVICE_NAME > /sys/bus/i2c/drivers/isl68137/bind
