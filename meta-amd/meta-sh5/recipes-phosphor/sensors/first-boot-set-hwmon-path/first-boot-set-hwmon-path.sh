#!/bin/sh -eu

boardID=0

sync_hwmon_path() {

    rm -f /etc/default/obmc/hwmon

    # Read Board ID from u-boot env
    boardID=`fw_printenv board_id | sed -n "s/^board_id=//p"`

    case $boardID in
           "3D"|"40"|"41"|"42"|"52")  # Onyx board_ids
                ln -s  /etc/default/obmc/hwmon_onyx/ /etc/default/obmc/hwmon
           ;;
           "5C"|"5D"|"5E"|"6C"|"6D")  # SH5 board_ids
                ln -s  /etc/default/obmc/hwmon_sh5d807/ /etc/default/obmc/hwmon
           ;;
           *)  # Default set to Onyx board
                ln -s  /etc/default/obmc/hwmon_sh5d807/ /etc/default/obmc/hwmon
    esac

}

# Set soft link for /etc/default/obmc/hwmon based on the platfrom
sync_hwmon_path
