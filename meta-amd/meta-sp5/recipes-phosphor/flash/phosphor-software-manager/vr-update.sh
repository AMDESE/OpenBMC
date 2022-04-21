#!/bin/bash

# VR upgrade
# Below are the BMC GPIO settings to access VR SPI flash
# GPIOs: [VR_BMC_GPIOO1:VR_BMC_GPIOO0]
#       [00] = Run Mode
#       [01] = Local BIOS SPI
#       [10] = HPM FPGA SPI
#       [11] = HPM LOM SPI
#

set +e

IMAGE_DIR=$1

echo "VR upgrade started at $(date)"

#Flashcp image to device.
echo $IMAGE_DIR
pushd $IMAGE_DIR

MANIFEST_FILE=$(find -type f -name 'MANIFEST')

if [ -e "$MANIFEST_FILE" ]; then
    Manufacturer=$(sed '2!d' $MANIFEST_FILE | awk -F= '{print $NF}')
else
    echo "MANIFEST file not available. Update failed"
    exit -1
fi

if [ -e *.hex ] ; then
    IMAGE_FILE=$(find -type f -name '*.hex')
elif [ -e *.bin ] ; then
    IMAGE_FILE=$(find -type f -name '*.bin')
elif [ -e *.txt ] ; then
    IMAGE_FILE=$(find -type f -name '*.txt')
elif [ -e *.xsf ] ; then
    IMAGE_FILE=$(find -type f -name '*.xsf')
    slave_addr=$(sed '3!d' $MANIFEST_FILE | awk -F= '{print $NF}')
else
    echo "VR image file does not exist"
    exit -1
fi

echo "VR image file is $IMAGE_FILE"

if [ "$Manufacturer" == "Renesas" ]; then
    SLAVEADDR=$(sed '3!d' $MANIFEST_FILE | awk -F= '{print $NF}')
    PROCESSOR=$(sed '4!d' $MANIFEST_FILE | awk -F= '{print $NF}')
    /usr/bin/renesas-vr-update.sh $PROCESSOR $SLAVEADDR $IMAGE_FILE $Manufacturer
    if [ $? -eq 0 ]; then
        echo "Renesas VR update Successful"
    else
        echo "Renesas VR update failed"
        exit -1
    fi

elif [ "$Manufacturer" == "Infineon" ]; then
    IMAGE_FILE=$(find -type f -name '*.xsf')
    if [ -e "$IMAGE_FILE" ]; then
        /usr/bin/infineon-vr-update.sh $IMAGE_FILE $Manufacturer $slave_addr
    else
        /usr/bin/infineon-vr-update.sh $IMAGE_FILE $Manufacturer
        if [ $? -eq 0 ]; then
            echo "Infineon VR update Successful"
        else
            echo "Infineon VR update failed"
            exit -1
        fi
    fi
else
    echo "Not a valid Manufacturer Name. Aborting the update"
    exit -1
fi

popd
