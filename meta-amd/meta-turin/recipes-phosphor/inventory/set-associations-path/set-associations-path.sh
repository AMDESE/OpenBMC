#!/bin/sh -eu

boardID=0

sync_associations_path() {

    rm -f /usr/share/phosphor-inventory-manager/associations.json
    # Read Board ID from u-boot env
    boardID=`fw_printenv board_id | sed -n "s/^board_id=//p"`

    case $boardID in
        "68" | "70" | "71")  # Galena board_ids
            ln -s  /usr/share/phosphor-inventory-manager/galena-associations.json /usr/share/phosphor-inventory-manager/associations.json
        ;;
        "69")  # Recluse board_ids
            ln -s  /usr/share/phosphor-inventory-manager/recluse-associations.json /usr/share/phosphor-inventory-manager/associations.json
        ;;
        "6A" | "72" | "73")  # Purico board_ids
            ln -s  /usr/share/phosphor-inventory-manager/purico-associations.json /usr/share/phosphor-inventory-manager/associations.json
        ;;
        "66" | "6E" | "6F" )  # Chalupa board_ids
            ln -s  /usr/share/phosphor-inventory-manager/chalupa-associations.json /usr/share/phosphor-inventory-manager/associations.json
        ;;
        "67")  # Huambo board_ids
            ln -s  /usr/share/phosphor-inventory-manager/huambo-associations.json /usr/share/phosphor-inventory-manager/associations.json
        ;;
        "6B" | "74" | "75")  # Volcano board_ids
            ln -s  /usr/share/phosphor-inventory-manager/volcano-associations.json /usr/share/phosphor-inventory-manager/associations.json
        ;;
        *)  # Default set to galena board
            ln -s  /usr/share/phosphor-inventory-manager/galena-associations.json /usr/share/phosphor-inventory-manager/associations.json
    esac

}

# Set soft link for /etc/default/obmc/hwmon based on the platfrom
sync_associations_path
