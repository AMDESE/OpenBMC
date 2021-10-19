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
           "3E"|"43"|"44"|"45"|"51")  # Quartz board_ids
                ln -s  /usr/share/phosphor-inventory-manager/quartz-associations.json /usr/share/phosphor-inventory-manager/associations.json
           ;;
           *)  # Default set to Quartz board
                ln -s  /usr/share/phosphor-inventory-manager/quartz-associations.json /usr/share/phosphor-inventory-manager/associations.json
    esac

}

# Set soft link for /etc/default/obmc/hwmon based on the platfrom
sync_associations_path
