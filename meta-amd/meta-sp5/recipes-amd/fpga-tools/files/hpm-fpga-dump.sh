#!/bin/bash

# Read board_id from u-boot env
board_id=`/sbin/fw_printenv -n board_id`
case "$board_id" in
    "3d" | "3D" | "40" | "41" | "42" | "52")
        /usr/sbin/onyx-fpga-dump.sh
        ;;
    "46" | "47" | "48")
        /usr/sbin/ruby-fpga-dump.sh
        ;;
    "3e" | "3E" | "43" | "44" | "45" | "51")
        /usr/sbin/quartz-fpga-dump.sh
        ;;
    "49" | "4A" | "4a" | "4B" | "4b" | "4C" |"4c" | "4D" | "4d" | "4E" | "4e")
        /usr/sbin/titanite-fpga-dump.sh
        ;;
    *)
        echo " Unknown platform"
        echo " Please program board FRU EEPROM"
        ;;
esac
