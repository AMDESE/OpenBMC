#!/bin/bash

# Read num of cpu from u-boot env
num_of_cpu=`/sbin/fw_printenv -n num_of_cpu`
dimm_per_bus=`/sbin/fw_printenv -n dimm_per_bus`
I3C_TOOL="/usr/bin/i3ctransfer"
LOG_DIR="/var/lib/dimm/DIMM_SPD"

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
            (( channel += dimm_per_bus ))
            continue
        fi

        for (( dimm=0; dimm<dimm_per_bus; dimm++ ))
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
