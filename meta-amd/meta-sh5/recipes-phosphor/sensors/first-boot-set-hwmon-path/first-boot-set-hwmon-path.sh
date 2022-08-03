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
           "3E"|"43"|"44"|"45"|"51")  # Quartz board_ids
                ln -s  /etc/default/obmc/hwmon_quartz/ /etc/default/obmc/hwmon
           ;;
           "46"|"47"|"48")  # Ruby board_ids
                ln -s  /etc/default/obmc/hwmon_ruby/ /etc/default/obmc/hwmon
           ;;
           "49"|"4A"|"4B"|"4C"|"4D"|"4E")  # Titanite board_ids
                ln -s  /etc/default/obmc/hwmon_titanite/ /etc/default/obmc/hwmon
           ;;
           *)  # Default set to Onyx board
                ln -s  /etc/default/obmc/hwmon_onyx/ /etc/default/obmc/hwmon
    esac

}

# Set soft link for /etc/default/obmc/hwmon based on the platfrom
sync_hwmon_path
