#!/bin/bash

set +e

# Read Board ID from u-boot env
boardID=`fw_printenv board_id | sed -n "s/^board_id=//p"`
revID=`hexdump -c /sys/bus/i2c/devices/7-0050/eeprom -s 24 -n 1 | head -n 1| awk '{ print $2}'`
case $boardID in
   "3D"|"40"|"41"|"42"|"52")  # Onyx board_ids
        echo "Retimer update not supported for Onyx"
   ;;
   "3E"|"43"|"44"|"45"|"51")  # Quartz board_ids
        echo "Retimer update not supported for Quartz"
   ;;
   "46"|"47"|"48")  # Ruby board_ids
        echo "Retimer update not supported for Ruby"
   ;;
   "49"|"4A"|"4B"|"4C"|"4D"|"4E"|"4F")  # Titanite board_ids
        echo "Titnanite Platform Rev $revID"
        if [ "$revID" != "B" ] ; then
            echo "Not Rev B (EVT). Aborting"
            exit -1
        fi
   ;;
   *)  # Default 
        echo "Unknown Platform. Aborting"
        exit -1
esac

# Find bus addr of PCIe Retimer
sbus_num=0
fmux=0
function probe_bus() {
	echo pca9548 $1 > /sys/bus/i2c/devices/i2c-10/new_device || true
	sleep 1
	sbus_num=`i2cdetect -l | grep i2c-10.*chan.*5 | awk '{print $1}' | cut -d\- -f 2`
	sleep 1
	i2cdetect -y $sbus_num | grep "20 21"
	local gretval=$?
	if [ $gretval -eq 0 ]; then
		echo "Found Retimers on $sbus_num"
		fmux=$1
		return $sbus_num
	else
		sbus_num=0
		echo $1 > /sys/bus/i2c/devices/i2c-10/delete_device || true
		return 0
	fi
}
probe_bus 0x70
abus_num=$?
if [ $abus_num -eq 0 ]; then
	probe_bus 0x71
	abus_num=$?
	if [ $abus_num -eq 0 ]; then
		probe_bus 0x75
		abus_num=$?
		if [ $abus_num -eq 0 ] ; then
			echo "Retimer not found on any mux behind i2c-10"
			exit -1
		else
			echo "Retimers found on $abus_num"
			BUSADDR=$abus_num
		fi
	else
		echo "Retimers found on $abus_num"
		BUSADDR=$abus_num
	fi
else
	echo "Retimers found on $abus_num"
	BUSADDR=$abus_num
fi
IMAGE_DIR=$1
echo "PCIe Retimer upgrade started at $(date)"

#Flashcp image to device.
#echo $IMAGE_DIR
pushd $IMAGE_DIR

MANIFEST_FILE=$(find -type f -name 'MANIFEST')

if [ -e "$MANIFEST_FILE" ]; then
    Manufacturer=$(sed '2!d' $MANIFEST_FILE | awk -F= '{print $NF}')
else
    echo "MANIFEST file not available. Update failed"
    echo $fmux > /sys/bus/i2c/devices/i2c-10/delete_device || true
    exit -1
fi

IMAGE_FILE=$(find -type f -name '*.ihx')

if [ ! -e "$IMAGE_FILE" ]; then
    IMAGE_FILE=$(find -type f -name '*.bin')
    if [ ! -e "$IMAGE_FILE" ]; then
        IMAGE_FILE=$(find -type f -name '*.txt')
        if [ ! -e "$IMAGE_FILE" ]; then
            echo "image file does not exist"
            echo $fmux > /sys/bus/i2c/devices/i2c-10/delete_device || true
            exit -1
        fi
    fi
fi

echo " image file is $IMAGE_FILE"

if [ "$Manufacturer" == "Aries" ]; then
    SLAVEADDR=$(sed '3!d' $MANIFEST_FILE | awk -F= '{print $NF}')
    /usr/bin/retimer_update $BUSADDR $SLAVEADDR $IMAGE_FILE
    if [ $? -eq 0 ]; then
        echo "update Successful"
	echo $fmux > /sys/bus/i2c/devices/i2c-10/delete_device || true
    else
        echo "update failed"
	echo $fmux > /sys/bus/i2c/devices/i2c-10/delete_device || true
        exit -1
    fi

else
    echo "Not a valid Manufacturer Name. Aborting the update"
    echo $fmux > /sys/bus/i2c/devices/i2c-10/delete_device || true
    exit -1
fi

popd
