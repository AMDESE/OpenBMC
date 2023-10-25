#!/bin/sh -eu

boardID=0

sync_associations_path() {

    rm -f /usr/share/phosphor-inventory-manager/associations.json
    # Read Board ID from u-boot env
    boardID=`fw_printenv board_id | sed -n "s/^board_id=//p"`

    case $boardID in
       "3D"|"40"|"41"|"42"|"52")  # Onyx board_ids
            ln -s  /usr/share/phosphor-inventory-manager/onyx-associations.json /usr/share/phosphor-inventory-manager/associations.json
       ;;
       "5C"|"5D"|"5E"|"6C"|"6D")  # SH5 board_ids
        ln -s  /usr/share/phosphor-inventory-manager/sh5d807-associations.json /usr/share/phosphor-inventory-manager/associations.json
       ;;
       *)  # Default set to sh5d807 board
        ln -s  /usr/share/phosphor-inventory-manager/sh5d807-associations.json /usr/share/phosphor-inventory-manager/associations.json
    esac
}

# Set soft link for /etc/default/obmc/hwmon based on the platfrom
sync_associations_path
