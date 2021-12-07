#!/bin/bash

# VR upgrade

set +e

IMAGE_FILE=$1

echo "VR upgrade started at $(date)\n"

#Flashcp image to device.
if [ -e "$IMAGE_FILE" ];
then
    echo "VR image is $IMAGE_FILE"
    ADDR=`grep "PMBus Address : " $IMAGE_FILE | awk '{print $4}'`
    BUS=`find /sys/bus/i2c/drivers/xdpe12284/ -name "*$ADDR" -exec basename {} \; | cut -d- -f 1`
    DEVICE_NAME=`find /sys/bus/i2c/drivers/xdpe12284/ -name "*$ADDR" -exec basename {} \;`
    echo $DEVICE_NAME > /sys/bus/i2c/drivers/xdpe12284/unbind
    /usr/bin/infineon-vr-update $BUS $ADDR $IMAGE_FILE
    if [ "$?" -ne "0" ];
    then
        echo "VR upgrade has failed\n"
        exit 1
    else
        echo "VR upgrade has succeeded! Please AC cycle for the changes to take effect.\n"
    fi

else
    echo "VR image $IMAGE_FILE doesn't exist\n"
fi
popd
echo $DEVICE_NAME > /sys/bus/i2c/drivers/xdpe12284/bind
