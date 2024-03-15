#!/bin/bash

MODE="I2C"
if [ "$(</sys/bus/i3c/devices/i3c-0/mode)" == "pure" ]; then
    MODE="I3C"
fi

# Read num of cpu from u-boot env
num_of_cpu=`/sbin/fw_printenv -n num_of_cpu`
dimm_per_bus=`/sbin/fw_printenv -n dimm_per_bus`
I2C_TOOL="/usr/sbin/i2ctransfer"
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

spd_i2c_dump()
{
    local i3cid=$1
    local i2cid=$2
    local channel=$3

    spd_addr=0x50
    for (( dimm=0; dimm<dimm_per_bus; dimm++ ))
    do
        # Check if DIMM is present
        i2cset -f -y $i2cid $(( spd_addr )) 0x0b 0x08 b
        $I2C_TOOL -y $i2cid w2@$(( spd_addr )) 0x80 0x00 r1 > /dev/null 2>&1
        if [[ $? -ne 0 ]]
        then
            # DIMM not present
            (( spd_addr += 1 ))
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
        $I2C_TOOL -y $i2cid w1@$(( spd_addr )) 0x0 r0x80 | sed 's/0x//g' | tr '\n' ' ' >> $reg

        #Read SPD EEPROM data
        for blk in {0..7}
        do
             $I2C_TOOL -y $i2cid w2@$(( spd_addr )) 0x80 $blk r0x40 | sed 's/0x//g' | tr '\n' ' ' >> $spd
             $I2C_TOOL -y $i2cid w2@$(( spd_addr )) 0xc0 $blk r0x40 | sed 's/0x//g' | tr '\n' ' ' >> $spd
        done # END of blk loop
        (( spd_addr += 1 ))

    done # END of dimm loop
}

spd_i3c_dump()
{
    local i3cid=$1
    local channel=$2

    for (( dimm=0; dimm<dimm_per_bus; dimm++ ))
    do
        # Driver generated I3C name for this dimm
        dev_name="/dev/bus/i3c/${i3cid}-3c00000000${dimm}"

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
}

# Generate DIMM REG/SPD data files
while [[ $sock_id < $num_of_cpu ]]
do
    for i3c_bus_per_soc in 1 2
    do
        # Check if at least one DIMM present on this BUS
        i2cid=
        dimms_present=0
        if [ "$MODE" == "I2C" ]; then
                i2cid=$(i2cdetect -y -l|grep "i3c$i3cid"|awk -F'[^0-9]+' '{ print $3 }')
                ls /sys/bus/i2c/devices/i2c-${i2cid}/${i2cid}-00* > /dev/null 2>&1
                if [[ $? -eq 0 ]]
                then
                    dimms_present=1
                fi
        else
            ls /dev/bus/i3c/${i3cid}-* > /dev/null 2>&1
            if [[ $? -eq 0 ]]
            then
                dimms_present=1
            fi
        fi

        if [[ $dimms_present -eq 1 ]]
        then
        if [ "$MODE" == "I2C" ]; then
                spd_i2c_dump $i3cid $i2cid $channel
            else
                spd_i3c_dump $i3cid $channel
            fi
        fi

        (( channel += 6 ))
        (( i3cid += 1 ))

    done # END of i3c_bus_per_sock loop
    (( sock_id += 1 ))

done # END of num_of_cpu loop
