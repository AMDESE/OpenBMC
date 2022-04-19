#!/bin/bash

set +e

PROCESSOR=$1
ADDR=$2
BOARD=$4

if [ "$5" = "-c" ] ; then
    MODEL_NUMBER=$3
    CRC_VALUE=$6
else
    HEX_FILE=$3
    MODEL_NUMBER=`echo $HEX_FILE | cut -d- -f1 | cut -c3-`
fi

echo "Renesas VR upgrade started at $(date)"

echo "$PROCESSOR $ADDR $HEX_FILE $MODEL_NUMBER $BOARD"

echo "Renesas VR update image is $HEX_FILE"
PLAT=`amd-plat-info get_board_info name`
if [ "$PLAT" == "titanite" ] ; then
    echo "Titanite detected"
    if [ "$PROCESSOR" == "P0" ] ; then
        BUS=5
    elif [ "$PROCESSOR" == "P1" ] ; then
        BUS=6
    fi
    MODEL_NUMBER="RAA229620"

    /usr/bin/vr-update $BUS $ADDR $HEX_FILE $MODEL_NUMBER -b $BOARD
    if [ "$?" -ne "0" ];
    then
        echo "VR upgrade has failed\n"
        exit -1
    else
        echo "VR upgrade has succeeded! Please AC cycle for the changes to take effect.\n"
    fi
    exit 0
fi
BUS=`find /sys/bus/i2c/drivers/isl68137/ -name "*$ADDR" -exec basename {} \; | cut -d- -f 1`
P0=${BUS:0:2}
P1=${BUS:2:4}
if [ $P0 -gt $P1 ] ; then
    tmp=$P0
    P0=$P1
    P1=$tmp
fi

if [ "$PROCESSOR" == "P0" ] ; then
    BUS=$P0
elif [ "$PROCESSOR" == "P1" ] ; then
    BUS=$P1
else
    echo "Not a valid bus number"
    exit -1
fi
DEVICE_NAME=`find /sys/bus/i2c/drivers/isl68137/ -name $BUS-00$ADDR -exec basename {} \;`
echo "ADDR = $ADDR"
echo "BUS  = $BUS"
echo "DEVICE_NAME = $DEVICE_NAME"
echo $DEVICE_NAME > /sys/bus/i2c/drivers/isl68137/unbind
echo "isl68137 driver is unbinded for VR update to continue"

if [ "$5" = "-c" ] ; then
    /usr/bin/vr-update $BUS $ADDR  $MODEL_NUMBER -b $BOARD -c $CRC_VALUE
else
    /usr/bin/vr-update $BUS $ADDR $HEX_FILE $MODEL_NUMBER -b $BOARD
    if [ "$?" -ne "0" ];
    then
        echo "VR upgrade has failed\n"
        exit -1
    else
        echo "VR upgrade has succeeded! Please AC cycle for the changes to take effect.\n"
    fi
fi

echo $DEVICE_NAME > /sys/bus/i2c/drivers/isl68137/bind
echo "isl68137 driver is binded back after VR update"
