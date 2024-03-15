#!/bin/bash

I2C_TOOL="/usr/sbin/i2ctransfer"
I3C_TOOL="/usr/bin/i3ctransfer"

pmic_i2c_err_dump()
{
    local i3cid=$1
    local dimm=$2

    i2cid=$(i2cdetect -y -l|grep "i3c$i3cid"|awk -F'[^0-9]+' '{ print $3 }')
    ls /sys/bus/i2c/devices/i2c-${i2cid}/${i2cid}-00* > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        # DIMM not present
        echo "DIMM Not detected in I3C_Bus" ${i3cid} "Ch" ${dimm}
        exit
    fi

    pmic_addr=$(( 0x48+dimm-1 ))
    # read interested registers from PMIC
    regs=(0x04 0x05 0x06 0x08 0x09 0x0A 0x0B 0x32 0x33 0x35)
    for reg in ${regs[@]}; do
        temp1="$($I2C_TOOL -y $i2cid w1@$(( pmic_addr )) $reg r1 | grep 0x)"
        printf 'R%02X = %s \n' ${reg} ${temp1}
    done
}

pmic_i3c_err_dump()
{
    # assume BMC has access to I3C
    pmic_name="/dev/bus/i3c/${i3cid}-2040000000${dimm}"
    # Check if DIMM is present
    $I3C_TOOL -d ${pmic_name} -w 0x33 -r 0x1 > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        # DIMM not present
        echo "DIMM Not detected in I3C_Bus" ${i3cid} "Ch" ${dimm}
        exit
    fi
    # read interested registers from PMIC
    regs=(0x04 0x05 0x06 0x08 0x09 0x0A 0x0B 0x32 0x33 0x35)
    for reg in ${regs[@]}; do
            temp1="$($I3C_TOOL -d ${pmic_name} -w $reg -r 1 | grep 0x)"
        printf 'R%02X = %s \n' ${reg} ${temp1}
    done
}

if [ "$(</sys/bus/i3c/devices/i3c-0/mode)" == "pure" ]; then
    pmic_i3c_err_dump $1 $2
else
    pmic_i2c_err_dump $1 $2
fi
