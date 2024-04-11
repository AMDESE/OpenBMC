#!/bin/bash

MODE="I2C"
if [ "$(</sys/bus/i3c/devices/i3c-0/mode)" == "pure" ]; then
    MODE="I3C"
fi

# Read number of CPU from u-boot env
num_of_cpu=`/sbin/fw_printenv -n num_of_cpu`
dimm_per_ch=`/sbin/fw_printenv -n dimm_per_ch`
dimm_per_bus=`/sbin/fw_printenv -n dimm_per_bus`
I2C_TOOL="/usr/sbin/i2ctransfer"
I3C_TOOL="/usr/bin/i3ctransfer"
LOG_DIR="/var/lib/dimm"

# assume BMC has access to I3C
i3cid=0
sock_id=0
channel=0

#move DIMM pmic info files from prev read
mv ${LOG_DIR}/pmic_info.txt ${LOG_DIR}/pmic_info.sav
pmic_info="${LOG_DIR}/pmic_info.txt"

pmic_dimm_temp_print()
{
    local temp=$1

    if [[ $temp -eq 0 ]] || [[ $temp -eq 1 ]]
    then
        printf "DIMM Temp is less than 85 C (%s) \n" "${temp}"
    elif [[ $temp -eq 2 ]] || [[ $temp -eq 3 ]]
    then
        printf "DIMM Temp is 85 C (%s) \n" "${temp}"
    elif [[ $temp -eq 4 ]] || [[ $temp -eq 5 ]]
    then
        printf "DIMM Temp is 95 C (%s) \n" "${temp}"
    elif [[ $temp -eq 6 ]] || [[ $temp -eq 7 ]]
    then
        printf "DIMM Temp is 105 C (%s) \n" "${temp}"
    elif [[ $temp -eq 8 ]] || [[ $temp -eq 9 ]]
    then
        printf "DIMM Temp is 115 C (%s) \n" "${temp}"
    elif [[ $temp -eq a ]] || [[ $temp -eq b ]]
    then
        printf "DIMM Temp is 125 C (%s) \n" "${temp}"
    elif [[ $temp -eq c ]] || [[ $temp -eq d ]]
    then
        printf "DIMM Temp is 135 C (%s) \n" "${temp}"
    elif [[ $temp -eq e ]] || [[ $temp -eq f ]]
    then
        printf "DIMM Temp is greater than 140 C (%s) \n" "${temp}"
    fi
}

pmic_dimm_warn_print()
{
    local warn=$1

    if [[ $warn -eq d ]] || [[ $warn -eq 5 ]]
    then
        printf "DIMM Warning Temp is set to > 125 C (%s) \n" "${warn}"
    elif [[ $warn -eq 9 ]] || [[ $warn -eq 1 ]]
    then
        printf "DIMM Warning Temp is set to > 85 C (%s) \n" "${warn}"
    elif [[ $warn -eq a ]] || [[ $warn -eq 2 ]]
    then
        printf "DIMM Warning Temp is set to > 95 C (%s) \n" "${warn}"
    elif [[ $warn -eq b ]] || [[ $warn -eq 3 ]]
    then
        printf "DIMM Warning Temp is set to > 105 C (%s) \n" "${warn}"
    elif [[ $warn -eq c ]] || [[ $warn -eq 4 ]]
    then
        printf "DIMM Warning Temp is set to > 115 C (%s) \n" "${warn}"
    elif [[ $warn -eq e ]] || [[ $warn -eq 6 ]]
    then
        printf "DIMM Warning Temp is set to > 135 C (%s) \n" "${warn}"
    fi
}

pmic_dimm_crit_print()
{
    local  crit=$1

    if [[ $crit -eq 4 ]]
    then
        printf "DIMM Critical Temp is set to > 145 C (%s) \n" "${crit}"
    elif [[ $crit -eq 0 ]]
    then
        printf "DIMM Critical Temp is set to > 105 C (%s) \n" "${crit}"
    elif [[ $crit -eq 1 ]]
    then
        printf "DIMM Critical Temp is set to > 115 C (%s) \n" "${crit}"
    elif [[ $crit -eq 2 ]]
    then
        printf "DIMM Critical Temp is set to > 125 C (%s) \n" "${crit}"
    elif [[ $crit -eq 3 ]]
    then
        printf "DIMM Critical Temp is set to > 135 C (%s) \n" "${crit}"
    fi
}

