#!/bin/sh -eu

boardID=0

sync_hwmon_path() {

    rm -f /etc/default/obmc/hwmon

    # Read Board ID from u-boot env
    boardID=`fw_printenv board_id | sed -n "s/^board_id=//p"`
    case $boardID in
       "61"|"64")  # Sunstone board_ids
                ln -s  /etc/default/obmc/hwmon_sunstone/ /etc/default/obmc/hwmon
           ;;
       "63")  # Cinnabar board_ids
                ln -s  /etc/default/obmc/hwmon_cinnabar/ /etc/default/obmc/hwmon
           ;;
       "59"|"62"|"65")  # Shale board_ids
                ln -s  /etc/default/obmc/hwmon_shale/ /etc/default/obmc/hwmon
           ;;
           *)  # Default set to Sunstone board
                ln -s  /etc/default/obmc/hwmon_sunstone/ /etc/default/obmc/hwmon
    esac

}

# Set soft link for /etc/default/obmc/hwmon based on the platfrom
sync_hwmon_path
