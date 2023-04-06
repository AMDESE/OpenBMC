#!/bin/bash
set +e

# Find bus addr of PCIe Retimer if OB
sbus_num=0
fmux=0
onboard_flag=0
slot_flag=0
port=0
i2cbus=9
mux=0
Volcano=false
volcano_riser1_bus=208
volcano_riser2_bus=209

# Read Board ID from u-boot env
boardID=`fw_printenv board_id | sed -n "s/^board_id=//p"`
revID=`hexdump -c /sys/bus/i2c/devices/7-0050/eeprom -s 24 -n 1 | head -n 1 | awk '{ print $2}'`
case $boardID in
   "3D"|"40"|"41"|"42"|"52")  # Onyx board_ids
        echo "Retimer update not supported for Onyx"
        mux=70
   ;;
   "3e" | "3E" | "43" | "44" | "45" | "51")  # Quartz board_ids
        echo "Retimer update not supported for Quartz"
        mux=70
   ;;
   "46"|"47"|"48")  # Ruby board_ids
        echo "Retimer update not supported for Ruby"
        mux=70
   ;;
   "49" | "4A" | "4a" | "4B" | "4b" | "4C" |"4c" | "4D" | "4d" | "4E" | "4e")  # Titanite board_ids
        echo "Titnanite Platform Rev $revID"
        mux=71
   ;;
   "6B"| "74" | "75")  # volcano board_ids
        Volcano=true
        echo "Turin Volcano platform Rev $revID"
   ;;
   *)  # Default
        echo "Unknown Platform. Aborting"
        exit -1
esac

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

function onboard_probe() {
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
    onboard_flag=1
}

function onboard_cleanup() {
    if [ $Volcano != "true" ]; then
        if [ $onboard_flag == 1 ]; then
            echo $fmux > /sys/bus/i2c/devices/i2c-10/delete_device || true
        fi
    fi
}

function set_bus_for_slot() {
    # unbind HW Monitors
    echo $i2cbus-00$mux > /sys/bus/i2c/drivers/pca954x/unbind
    sleep 1
    # set MUX to Port
    i2cset -f -y $i2cbus 0x$mux $port
    BUSADDR=$i2cbus
    slot_flag=1
}

function slot_cleanup() {
    if [ $slot_flag == 1 ] ; then
    # bind HW Monitors
        echo $i2cbus-00$mux > /sys/bus/i2c/drivers/pca954x/bind
        sleep 1
    fi
}

IMAGE_DIR=$1
echo "PCIe Retimer upgrade started at $(date)"

#Flashcp image to device.
#echo $IMAGE_DIR
pushd $IMAGE_DIR

MANIFEST_FILE=$(find -type f -name 'MANIFEST')

if [ -e "$MANIFEST_FILE" ]; then
    Manufacturer=$(sed '2!d' $MANIFEST_FILE | awk -F= '{print $NF}')
    Riser=$(sed '4!d' $MANIFEST_FILE | awk -F= '{print $NF}')
else
    echo "MANIFEST file not available. Update failed"
    onboard_cleanup
    slot_cleanup
    exit -1
fi

if [ $Volcano == "true" ]; then
    if [ $Riser == "Riser1" ]; then
        BUSADDR=$volcano_riser1_bus
    elif [ $Riser == "Riser2" ]; then
        BUSADDR=$volcano_riser2_bus
    else
        echo "Unknown Riser in MANIFEST"
        exit
    fi
    echo "Volcano: " $Manufacturer $Riser $BUSADDR
else
    if [ $Riser == "Riser1" ]; then
        port=0x10
        set_bus_for_slot
    elif [ $Riser == "Riser2" ]; then
        port=0x20
        set_bus_for_slot
    elif [ $Riser == "RiserOB" ]; then
        onboard_probe
    else
        echo "Unknown Riser in MANIFEST"
        exit
    fi
fi

IMAGE_FILE=$(find -type f -name '*.ihx')

if [ ! -e "$IMAGE_FILE" ]; then
    IMAGE_FILE=$(find -type f -name '*.bin')
    if [ ! -e "$IMAGE_FILE" ]; then
        IMAGE_FILE=$(find -type f -name '*.txt')
        if [ ! -e "$IMAGE_FILE" ]; then
            echo "image file does not exist"
            onboard_cleanup
            slot_cleanup
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
        onboard_cleanup
        slot_cleanup
    else
        echo "update failed"
        onboard_cleanup
        slot_cleanup
        exit -1
    fi

else
    echo "Not a valid Manufacturer Name. Aborting the update"
    onboard_cleanup
    slot_cleanup
    exit -1
fi

popd

