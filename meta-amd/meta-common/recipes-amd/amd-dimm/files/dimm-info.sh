#!/bin/bash

num_of_cpu=`/sbin/fw_printenv -n num_of_cpu`
dimm_per_ch=`/sbin/fw_printenv -n dimm_per_ch`
dimm_per_bus=`/sbin/fw_printenv -n dimm_per_bus`
por_rst=`/sbin/fw_printenv -n por_rst`
max_loop_cnt=1
I3C_TOOL="/usr/bin/i3ctransfer"
LOG_DIR="/var/lib/dimm"
dimm_sh="${LOG_DIR}/dimm.sh"
dimm_info="${LOG_DIR}/dimm_info.txt"
SET_PROP="busctl set-property xyz.openbmc_project.Inventory.Manager /xyz/openbmc_project/inventory/system/chassis/motherboard/"
ITEM_DIMM="xyz.openbmc_project.Inventory.Item.Dimm"

# check for Volcano and Purico system and exit
board_id=`fw_printenv board_id | sed -n "s/^board_id=//p"`

case $board_id in
       "6A" | "72" | "73" | "6B"| "74" | "75" | "7F")  # Purico or Volcano
            echo "Lenovo Turin system " $board_id " do not run dimm-info "
            exit
       ;;
esac

power_status() {
        st=$(busctl get-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis CurrentPowerState | cut -d"." -f6)
        if [ "$st" == "On\"" ]; then
                echo "on"
        else
                echo "off"
        fi
}

if [ $num_of_cpu == 2 ];then
    max_loop_cnt=2
fi

if [ $dimm_per_ch == 2 ];then
    dpc2="true"
    max_loop_cnt=2
else
    dpc2="false"
fi

echo "Board ID = " $board_id " Num of CPU = " $num_of_cpu " DPC = " $dimm_per_ch " 2DPC = " $dpc2 " DIMM per Bus = " $dimm_per_bus

# check for POR
if [ "$por_rst" != "true" ]; then
    echo "Not Power On Reset (AC Cycle), Run dimm.sh"
    echo "Not Power On Reset (AC Cycle), Run dimm.sh" >> $dimm_info
    $dimm_sh
    exit
fi

# check for Power State
power_state=$(power_status)
if [ "$power_state" == "on" ]; then
    echo "DIMMs not re-scanned because Host Power is On (S0 State) "
    echo "Retrieving existing DIMM information from BMC file system "
    $dimm_sh
    exit
fi

# re-bind I3C buses
dimm-re-bind.sh

# check for LOG Dir
if [ -d "$LOG_DIR" ]; then
    echo $LOG_DIR "exist"
else
    mkdir $LOG_DIR
fi

# BMC has access to I3C
i3cid=0
sock_id=0
channel=0
dimmNum=0
bus_type=unknown
module_type=reserved
package_density=0
io_width=0
num_ranks=0
vendor=0

#remove DIMM info files from prev read
rm $dimm_sh
rm $dimm_info
echo "#!/bin/bash" >> $dimm_sh
chmod 777 $dimm_sh

