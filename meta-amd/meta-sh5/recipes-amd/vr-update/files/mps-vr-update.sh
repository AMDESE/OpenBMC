#!/bin/bash

set +e

# usr/bin/mps-vr-update.sh $PROCESSOR $SLAVEADDR $IMAGE_FILE $Manufacturer
PROCESSOR=$1
ADDR=$2
IMAGE_FILE=$3
BOARD=$4

echo "MPS VR upgrade started on $(date)\n"
echo "Processor = $PROCESSOR Address = $ADDR Board = $BOARD"
echo "VR update image file is = $IMAGE_FILE"

FILE_NAME=`echo $IMAGE_FILE | cut -c3-`
while read line; do
	if [[ "${line}" == "Product ID:"* ]]; then
		MODEL_NUMBER=`echo "$line" | cut -f 2`
		MODEL_NUMBER=`sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'<<<"${MODEL_NUMBER}"`
		CONFIG_ID=`echo $MODEL_NUMBER | cut -b 5-`
		CONFIG_ID=`sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'<<<"${CONFIG_ID}"`

	elif [[ "${line}" == "I2C Address:"* ]]; then
	   	I2C_ADDRESS=`echo "${line}" | cut -f 2`
		I2C_ADDRESS=`sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'<<<"${I2C_ADDRESS}"`
fi
done < $FILE_NAME


#Step 1: BUS NUMBER AND I2C ADDRESS
if [ "$ADDR" == "$I2C_ADDRESS" ]; then
	BUS=`find /sys/bus/i2c/drivers/MP2862/ -name *-00${ADDR,,} -exec basename {} \; | cut -c -2`
	echo "Bus configured to $BUS and I2C address is $ADDR"
else
	echo "Invalid chip address"
	exit -1
fi

echo $BUS-00${ADDR,,}> /sys/bus/i2c/drivers/MP2862/unbind
echo "MPS Driver is unbinded for VR update to continue"

#Step 2: VENDOR ID  # To be discussed
VENDOR_ID=`i2cget -y $BUS 0x$ADDR 0x99 i 4`
echo "Vendor id is $VENDOR_ID"

#Step 3: CONFIG ID - dynamic retrieval from .txt file
if ([  "0x$CONFIG_ID" == 0x61  ] || [  "0x$CONFIG_ID" == 0x62  ] ||[  "0x$CONFIG_ID" == 0x63  ]); then
	echo "Valid CONFIG id"
else
	echo "invalid CONFIG id --$CONFIG_ID--"
	echo $BUS-00${ADDR,,} > /sys/bus/i2c/drivers/MP2862/bind
	exit -1
fi

#Step 4: MODEL NUMBER - Dynamic retrieval from .txt file

if([  "$MODEL_NUMBER" == "MP2861"  ] || [  "$MODEL_NUMBER" == "MP2862"  ] || [  "$MODEL_NUMBER" == "MP2863"  ] ); then
	echo "Model number is = $MODEL_NUMBER"
else
	echo "Invalid model number $MODEL_NUMBER"
	echo $BUS-00${ADDR,,} > /sys/bus/i2c/drivers/MP2862/bind
	exit -1
fi

#Step 5: Start VR update
/usr/bin/mps-vr.sh $IMAGE_FILE $BUS $ADDR  $MODEL_NUMBER

echo $BUS-00${ADDR,,} > /sys/bus/i2c/drivers/MP2862/bind
echo "$MODEL_NUMBER driver is binded back after VR update"
