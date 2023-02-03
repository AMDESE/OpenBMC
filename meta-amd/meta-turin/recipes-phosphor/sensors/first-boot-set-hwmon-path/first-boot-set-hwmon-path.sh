#!/bin/sh -eu

boardID=0

sync_hwmon_path() {

    rm -f /etc/default/obmc/hwmon

    # Read Board ID from u-boot env
    boardID=`fw_printenv board_id | sed -n "s/^board_id=//p"`

    case $boardID in
           "68" | "70" | "71")  # galena board_ids
                ln -s  /etc/default/obmc/hwmon_galena/ /etc/default/obmc/hwmon
           ;;
           "69")  # recluse board_ids
                ln -s  /etc/default/obmc/hwmon_recluse/ /etc/default/obmc/hwmon
           ;;
           "6A" | "72" | "73")  # purico board_ids
                ln -s  /etc/default/obmc/hwmon_purico/ /etc/default/obmc/hwmon
           ;;
           "66"| "6E" | "6F")  # chalupa board_ids
                ln -s  /etc/default/obmc/hwmon_chalupa/ /etc/default/obmc/hwmon
           ;;
           "67")  # huambo board_ids
                ln -s  /etc/default/obmc/hwmon_huambo/ /etc/default/obmc/hwmon
           ;;
           "6B"| "74" | "75")  # volcano board_ids
                ln -s  /etc/default/obmc/hwmon_volcano/ /etc/default/obmc/hwmon
           ;;
           *)  # Default set to galena board
                ln -s  /etc/default/obmc/hwmon_galena/ /etc/default/obmc/hwmon
    esac
}

# Set soft link for /etc/default/obmc/hwmon based on the platfrom
sync_hwmon_path
