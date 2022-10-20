#!/bin/bash

# Read board_id from u-boot env
board_id=`/sbin/fw_printenv -n board_id`
I3C_TOOL="/usr/bin/i3ctransfer"
LOG_DIR="/home/root/DIMM_SPD"
num_of_cpu=1

# If no board_id then set num of cpu to 2 socket
case "$board_id" in
    "65" | "62")
        echo " Shale 1 CPU"
        num_of_cpu=1
        ;;
    "63")
        echo " Cinnabar 1 CPU"
        num_of_cpu=2
        ;;
    "64" | "61")
        echo " Sunstone 1 CPU"
        num_of_cpu=2
        ;;
    *)
        echo " Unknown 2 CPU "
        num_of_cpu=2
        ;;
esac

# <TBD>
# Set BMC GPIO for I3C access
# Currently Hawaii doesn't have any GPIOs defined for this
# and Onyx has P0_SPD_HOST_CTRL GPIO which tells whether
# platform fw is has the bus or not.
# Ideally default behavior should be: whenever host power is
# off, BMC should have I3C access without setting any GPIOs.
# <TBD>

# BMC has access to I3C - Read DIMM SPDs
i3cid=0
sock_id=0
channel=0

#Create LOG_DIR to store spd data
if [[ ! -d ${LOG_DIR} ]]
then
    mkdir ${LOG_DIR}
fi

#Remove DIMM SPD files from prev read
rm ${LOG_DIR}/* > /dev/null 2>&1

# Generate DIMM REG/SPD data files
while [[ $sock_id < $num_of_cpu ]]
do
    for i3c_bus_per_soc in 1 2
    do
        # Check if at least one DIMM present on this BUS
        ls /dev/i3c-${i3cid}-* > /dev/null 2>&1
        if [[ $? -ne 0 ]]
        then
            # No DIMMs on this I3C bus
            (( i3cid += 1))
            (( channel += 6 ))
            continue
        fi

        for dimm in {0..5}
        do
            # Driver generated I3C name for this dimm
            dev_name="/dev/i3c-${i3cid}-3c00000000${dimm}"

            # Check if DIMM is present
            $I3C_TOOL -d ${dev_name} -w 0x80,0x00 -r 0x1 > /dev/null 2>&1
            if [[ $? -ne 0 ]]
            then
                # DIMM not present
                continue
            fi

            echo "----------------------------------"
            echo "DIMM detected in S"${sock_id} "I3C_Bus" ${i3cid} "Ch"${dimm}""
            # DDR5 I3C DIMMs have 128 bytes of internal register
            # data and 1024 bytes of SPD EEPROM data
            id=$(( channel + dimm ))
            reg="${LOG_DIR}/P${sock_id}_dimm${id}_spd_reg"
            spd="${LOG_DIR}/P${sock_id}_dimm${id}_spd_data"

            # Read Register data
            $I3C_TOOL -d ${dev_name} -w 0x0 -r 0x80 | sed '1,3d;s/0x//g;s/ //g' | tr '\n' ' ' >> $reg

            #Read SPD EEPROM data
            for blk in {0..7}
            do
                $I3C_TOOL -d ${dev_name} -w 0x80,$blk -r 0x40 | sed '1,3d;s/0x//g;s/ //g' | tr '\n' ' ' >> $spd
                $I3C_TOOL -d ${dev_name} -w 0xc0,$blk -r 0x40 | sed '1,3d;s/0x//g;s/ //g' | tr '\n' ' ' >> $spd
            done # END of blk loop

        done # END of dimm loop

        (( channel += 6 ))
        (( i3cid += 1 ))

    done # END of i3c_bus_per_sock loop
    (( sock_id += 1 ))

done # END of num_of_cpu loop

# <TBD>
# If BMC set any GPIO for I3C access then
# release it here
# <TBD>
