#!/bin/bash
# Set all the fans to run at full speed at boot time

set -e

boardID=0

# First remove the old link to make sure we set correct path
rm -f /usr/share/swampd/config.json

# Read Board ID from u-boot env
boardID=`fw_printenv board_id | sed -n "s/^board_id=//p"`

# Set soflink for platform dependent config.json file
case $boardID in
   "68"|"70"|"71")  # Galena board_ids
        ln -s /usr/share/swampd/galena-stepwise-config.json /usr/share/swampd/config.json
   ;;
   "69")  # Recluse board_ids
        ln -s /usr/share/swampd/recluse-stepwise-config.json /usr/share/swampd/config.json
   ;;
   "66"|"6E"|"6F")  # Chalupa board_ids
        ln -s /usr/share/swampd/chalupa-stepwise-config.json /usr/share/swampd/config.json
   ;;
   "6A"|"72"|"73")  # Purico board_ids
        ln -s /usr/share/swampd/purico-stepwise-config.json /usr/share/swampd/config.json
   ;;
   "6B"|"74"|"75")  # Volcano board_ids
        ln -s /usr/share/swampd/volcano-stepwise-config.json /usr/share/swampd/config.json
   ;;
   "67")  # Huambo board_ids
        ln -s /usr/share/swampd/huambo-stepwise-config.json /usr/share/swampd/config.json
   ;;
   *)  # Default set to Chalupa board, as it have most fans connected
        ln -s /usr/share/swampd/chalupa-stepwise-config.json /usr/share/swampd/config.json
esac

