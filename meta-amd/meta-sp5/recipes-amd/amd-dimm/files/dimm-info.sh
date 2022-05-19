#!/bin/bash

# Read board_id from u-boot env
board_id=`/sbin/fw_printenv -n board_id`
I3C_TOOL="/usr/bin/i3ctransfer"
LOG_DIR="/home/root"
num_of_cpu=1

# If no board_id then set num of cpu to 2 socket
case "$board_id" in
    "3d" | "3D" | "40" | "41" | "42" | "52")
        echo " Onyx 1 CPU"
        num_of_cpu=1
        ;;
    "46" | "47" | "48")
        echo " Ruby 1 CPU"
        num_of_cpu=1
        ;;
    "3e" | "3E" | "43" | "44" | "45" | "51")
        echo " Quartz 2 CPU"
        num_of_cpu=2
        ;;
    "49" | "4A" | "4a" | "4B" | "4b" | "4C" |"4c" | "4D" | "4d" | "4E" | "4e")
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
bus_type=unknown
module_type=reserved
package_density=0
io_width=0
num_ranks=0
vendor=0

#move DIMM info files from prev read
mv ${LOG_DIR}/dimm_info ${LOG_DIR}/dimm_info.sav
dimm_info="${LOG_DIR}/dimm_info"

while [[ $sock_id < $num_of_cpu ]]
do
    for i3c_bus_per_soc in 1 2
    do
        # Check if at least one DIMM present on this BUS
        ls /dev/i3c-${i3cid}-* > /dev/null 2>&1
        if [[ $? -ne 0 ]]
        then
            echo "No dimms detected on S"${sock_id} "I3C_Bus"${i3cid}
            # No DIMMs on this I3C bus
            (( i3cid += 1))
            (( channel += 6 ))
            continue
        fi
        # This section reads various SPD bytes and provides dimm info
        for dimm in {0..5}
        do
            # Driver generated I3C name for this dimm
            pmic_name="/dev/i3c-${i3cid}-2040000000${dimm}"
            spd_name="/dev/i3c-${i3cid}-3c00000000${dimm}"

            # Check if DIMM is present
            $I3C_TOOL -d ${spd_name} -w 0x80,0x00 -r 0x1 > /dev/null 2>&1
            if [[ $? -ne 0 ]]
            then
                # DIMM not present
                continue
            fi

            echo "----------------------------------"
            echo "DIMM detected in S"${sock_id} "I3C_Bus" ${i3cid} "Ch"${dimm}""

            echo "----------------------------------"                            >> $dimm_info
            echo "DIMM detected in S"${sock_id} "I3C_Bus" ${i3cid} "Ch"${dimm}"" >> $dimm_info

            # DDR5 I3C DIMMs info
            id=$(( channel + dimm ))

            # Read DIMM Protocol Type
            mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0x80,0x00 -r 0x40)
            if [[ ${spd_data[2]} -eq "0x12" ]]
            then
                bus_type=DDR5
            else
                bus_type=unsupported
            fi
            # Read DIMM module type
            mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0x80,0x00 -r 0x40)
            if [[ ${spd_data[3]} -eq "0x01" ]]
            then
                module_type=RDIMM
            elif [[ ${spd_data[3]} -eq "0x04" ]]
            then
                module_type=LRDIMM
            else
                module_type=Reserved
            fi

            # Read Supported DDR Speed
            mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0x80,0x00 -r 0x40)
            if [[ ${spd_data[21]} -eq "0x01" ]] && [[ ${spd_data[20]} -eq "0xA0" ]]
            then
                speed=4800
            elif [[ ${spd_data[21]} -eq "0x01" ]] && [[ ${spd_data[20]} -eq "0x80" ]]
            then
                speed=5200
            elif [[ ${spd_data[21]} -eq "0x01" ]] && [[ ${spd_data[20]} -eq "0x65" ]]
            then
                speed=5600
            else
                speed=Unknown
            fi

            # Read DRAM Density and Package
            mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0x80,0x00 -r 0x40)
            package_density=${spd_data[4]}
            package=$(($package_density >> 5))
            density=$(($package_density & 0x0f))

            if [[ $package -eq "0" ]]
            then
                package=""
            elif [[ $package -eq "2" ]]
            then
                package=(2H)3DS
            elif [[ $package -eq "3" ]]
            then
                package=(4H)3DS
            else
                package=Reserved
            fi

            if [[ $density -eq "4" ]]
            then
                density=16Gb
            elif [[ $density -eq "5" ]]
            then
                density=24Gb
            elif [[ $density -eq "6" ]]
            then
                density=32Gb
            else
                density=unsupported
            fi

            # Read IO Width
            mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0x80,0x00 -r 0x40)
            io_width=$((${spd_data[6]} >> 5))

            if [[ $io_width -eq "0" ]]
            then
                io_width=x4
            elif [[ $io_width -eq "1" ]]
            then
                io_width=x8
            elif [[ $io_width -eq "2" ]]
            then
                io_width=x16
            else
                io_width=unsupported
            fi

            # Read Number of Ranks
            mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0xC0,0x01 -r 0x40)
            num_ranks=$((${spd_data[42]} >> 3))

            if [[ $num_ranks -eq "0" ]]
            then
                num_ranks="1R"
            elif [[ $num_ranks -eq "1" ]]
            then
                num_ranks="2R"
            elif [[ $num_ranks -eq "3" ]]
            then
                num_ranks="4R"
            else
                num_ranks=unsupported
            fi

            # Determine Total Capacity
            if  [[ $density == "16Gb" ]]
            then
                if [[ $io_width == "x8" ]]
                then
                    if [[ $num_ranks == "1R" ]]
                    then
                        capacity=16GB
                    elif [[ $num_ranks == "2R" ]]
                    then
                        capacity=32GB
                    elif [[ $num_ranks == "4R" ]]
                    then
                        capacity=64GB
                    else
                        capacity=Undefined
                    fi
                elif [[ $io_width == "x4" ]]
                then
                    if [[ $num_ranks == "1R" ]]
                    then
                        capacity=32GB
                    elif [[ $num_ranks == "2R" ]]
                    then
                        if [[ $package == "(2H)3DS" ]]
                        then
                            capacity=128GB
                        elif [[ $package == "(4H) 3DS" ]]
                        then
                            capacity=256GB
                        else
                            capacity=64GB
                        fi
                    elif [[ $num_ranks == "4R" ]]
                    then
                        capacity=128GB
                    else
                        capacity=Undefined
                    fi
                else
                    capacity=Undefined
                fi
            elif [[ $density == "24Gb" ]]
            then
                if [[ $io_width == "x8" ]]
                then
                    if [[ $num_ranks == "1R" ]]
                    then
                        capacity=24GB
                    elif [[ $num_ranks == "2R" ]]
                    then
                        capacity=48GB
                    elif [[ $num_ranks == "4R" ]]
                    then
                        capacity=96GB
                    else
                        capacity=Undefined
                    fi
                elif [[ $io_width == "x4" ]]
                then
                    if [[ $num_ranks == "1R" ]]
                    then
                        capacity=48GB
                    elif [[ $num_ranks == "2R" ]]
                    then
                        if [[ $package == "(2H)3DS" ]]
                        then
                            capacity=192GB
                        elif [[ $package == "(4H) 3DS" ]]
                        then
                            capacity=384GB
                        else
                            capacity=96GB
                        fi
                    elif [[ $num_ranks == "4R" ]]
                    then
                        capacity=192GB
                    else
                        capacity=Undefined
                    fi
                else
                    capacity=Undefined
                fi
            else
                capacity=Undefined
            fi

            # Read DIMM Vendor
            mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0x80,0x04 -r 0x40)
            vendor=${spd_data[40]}
            vendor1=${spd_data[41]}
            if [[ $vendor -eq "0x80" ]]
            then
                if [[ $vendor1 -eq "0x2C" ]]
                then
                    vendor1=Micron
                elif [[ $vendor1 -eq "0xAD" ]]
                then
                    vendor1=Hynix
                elif [[ $vendor1 -eq "0xCE" ]]
                then
                    vendor1=Samsung
                else
                    vendor1=Unknown
                fi
            else
                vendor1=Unknown
            fi

            # Read DIMM RCD vendor and revision
            mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0xC0,0x01 -r 0x40)
            if [[ ${spd_data[48]} -eq "0x86" ]] && [[ ${spd_data[49]} -eq "0x32" ]]
            then
                rcd=Montage
            elif [[ ${spd_data[48]} -eq "0x86" ]] && [[ ${spd_data[49]} -eq "0x9d" ]]
            then
                rcd=Rambus
            elif [[ ${spd_data[48]} -eq "0x80" ]] && [[ ${spd_data[49]} -eq "0xb3" ]]
            then
                rcd=IDT
            else
                rcd=Unsupported
            fi
            rcd_rev=${spd_data[51]}

            # Print dimm info
            echo "  "$bus_type $speed $module_type $package
            echo "  "$capacity" "$vendor1 $num_ranks$io_width" ("$density")"
            echo "  RCD: "$rcd $rcd_rev

            echo "  "$bus_type $speed $module_type $package                  >> $dimm_info
            echo "  "$capacity" "$vendor1 $num_ranks$io_width" ("$density")" >> $dimm_info
            echo "  RCD: "$rcd $rcd_rev                                      >> $dimm_info

            # Read DIMM p/n
            mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0x80,0x04 -r 0x40)
            printf "  PN: "
            printf "  PN: " >> $dimm_info
            for pn in {9..38}
            do
                pnx=${spd_data[pn]}
                echo -e "$pnx" | awk '{printf "%c",$1}'
                echo -e "$pnx" | awk '{printf "%c",$1}' >> $dimm_info
            done
            printf " \n"
            printf " \n" >> $dimm_info
            # Read DIMM date code
            mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0x80,0x04 -r 0x40)
            dc0=${spd_data[3]}
            dc1=${spd_data[4]}
            echo -n "  Date: WW "
            echo -e "$dc1" | awk '{printf "%2x",$1}'
            echo -n " Year 20"
            echo -e "$dc0" | awk '{printf "%2x",$1}'
            printf "\n----------------------------------\n"

            echo -n "  Date: WW "                           >> $dimm_info
            echo -e "$dc1" | awk '{printf "%2x",$1}'        >> $dimm_info
            echo -n " Year 20"                              >> $dimm_info
            echo -e "$dc0" | awk '{printf "%2x",$1}'        >> $dimm_info
            printf "\n----------------------------------\n" >> $dimm_info

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