while [[ $sock_id < $max_loop_cnt ]]
do
    for i3c_bus_per_soc in 1 2
    do
        # Check if at least one DIMM present on this BUS
        ls /dev/i3c-${i3cid}-* > /dev/null 2>&1
        if [[ $? -ne 0 ]]
        then
            echo "No dimms detected on S"${sock_id} "I3C_Bus"${i3cid}
            echo "No dimms detected on S"${sock_id} "I3C_Bus"${i3cid} >> $dimm_info
            # No DIMMs on this I3C bus
            (( i3cid += 1))
            (( channel += dimm_per_bus ))
            continue
        fi
        # This section reads various SPD bytes and provides dimm info
        for (( dimm=0; dimm<dimm_per_bus; dimm++ ))
        do
            (( dimmNum = (i3cid * dimm_per_bus)+(dimm) ))
            # Driver generated I3C name for this dimm
            pmic_name="/dev/i3c-${i3cid}-2040000000${dimm}"
            spd_name="/dev/i3c-${i3cid}-3c00000000${dimm}"

            if [ $dimm_per_bus == 3 ];then
                case "$dimmNum" in
                "0")
                    dimmID=P0_DIMM_A
                ;;
                "1")
                    dimmID=P0_DIMM_B
                ;;
                "2")
                    dimmID=P0_DIMM_D
                ;;
                "3")
                    dimmID=P0_DIMM_E
                ;;
                "4")
                    dimmID=P0_DIMM_F
                ;;
                "5")
                    dimmID=P0_DIMM_H
                ;;
                "6")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_A1
                    else
                        dimmID=P1_DIMM_A
                    fi
                ;;
                "7")
                if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_B1
                    else
                        dimmID=P1_DIMM_B
                    fi
                ;;
                "8")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_D1
                    else
                        dimmID=P1_DIMM_D
                    fi
                ;;
                "9")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_E1
                    else
                        dimmID=P1_DIMM_E
                    fi
                ;;
                "10")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_F1
                    else
                        dimmID=P1_DIMM_F
                    fi
                ;;
                "11")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_H1
                    else
                        dimmID=P1_DIMM_H
                    fi
                ;;
                *)
                    echo "wrong DIMM Number " $dimmNum
                    echo "wrong DIMM Number " $dimmNum >> $dimm_info
                    exit
                ;;
                esac
            else
                case "$dimmNum" in
                "0")
                    dimmID=P0_DIMM_A
                ;;
                "1")
                    dimmID=P0_DIMM_B
                ;;
                "2")
                    dimmID=P0_DIMM_C
                ;;
                "3")
                    dimmID=P0_DIMM_D
                ;;
                "4")
                    dimmID=P0_DIMM_E
                ;;
                "5")
                    dimmID=P0_DIMM_F
                ;;
                "6")
                    dimmID=P0_DIMM_G
                ;;
                "7")
                    dimmID=P0_DIMM_H
                ;;
                "8")
                    dimmID=P0_DIMM_I
                ;;
                "9")
                    dimmID=P0_DIMM_J
                ;;
                "10")
                    dimmID=P0_DIMM_K
                ;;
                "11")
                    dimmID=P0_DIMM_L
                ;;
                "12")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_A1
                    else
                        dimmID=P1_DIMM_A
                    fi
                ;;
                "13")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_B1
                    else
                        dimmID=P1_DIMM_B
                    fi
                ;;
                "14")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_C1
                    else
                        dimmID=P1_DIMM_C
                    fi
                ;;
                "15")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_D1
                    else
                        dimmID=P1_DIMM_D
                    fi
                ;;
                "16")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_E1
                    else
                        dimmID=P1_DIMM_E
                    fi
                ;;
                "17")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_F1
                    else
                        dimmID=P1_DIMM_F
                    fi
                ;;
                "18")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_G1
                    else
                        dimmID=P1_DIMM_G
                    fi
                ;;
                "19")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_H1
                    else
                        dimmID=P1_DIMM_H
                    fi
                ;;
                "20")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_I1
                    else
                        dimmID=P1_DIMM_I
                    fi
                ;;
                "21")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_J1
                    else
                        dimmID=P1_DIMM_J
                    fi
                ;;
                "22")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_K1
                    else
                        dimmID=P1_DIMM_K
                    fi
                ;;
                "23")
                    if [ "$dpc2" == "true" ]; then
                        dimmID=P0_DIMM_L1
                    else
                        dimmID=P1_DIMM_L
                    fi
                ;;
                *)
                    echo "wrong DIMM Number " $dimmNum
                    echo "wrong DIMM Number " $dimmNum >> $dimm_info
                    exit
                ;;
                esac
            fi

            echo "--------------------------"
            echo $dimmID
            echo "--------------------------" >> $dimm_info
            echo $dimmID                   >> $dimm_info
            # Check if DIMM is present
            $I3C_TOOL -d ${spd_name} -w 0x80,0x00 -r 0x1 > /dev/null 2>&1
            if [[ $? -ne 0 ]]
            then
                # DIMM not present
                echo "\"Status\" : \"Absent\""
                echo "\"Status\" : \"Absent\"" >> $dimm_info
                echo $SET_PROP$dimmID $ITEM_DIMM "MemorySizeInKB u 0" >> $dimm_sh
                $SET_PROP$dimmID $ITEM_DIMM MemorySizeInKB u 0
                continue
            fi
            echo "\"Status\" : \"Enabled\""
            echo "\"Status\" : \"Enabled\"" >> $dimm_info

            # DDR5 I3C DIMMs info
            id=$(( channel + dimm ))

            # Read DIMM Protocol Type
            mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0x80,0x00 -r 0x40)
            if [[ ${spd_data[2]} -eq "0x12" ]]
            then
                bus_type=DDR5
                $SET_PROP$dimmID $ITEM_DIMM MemoryType s "xyz.openbmc_project.Inventory.Item.Dimm.DeviceType.DDR5"
                echo $SET_PROP$dimmID $ITEM_DIMM "MemoryType s \"xyz.openbmc_project.Inventory.Item.Dimm.DeviceType.DDR5\"" >> $dimm_sh
                $SET_PROP$dimmID $ITEM_DIMM ECC s "xyz.openbmc_project.Inventory.Item.Dimm.Ecc.SingleBitECC"
                echo $SET_PROP$dimmID $ITEM_DIMM "ECC s \"xyz.openbmc_project.Inventory.Item.Dimm.Ecc.SingleBitECC\"" >> $dimm_sh
            else
                bus_type=unsupported
            fi
            # Read DIMM module type
            # mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0x80,0x00 -r 0x40)
            if [[ ${spd_data[3]} -eq "0x01" ]]
            then
                module_type=RDIMM
                $SET_PROP$dimmID $ITEM_DIMM FormFactor s "xyz.openbmc_project.Inventory.Item.Dimm.FormFactor.RDIMM"
                echo $SET_PROP$dimmID $ITEM_DIMM "FormFactor s \"xyz.openbmc_project.Inventory.Item.Dimm.FormFactor.RDIMM\"" >> $dimm_sh
            elif [[ ${spd_data[3]} -eq "0x04" ]]
            then
                module_type=LRDIMM
                $SET_PROP$dimmID $ITEM_DIMM FormFactor s "xyz.openbmc_project.Inventory.Item.Dimm.FormFactor.LRDIMM"
                echo $SET_PROP$dimmID $ITEM_DIMM "FormFactor s \"xyz.openbmc_project.Inventory.Item.Dimm.FormFactor.LRDIMM\"" >> $dimm_sh
            else
                module_type=Reserved
            fi

            # Read Supported DDR Speed
            # mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0x80,0x00 -r 0x40)
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
            # mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0x80,0x00 -r 0x40)
            package_density=${spd_data[4]}
            package=$(($package_density >> 5))
            density=$(($package_density & 0x0f))
            spdDensity=$(($package_density & 0x0f))

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
                # 16 GB
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
            # mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0x80,0x00 -r 0x40)
            io_width=$((${spd_data[6]} >> 5))

            if [[ $io_width -eq "0" ]]
            then
                io_width=x4
                spd_iowidth=4
            elif [[ $io_width -eq "1" ]]
            then
                io_width=x8
                spd_iowidth=8
            elif [[ $io_width -eq "2" ]]
            then
                io_width=x16
                spd_iowidth=16
            else
                io_width=unsupported
                spd_iowidth=0
            fi

            $SET_PROP$dimmID $ITEM_DIMM MemoryDataWidth q $spd_iowidth
            echo $SET_PROP$dimmID $ITEM_DIMM " MemoryDataWidth q " $spd_iowidth >> $dimm_sh

            # Read Number of Ranks
            mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0xC0,0x01 -r 0x40)
            busWidth1=${spd_data[43]}
            busWidth=$(($busWidth1 & 0x1f))
            if [[ $busWidth -eq "0x12" ]]
            then
                busWidth=80
            elif [[ $busWidth -eq "0x0A" ]]
            then
                busWidth=72
            else
                busWidth=64
            fi
            $SET_PROP$dimmID $ITEM_DIMM MemoryTotalWidth q $busWidth
            echo $SET_PROP$dimmID $ITEM_DIMM MemoryTotalWidth q $busWidth >> $dimm_sh
            pmic1Mfg1=${spd_data[6]}
            pmic1Mfg2=${spd_data[7]}
            pmic1Type=${spd_data[8]}
            pmic2Mfg1=${spd_data[10]}
            pmic2Mfg2=${spd_data[11]}
            pmic2Type=${spd_data[12]}
            pmic3Mfg1=${spd_data[14]}
            pmic3Mfg2=${spd_data[15]}
            pmic3Type=${spd_data[16]}
            $SET_PROP$dimmID $ITEM_DIMM MemoryTypeDetail s "PMIC1:$pmic1Mfg1,$pmic1Mfg2,$pmic1Type PMIC2:$pmic2Mfg1,$pmic2Mfg2,$pmic2Type PMIC3:$pmic3Mfg1,$pmic3Mfg2,$pmic3Type"
            echo $SET_PROP$dimmID $ITEM_DIMM " MemoryTypeDetail s  " \"PMIC1:$pmic1Mfg1,$pmic1Mfg2,$pmic1Type PMIC2:$pmic2Mfg1,$pmic2Mfg2,$pmic2Type PMIC3:$pmic3Mfg1,$pmic3Mfg2,$pmic3Type\" >> $dimm_sh

            num_ranks=$((${spd_data[42]} >> 3))

            if [[ $num_ranks -eq "0" ]]
            then
                num_ranks=1
            elif [[ $num_ranks -eq "1" ]]
            then
                num_ranks=2
            elif [[ $num_ranks -eq "3" ]]
            then
                num_ranks=4
            else
                num_ranks=0
            fi

            # Determine Total Capacity
            if  [[ $density == "16Gb" ]]
            then
                if [[ $io_width == "x8" ]]
                then
                    if [[ $num_ranks == 1 ]]
                    then
                        # 16 GB
                        capacity=16384000
                    elif [[ $num_ranks == 2 ]]
                    then
                        # 32 GB
                        capacity=32768000
                    elif [[ $num_ranks == 4 ]]
                    then
                        # 64 GB
                        capacity=65536000
                    else
                        capacity=Undefined
                    fi
                elif [[ $io_width == "x4" ]]
                then
                    if [[ $num_ranks == 1 ]]
                    then
                        # 32 GB
                        capacity=32768000
                    elif [[ $num_ranks == 2 ]]
                    then
                        if [[ $package == "(2H)3DS" ]]
                        then
                            # 128 GB
                            capacity=131072000
                        elif [[ $package == "(4H) 3DS" ]]
                        then
                            # 256 GB
                            capacity=262144000
                        else
                            # 64 GB
                            capacity=65536000
                        fi
                    elif [[ $num_ranks == 4 ]]
                    then
                        # 128 GB
                        capacity=131072000
                    else
                        capacity=0
                    fi
                else
                    capacity=0
                fi
            elif [[ $density == "24Gb" ]]
            then
                if [[ $io_width == "x8" ]]
                then
                    if [[ $num_ranks == 1 ]]
                    then
                        # 24 GB
                        capacity=24576000
                    elif [[ $num_ranks == 2 ]]
                    then
                        # 48 GB
                        capacity=49152000
                    elif [[ $num_ranks == 4 ]]
                    then
                        # 96 GB
                        capacity=98304000
                    else
                        capacity=0
                    fi
                elif [[ $io_width == "x4" ]]
                then
                    if [[ $num_ranks == 1 ]]
                    then
                        # 48 GB
                        capacity=49152000
                    elif [[ $num_ranks == 2 ]]
                    then
                        if [[ $package == "(2H)3DS" ]]
                        then
                            # 192 GB
                            capacity=196608000
                        elif [[ $package == "(4H) 3DS" ]]
                        then
                            # 384 GB
                            capacity=393216000
                        else
                            # 96 GB
                            capacity=98304000
                        fi
                    elif [[ $num_ranks == 4 ]]
                    then
                        # 192 GB
                        capacity=196608000
                    else
                        capacity=0
                    fi
                else
                    capacity=0
                fi
            else
                capacity=0
            fi

            echo $SET_PROP$dimmID $ITEM_DIMM "MemorySizeInKB u " $capacity  >> $dimm_sh
            $SET_PROP$dimmID $ITEM_DIMM MemorySizeInKB u $capacity

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

            echo $SET_PROP$dimmID $ITEM_DIMM "MemoryDeviceLocator s" \"$dimmID\" >> $dimm_sh
            $SET_PROP$dimmID $ITEM_DIMM MemoryDeviceLocator s $dimmID

            $SET_PROP$dimmID $ITEM_DIMM MemoryConfiguredSpeedInMhz q $speed
            echo $SET_PROP$dimmID $ITEM_DIMM " MemoryConfiguredSpeedInMhz q " $speed >> $dimm_sh

            $SET_PROP$dimmID $ITEM_DIMM Manufacturer s $vendor1
            echo $SET_PROP$dimmID $ITEM_DIMM " Manufacturer s " $vendor1 >> $dimm_sh

            $SET_PROP$dimmID $ITEM_DIMM MemoryAttributes y $num_ranks
            echo $SET_PROP$dimmID $ITEM_DIMM "MemoryAttributes y " $num_ranks  >> $dimm_sh

            modelRcd=$(printf '%s 0x%2x' $rcd  $rcd_rev)
            $SET_PROP$dimmID $ITEM_DIMM Model s "RCD: $rcd $rcd_rev"
            echo $SET_PROP$dimmID $ITEM_DIMM " Model s " \"RCD: $rcd $rcd_rev\"  >> $dimm_sh
            echo "\"RCD\"" ":" \"$rcd $rcd_rev\" >> $dimm_info

            # Read DIMM Part Number
            mapfile -s 3  -t spd_data < <($I3C_TOOL -d ${spd_name} -w 0x80,0x04 -r 0x40)
            spdPN1=$(echo -e   "${spd_data[9]}"  | awk '{printf "%c",$1}')
            spdPN2=$(echo -e   "${spd_data[10]}" | awk '{printf "%c",$1}')
            spdPN3=$(echo -e   "${spd_data[11]}" | awk '{printf "%c",$1}')
            spdPN4=$(echo -e   "${spd_data[12]}" | awk '{printf "%c",$1}')
            spdPN5=$(echo -e   "${spd_data[13]}" | awk '{printf "%c",$1}')
            spdPN6=$(echo -e   "${spd_data[14]}" | awk '{printf "%c",$1}')
            spdPN7=$(echo -e   "${spd_data[15]}" | awk '{printf "%c",$1}')
            spdPN8=$(echo -e   "${spd_data[16]}" | awk '{printf "%c",$1}')
            spdPN9=$(echo -e   "${spd_data[17]}" | awk '{printf "%c",$1}')
            spdPN10=$(echo -e  "${spd_data[18]}" | awk '{printf "%c",$1}')
            spdPN11=$(echo -e  "${spd_data[19]}" | awk '{printf "%c",$1}')
            spdPN12=$(echo -e  "${spd_data[20]}" | awk '{printf "%c",$1}')
            spdPN13=$(echo -e  "${spd_data[21]}" | awk '{printf "%c",$1}')
            spdPN14=$(echo -e  "${spd_data[22]}" | awk '{printf "%c",$1}')
            spdPN15=$(echo -e  "${spd_data[23]}" | awk '{printf "%c",$1}')
            spdPN16=$(echo -e  "${spd_data[24]}" | awk '{printf "%c",$1}')
            spdPN=$spdPN1$spdPN2$spdPN3$spdPN4$spdPN5$spdPN6$spdPN7$spdPN8$spdPN9$spdPN10$spdPN11$spdPN12$spdPN13$spdPN14$spdPN15$spdPN16
            $SET_PROP$dimmID $ITEM_DIMM PartNumber s $spdPN
            echo $SET_PROP$dimmID $ITEM_DIMM PartNumber s $spdPN  >> $dimm_sh

            # Read DIMM Serial Number
            spdSN=$(printf '%02x%02x%02x%02x' ${spd_data[5]} ${spd_data[6]} ${spd_data[7]} ${spd_data[8]})
            $SET_PROP$dimmID $ITEM_DIMM SerialNumber s $spdSN
            echo $SET_PROP$dimmID $ITEM_DIMM " SerialNumber s " $spdSN >> $dimm_sh

            # Read DIMM date code
            dc0=${spd_data[3]}
            dc1=${spd_data[4]}
            spdDate=$(printf '%02x%02x' $dc0 $dc1)
            $SET_PROP$dimmID $ITEM_DIMM RevisionCode q $spdDate
            echo $SET_PROP$dimmID $ITEM_DIMM " RevisionCode q " $spdDate >> $dimm_sh

            # Print dimm info
            echo "\"Model\" : \"$bus_type\""
            echo "\"BaseModuleType\" : \"$module_type\""
            echo "\"Package\" : \"$package\""
            capacityMB=$(( capacity / 1024 ))
            echo "\"CapacityMB\" : \"$capacityMB\""
            echo "\"Density\" : \"$density\""
            echo "\"IO Width\" : \"$io_width\""
            echo "\"Bus Width\" : \"$busWidth\""
            echo "\"RankCount\" : \"$num_ranks\""
            echo "\"OperatingSpeedMhz\" : \"$speed\""
            echo "\"Manufacturer\" : \"$vendor1\""
            printf "\"PartNumber\" : \"%s\" \n" $spdPN
            printf "\"SerialNumber\" : \"%s\" \n" $spdSN
            echo -n "\"Date\" : \"WW "
            echo -e "$dc1" | awk '{printf "%2x",$1}'
            echo -n " Year 20"
            echo -e "$dc0" | awk '{printf "%2x",$1}'
            printf "\"\n"
            echo "\"PMIC Vendor ID\" : \"PMIC1:$pmic1Mfg1,$pmic1Mfg2,$pmic1Type PMIC2:$pmic2Mfg1,$pmic2Mfg2,$pmic2Type PMIC3:$pmic3Mfg1,$pmic3Mfg2,$pmic3Type\""
            # Save dimm_info
            echo "\"Model\" : \"$bus_type\""               >> $dimm_info
            echo "\"BaseModuleType\" : \"$module_type\""   >> $dimm_info
            echo "\"Package\" : \"$package\""              >> $dimm_info
            echo "\"CapacityMB\" : \"$capacityMB \""       >> $dimm_info
            echo "\"Density\" : \"$density\""              >> $dimm_info
            echo "\"IO Width\" : \"$io_width\""            >> $dimm_info
            echo "\"Bus Width\" : \"$busWidth\""           >> $dimm_info
            echo "\"RankCount\" : \"$num_ranks\""          >> $dimm_info
            echo "\"OperatingSpeedMhz\" : \"$speed\""      >> $dimm_info
            echo "\"Manufacturer\" : \"$vendor1\""         >> $dimm_info
            printf "\"PartNumber\" : \"%s\" \n" $spdPN     >> $dimm_info
            printf "\"SerialNumber\" : \"%s\" \n" $spdSN   >> $dimm_info
            echo -n "\"Date\" : \"WW "                     >> $dimm_info
            echo -e "$dc1" | awk '{printf "%2x",$1}'       >> $dimm_info
            echo -n " Year 20"                             >> $dimm_info
            echo -e "$dc0" | awk '{printf "%2x",$1}'       >> $dimm_info
            printf "\"\n"                                  >> $dimm_info
            echo "\"PMIC Vendor ID\" : \"PMIC1:$pmic1Mfg1,$pmic1Mfg2,$pmic1Type PMIC2:$pmic2Mfg1,$pmic2Mfg2,$pmic2Type PMIC3:$pmic3Mfg1,$pmic3Mfg2,$pmic3Type\"" >> $dimm_info

        done # END of dimm loop

        (( channel += 6 ))
        (( i3cid += 1 ))

    done # END of i3c_bus_per_sock loop
    (( sock_id += 1 ))
done # END of num_sock loop
