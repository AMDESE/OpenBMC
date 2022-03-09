#!/bin/bash

# Read board_id from u-boot env
board_id=`/sbin/fw_printenv -n board_id`
I3C_TOOL="/usr/bin/i3ctransfer"
num_of_cpu=1

# If no board_id then set num of cpu to 2 socket
case "$board_id" in
    "40" | "41" | "42")
        echo " Onyx 1 CPU"
        num_of_cpu=1
        ;;
    "46" | "47" | "48")
        echo " Ruby 1 CPU"
        num_of_cpu=1
        ;;
    "43" | "44" | "45")
        echo " Quartz 2 CPU"
        num_of_cpu=2
        ;;
    "49" | "4A" |"4a" | "4B" | "4b")
        echo " Titanite 2 CPU "
        num_of_cpu=2
        ;;
    *)
        num_of_cpu=2
        ;;
esac

# assume BMC has access to I3C
i3cid=0
sock_id=0
channel=0

# read and process DIMM Temp
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
            pmic_name="/dev/i3c-${i3cid}-2040000000${dimm}"
            spd_name="/dev/i3c-${i3cid}-3c00000000${dimm}"

            # Check if DIMM is present
            $I3C_TOOL -d ${pmic_name} -w 0x33 -r 0x1 > /dev/null 2>&1
            if [[ $? -ne 0 ]]
            then
                # DIMM not present
                continue
            fi

            echo "----------------------------------"
            echo "DIMM in Socket " ${sock_id} " Ch " ${i3cid} " slot " ${dimm} "is present"

            # DDR5 I3C DIMMs have 128 bytes of PMIC registers
            id=$(( channel + dimm ))
            reg="${LOG_DIR}/P${sock_id}_dimm${id}_pmic_temp"

            # Read DIMM SPD ID
            mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0xC0,0x01 -r 0x40)
            if [[ ${spd_data[48]} -eq "0x86" ]] && [[ ${spd_data[49]} -eq "0x32" ]]
            then
                echo "  MFG is:  Montage "
            elif [[ ${spd_data[48]} -eq "0x86" ]] && [[ ${spd_data[49]} -eq "0x9d" ]]
            then
                echo "  MFG ID:  Rambus "
            elif [[ ${spd_data[48]} -eq "0x80" ]] && [[ ${spd_data[49]} -eq "0xb3" ]]
            then
                echo "  MFG ID:  IDT "
            else
                echo "  MFG ID: " ${spd_data[49]} ${spd_data[48]}
            fi
            echo "  Device Type:  " ${spd_data[50]}
            echo "  Device Rev :  " ${spd_data[51]}
            # Read DIMM Temp Register 0x33
            temp1="$($I3C_TOOL -d ${pmic_name} -w 0x33 -r 1 | grep 0x| cut -c 7-7)"
            temp="$(printf '%d' ${temp1})"
            if [[ $temp -eq 0 ]] || [[ $temp -eq 1 ]]
            then
                printf "  Temp is < 85 C \n"
            elif [[ $temp -eq 2 ]] || [[ $temp -eq 3 ]]
            then
                printf "DIMM Temp is 85 C \n"
            elif [[ $temp -eq 4 ]] || [[ $temp -eq 5 ]]
            then
                printf "DIMM Temp is 95 C \n"
            elif [[ $temp -eq 6 ]] || [[ $temp -eq 7 ]]
            then
                printf "DIMM Temp is 105 C \n"
            elif [[ $temp -eq 8 ]] || [[ $temp -eq 9 ]]
            then
                printf "DIMM Temp is 115 C \n"
            elif [[ $temp -eq a ]] || [[ $temp -eq b ]]
            then
                printf "DIMM Temp is 125 C \n"
            elif [[ $temp -eq c ]] || [[ $temp -eq d ]]
            then
                printf "DIMM Temp is 135 C \n"
            elif [[ $temp -eq e ]] || [[ $temp -eq f ]]
            then
                printf "DIMM Temp > 140 C \n"
            fi

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