pmic_i2c_dump()
{
    local i3cid=$1
    local i2cid=$2
    local channel=$3

    pmic_addr=0x48
    for (( dimm=0; dimm<dimm_per_bus; dimm++ ))
    do
        # Check if DIMM is present
        #echo $pmic_addr
        $I2C_TOOL -y $i2cid w1@$(( pmic_addr )) 0x33 r1 > /dev/null 2>&1
        if [[ $? -ne 0 ]]
        then
            # DIMM not present
            (( pmic_addr += 1 ))
            continue
        fi
        echo "----------------------------------"
        echo "DIMM detected in S"${sock_id} "I3C_Bus" ${i3cid} "Ch"${dimm}""

        echo "----------------------------------"                            >> $pmic_info
        echo "DIMM detected in S"${sock_id} "I3C_Bus" ${i3cid} "Ch"${dimm}"" >> $pmic_info

        # DDR5 I3C DIMMs have 128 bytes of PMIC registers
        id=$(( channel + dimm ))
        reg="${LOG_DIR}/P${sock_id}_dimm${id}_pmic_temp"

        # Read PMIC Register 0x3B (Rev)
        temp1="$($I2C_TOOL -y $i2cid w1@$(( pmic_addr )) 0x3b r1 | grep 0x)"
        printf 'R3B (Rev) = %s \n' ${temp1}
        printf 'R3B (Rev) = %s \n' ${temp1} >> $pmic_info

        regs=(0x04 0x05 0x06 0x08 0x09 0x0A 0x0B 0x32 0x33 0x35)
        for reg in ${regs[@]}; do
            temp1="$($I2C_TOOL -y $i2cid w1@$(( pmic_addr )) ${reg} r1 | grep 0x)"
            printf 'R%02X = %s \n' ${reg} ${temp1}
            printf 'R%02X = %s \n' ${reg} ${temp1} >> $pmic_info
        done

        # Read DIMM Temp Register 0x33
        temp1="$($I2C_TOOL -y $i2cid w1@$(( pmic_addr )) 0x33 r1 | grep 0x | cut -c 7-7)"
        temp="$(printf '%d' ${temp1})"
        pmic_dimm_temp_print $temp

        # Read DIMM Warning Register 0x1B
        warn1="$($I2C_TOOL -y $i2cid w1@$(( pmic_addr )) 0x1b r1 | grep 0x | cut -c 8-8)"
        warn="$(printf '%d' ${warn1})"
        pmic_dimm_warn_print $warn

        # Read DIMM Critical Temp Register 0x2E
        crit1="$($I2C_TOOL -y $i2cid w1@$(( pmic_addr )) 0x2e r1 | grep 0x | cut -c 8-8)"
        crit="$(printf '%d' ${crit1})"
        pmic_dimm_crit_print $crit

        (( pmic_addr += 1 ))
    done #for (( dimm=0; dimm<dimm_per_bus; dimm++ ))
}

pmic_i3c_dump()
{
    local i3cid=$1
    local channel=$2
    for (( dimm=0; dimm<dimm_per_bus; dimm++ ))
    do
        # Driver generated I3C name for this dimm
        pmic_name="/dev/bus/i3c/${i3cid}-2040000000${dimm}"

        # Check if DIMM is present
        $I3C_TOOL -d ${pmic_name} -w 0x33 -r 0x1 > /dev/null 2>&1
        if [[ $? -ne 0 ]]
        then
            # DIMM not present
            continue
        fi
        echo "----------------------------------"
        echo "DIMM detected in S"${sock_id} "I3C_Bus" ${i3cid} "Ch"${dimm}""

        echo "----------------------------------"                            >> $pmic_info
        echo "DIMM detected in S"${sock_id} "I3C_Bus" ${i3cid} "Ch"${dimm}"" >> $pmic_info

        # DDR5 I3C DIMMs have 128 bytes of PMIC registers
        id=$(( channel + dimm ))
        reg="${LOG_DIR}/P${sock_id}_dimm${id}_pmic_temp"

        # Read PMIC Register 0x3B (Rev)
        temp1="$($I3C_TOOL -d ${pmic_name} -w 0x3b -r 1 | grep 0x)"
        printf 'R3B (Rev) = %s \n' ${temp1}
        printf 'R3B (Rev) = %s \n' ${temp1} >> $pmic_info

        regs=(0x04 0x05 0x06 0x08 0x09 0x0A 0x0B 0x32 0x33 0x35)
        for reg in ${regs[@]}; do
            temp1="$($I3C_TOOL -d ${pmic_name} -w ${reg} -r 1 | grep 0x)"
            printf 'R%02X = %s \n' ${reg} ${temp1}
            printf 'R%02X = %s \n' ${reg} ${temp1} >> $pmic_info
        done

        # Read DIMM Temp Register 0x33
        temp1="$($I3C_TOOL -d ${pmic_name} -w 0x33 -r 1 | grep 0x| cut -c 7-7)"
        temp="$(printf '%d' ${temp1})"
        pmic_dimm_temp_print $temp

        # Read DIMM Warning Register 0x1B
        warn1="$($I3C_TOOL -d ${pmic_name} -w 0x1b -r 1 | grep 0x| cut -c 8-8)"
        warn="$(printf '%d' ${warn1})"
        pmic_dimm_warn_print $warn

        # Read DIMM Critical Temp Register 0x2E
        crit1="$($I3C_TOOL -d ${pmic_name} -w 0x2e -r 1 | grep 0x| cut -c 8-8)"
        crit="$(printf '%d' ${crit1})"
        pmic_dimm_crit_print $crit

    done #for (( dimm=0; dimm<dimm_per_bus; dimm++ ))
}

# read and process DIMM PMIC Regs
max_i3c_bus_per_soc=$((2 * dimm_per_ch))
while [[ $sock_id < $num_of_cpu ]]
do
    for i3c_bus_per_soc in $(seq 1 $max_i3c_bus_per_soc)
    do
        # Check if at least one DIMM present on this BUS
        i2cid=
        no_dimms=
        if [ "$MODE" == "I2C" ]; then
                i2cid=$(i2cdetect -y -l|grep "i3c$i3cid"|awk -F'[^0-9]+' '{ print $3 }')
                ls /sys/bus/i2c/devices/i2c-${i2cid}/${i2cid}-00* > /dev/null 2>&1
                if [[ $? -ne 0 ]]
                then
                    no_dimms=1
                fi
        else
            ls /dev/bus/i3c/${i3cid}-* > /dev/null 2>&1
            if [[ $? -ne 0 ]]
            then
                no_dimms=1
            fi
        fi

        if [[ $no_dimms -eq 1 ]]
        then
            # No DIMMs on this I3C bus
            (( i3cid += 1))
            (( channel += dimm_per_bus ))
            continue
        fi

        if [ "$MODE" == "I2C" ]; then
            pmic_i2c_dump $i3cid $i2cid $channel
        else
            pmic_i3c_dump $i3cid $channel
        fi

        (( channel += 6 ))
        (( i3cid += 1 ))

    done # END of i3c_bus_per_sock loop

    (( sock_id += 1 ))

done # END of num_of_cpu loop
