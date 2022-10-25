#!/bin/bash

set +e

PROCESSOR=$1
ADDR=$2
BOARD=$4
CRC=$6

CRC_VALIDATION=0
if [ "$5" = "-c" ] ; then
    CRC_VALIDATION=1
    MODEL_NUMBER=$3
else
    HEX_FILE=$3
    MODEL_NUMBER=$5
fi

echo "Renesas VR upgrade started at $(date)"

echo "Processor = $PROCESSOR Address = $ADDR ModelNumber = $MODEL_NUMBER Board = $BOARD"
echo "VR update image file is = $HEX_FILE"

P0_retval=1
P1_retval=1

vr_update()
{
    retval=1
    BUS=$1
    DEVICE_NAME=`find /sys/bus/i2c/drivers/isl68137/ -name $BUS-00$ADDR -exec basename {} \;`
    echo "ADDR = $ADDR"
    echo "BUS  = $BUS"
    echo "DEVICE_NAME = $DEVICE_NAME"
    echo $DEVICE_NAME > /sys/bus/i2c/drivers/isl68137/unbind
    echo "isl68137 driver is unbinded for VR update to continue"

    if [ $CRC_VALIDATION == 1 ] ; then
        /usr/bin/vr-update $BUS $ADDR  $MODEL_NUMBER -b $BOARD -c $CRC
    else
        /usr/bin/vr-update $BUS $ADDR "$HEX_FILE" $MODEL_NUMBER -b $BOARD $CRC

        if [ "$?" -ne "0" ] ; then
            echo "VR upgrade has failed\n"
            retval=0
        else
            echo "VR upgrade has succeeded! Please AC cycle for the changes to take effect.\n"
        fi
    fi

    echo $DEVICE_NAME > /sys/bus/i2c/drivers/isl68137/bind
    echo "isl68137 driver is binded back after VR update"

    return "$retval"
}

PLAT=`amd-plat-info get_board_info name`

if [ "$PLAT" == "quartz" ] ; then

    echo "Quartz detected"

    BUS=`find /sys/bus/i2c/drivers/isl68137/ -name "*$ADDR" -exec basename {} \; | cut -d- -f 1`
    P1=${BUS:0:2}
    P0=${BUS:2:4}

    if [ $P0 -gt $P1 ] ; then
        tmp=$P0
        P0=$P1
        P1=$tmp
    fi

    if [ "$PROCESSOR" == "P0" ] ; then
        BUS=$P0
        vr_update $BUS
        P0_retval=$?

    elif [ "$PROCESSOR" == "P1" ] ; then
        BUS=$P1
        vr_update $BUS
        P1_retval=$?

    elif [ "$PROCESSOR" == "Px" ] ; then
        BUS=$P0
        vr_update $BUS
        P0_retval=$?
        BUS=$P1
        vr_update $BUS
        P1_retval=$?
    fi

    if ([ "$P0_retval" == 0 ]  || [ "$P1_retval" == 0 ]); then
        exit -1
    else
        exit 0
    fi

else

    BUS=`find /sys/bus/i2c/drivers/isl68137/ -name "*$ADDR" -exec basename {} \; | cut -d- -f 1`
    vr_update $BUS
    retval=$?

    if ([ "$retval" == 0 ]); then
        exit -1
    else
        exit 0
    fi
fi
