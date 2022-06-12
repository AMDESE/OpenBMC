#!/bin/bash

# VR upgrade

set +e

IMAGE_FILE=$1
BOARD=$2
CRC=''
UNBIND_DRIVER=0
echo "VR upgrade started at $(date)\n"


#Flashcp image to device.
if [ -e "$IMAGE_FILE" ];
then
    echo "VR image is $IMAGE_FILE"
    if [ "${IMAGE_FILE: -4}" == ".xsf" ];then
        ADDR=$3
        CRC=$4
        if ([ "$ADDR" == "13" ] || [ "$ADDR" == "14" ] || [ "$ADDR" == "15" ]); then
            BUS=4
        else
            UNBIND_DRIVER=1
        fi
    else
        ADDR=`grep "PMBus Address : " $IMAGE_FILE | awk '{print $4}'`
        ADDR=${ADDR:2}
        UNBIND_DRIVER=1
    fi

    if [ "$UNBIND_DRIVER" == "1" ] ; then
        BUS=`find /sys/bus/i2c/drivers/xdpe12284/ -name "*$ADDR" -exec basename {} \; | cut -d- -f 1`
        DEVICE_NAME=`find /sys/bus/i2c/drivers/xdpe12284/ -name "*$ADDR" -exec basename {} \;`
        echo $DEVICE_NAME > /sys/bus/i2c/drivers/xdpe12284/unbind
        echo "xdpe12284 driver is unbinded for VR telemetry to continue"
    fi

    if [ -z "$CRC" ] ; then
        /usr/bin/vr-update $BUS $ADDR $IMAGE_FILE "debug" -b $BOARD
    else
        /usr/bin/vr-update $BUS $ADDR $IMAGE_FILE "debug" -b $BOARD $CRC
    fi

    if [ "$?" -ne "0" ];
    then
        echo "VR upgrade has failed\n"
        exit -1
    else
        echo "VR upgrade has succeeded! Please AC cycle for the changes to take effect.\n"
    fi

else
    echo "VR image $IMAGE_FILE doesn't exist\n"
fi
popd

if [ "$UNBIND_DRIVER" == "1" ] ; then
    echo $DEVICE_NAME > /sys/bus/i2c/drivers/xdpe12284/bind
    echo "xdpe12284 driver is binded back after VR telemetry"
fi
