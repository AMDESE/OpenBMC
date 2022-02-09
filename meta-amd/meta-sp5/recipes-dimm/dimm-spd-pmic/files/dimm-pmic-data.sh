#!/bin/bash

# Read board_id from u-boot env
board_id=`/sbin/fw_printenv -n board_id`
I3C_TOOL="/usr/bin/i3ctransfer"
LOG_DIR="/home/root/DIMM_PMIC"
num_socks=1

# If not onyx board or no board_id then we should set to 2 socket
if [[ "$board_id" != "40" ]] && [[ "$board_id" != "41" ]] && [[ "$board_id" != "42" ]] && [[ "$board_id" != "ff" ]]; then
    num_socks=2
fi

# <TBD>
# Set BMC GPIO for I3C access
# Currently Hawaii doesn't have any GPIOs defined for this
# and Onyx has P0_SPD_HOST_CTRL GPIO which tells whether
# platform fw is has the bus or not.
# Ideally default behavior should be: whenever host power is
# off, BMC should have I3C access without setting any GPIOs.
# <TBD>

# BMC has access to I3C - Read DIMM PMIC
i3cid=0
sock_id=0
channel=0

#Create LOG_DIR to store PMIC Registers
if [[ ! -d ${LOG_DIR} ]]
then
    mkdir ${LOG_DIR}
fi

#Remove DIMM PMIC files from prev read
rm ${LOG_DIR}/* > /dev/null 2>&1

# Generate DIMM PMIC data files
while [[ $sock_id < $num_socks ]]
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
            pmic_name="/dev/i3c-${i3cid}-2040000000${dimm}"

            # Check if DIMM is present
            $I3C_TOOL -d ${pmic_name} -w 0x33 -r 0x1 > /dev/null 2>&1
            if [[ $? -ne 0 ]]
            then
                # DIMM not present
                continue
            fi

            echo "DIMM in Socket " ${sock_id} " Ch " ${i3cid} " slot " ${dimm} "is present"

            # DDR5 I3C DIMMs have 128 bytes of PMIC registers
            id=$(( channel + dimm ))
            reg="${LOG_DIR}/P${sock_id}_dimm${id}_pmic_reg"

            # Read Register data
            $I3C_TOOL -d ${pmic_name} -w 0x0 -r 0x80 | sed '1,3d;s/0x//g;s/ //g' | tr '\n' ' ' >> $reg

        done # END of dimm loop

        (( channel += 6 ))
        (( i3cid += 1 ))

    done # END of i3c_bus_per_sock loop
    (( sock_id += 1 ))

done # END of num_sock loop

# <TBD>
# If BMC set any GPIO for I3C access then
# release it here
# <TBD>
