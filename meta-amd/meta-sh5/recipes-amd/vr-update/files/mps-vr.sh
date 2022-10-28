#!/bin/bash

set +e

FILENAME=$1
BUS=$2
ADDR=$3
MODEL=$4

i2c_write_prefix="i2cset -y $BUS 0x$ADDR"
i2c_read_prefix="i2cget -y $BUS 0x$ADDR"

write_byte(){
$i2c_write_prefix 0x$register 0x$data
}

write_word(){
$i2c_write_prefix 0x$register 0x$data w
}

write_block_3byte(){
byte1=`echo $data | cut -c 1,2`
byte2=`echo $data | cut -c 3,4`
byte3=`echo $data | cut -c 5,6`
$i2c_write_prefix 0x$register 0x$byte3 0x$byte2 0x$byte1 i
}

write_block_4byte(){
byte1=`echo $data | cut -c 1,2`
byte2=`echo $data | cut -c 3,4`
byte3=`echo $data | cut -c 5,6`
byte4=`echo $data | cut -c 7,8`
$i2c_write_prefix 0x$register 0x$byte4 0x$byte3 0x$byte2 0x$byte1 i
}


set_page_mode(){
local page=$current_page
echo " "
echo "Set Page Mode : $page"
$i2c_write_prefix 0x00 $page
}

#Read the file and keep updating page as needed
#Use 'mode' to decide which write function to call

current_page="-1"
while read line && [[ "${line}" != "END"* ]]; do

	page=`echo "${line}" | cut -f 2`

	if [ $current_page != $page ]; then
		current_page=$page
		set_page_mode
	fi

    register=`echo "${line}" | cut -f 3`
	data=`echo "${line}" | cut -f 6`
	mode=`echo "${line}" | cut -f 8`

	if [[ "$mode" == "1"* ]]; then
		write_byte
	elif [[ $mode == "2"* ]]; then
		write_word 
	elif [[ $mode == "3"* ]]; then
		write_block_3byte
	elif [[ $mode == "4"* ]]; then
		write_block_4byte
	else
		echo "Invalid W/R mode"
	fi
done < $FILENAME


#Write to page 0
current_page=0
set_page_mode
$i2c_write_prefix 0x15 0
sleep 1
