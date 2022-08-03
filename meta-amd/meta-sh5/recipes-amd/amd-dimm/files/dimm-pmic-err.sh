#!/bin/bash

I3C_TOOL="/usr/bin/i3ctransfer"
i3cid=$1
dimm=$2

# assume BMC has access to I3C
pmic_name="/dev/i3c-${i3cid}-2040000000${dimm}"
# Check if DIMM is present
$I3C_TOOL -d ${pmic_name} -w 0x33 -r 0x1 > /dev/null 2>&1
if [[ $? -ne 0 ]]
then
    # DIMM not present
    echo "DIMM Not detected in I3C_Bus" ${i3cid} "Ch" ${dimm}
    exit
fi
# Read PMIC Register 0x04
temp1="$($I3C_TOOL -d ${pmic_name} -w 0x04 -r 1 | grep 0x)"
printf 'R04 = %s \n' ${temp1}
# Read PMIC Register 0x05
temp1="$($I3C_TOOL -d ${pmic_name} -w 0x05 -r 1 | grep 0x)"
printf 'R05 = %s \n' ${temp1}
# Read PMIC Register 0x06
temp1="$($I3C_TOOL -d ${pmic_name} -w 0x06 -r 1 | grep 0x)"
printf 'R06 = %s \n' ${temp1}
# Read PMIC Register 0x08
temp1="$($I3C_TOOL -d ${pmic_name} -w 0x08 -r 1 | grep 0x)"
printf 'R08 = %s \n' ${temp1}
# Read PMIC Register 0x09
temp1="$($I3C_TOOL -d ${pmic_name} -w 0x09 -r 1 | grep 0x)"
printf 'R09 = %s \n' ${temp1}
# Read PMIC Register 0x0A
temp1="$($I3C_TOOL -d ${pmic_name} -w 0x0A -r 1 | grep 0x)"
printf 'R0A = %s \n' ${temp1}
# Read PMIC Register 0x0B
temp1="$($I3C_TOOL -d ${pmic_name} -w 0x0B -r 1 | grep 0x)"
printf 'R0B = %s \n' ${temp1}
# Read PMIC Register 0x32
temp1="$($I3C_TOOL -d ${pmic_name} -w 0x32 -r 1 | grep 0x)"
printf 'R32 = %s \n' ${temp1}
# Read PMIC Register 0x33
temp1="$($I3C_TOOL -d ${pmic_name} -w 0x33 -r 1 | grep 0x)"
printf 'R33 = %s \n' ${temp1}
# Read PMIC Register 0x35
temp1="$($I3C_TOOL -d ${pmic_name} -w 0x35 -r 1 | grep 0x)"
printf 'R35 = %s \n' ${temp1}

