#!/bin/sh -eu

boardID=0

sync_associations_path() {

    rm -f /usr/share/phosphor-inventory-manager/associations.json
    # Read Board ID from u-boot env
    boardID=`fw_printenv board_id | sed -n "s/^board_id=//p"`

    case $boardID in
       "61"|"64")  # Sunstone board_ids
            ln -s  /usr/share/phosphor-inventory-manager/sunstone-associations.json /usr/share/phosphor-inventory-manager/associations.json
       ;;
       "63")  # Cinnabar board_ids
            ln -s  /usr/share/phosphor-inventory-manager/cinnabar-associations.json /usr/share/phosphor-inventory-manager/associations.json
       ;;
       "59")  # Shale64 board_ids
            ln -s  /usr/share/phosphor-inventory-manager/shale64-associations.json /usr/share/phosphor-inventory-manager/associations.json
       ;;
       "62"|"65")  # Shale96 board_ids
            ln -s  /usr/share/phosphor-inventory-manager/shale96-associations.json /usr/share/phosphor-inventory-manager/associations.json
       ;;
       *)  # Default set to Sunstone board
            ln -s  /usr/share/phosphor-inventory-manager/sunstone-associations.json /usr/share/phosphor-inventory-manager/associations.json
    esac

}

# Set soft link for /etc/default/obmc/hwmon based on the platfrom
sync_associations_path
