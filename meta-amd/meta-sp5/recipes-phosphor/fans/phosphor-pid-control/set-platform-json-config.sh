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
   "3D"|"40"|"41"|"42"|"52")  # Onyx board_ids
        ln -s /usr/share/swampd/onyx-stepwise-config.json /usr/share/swampd/config.json
   ;;
   "3E"|"43"|"44"|"45"|"51")  # Quartz board_ids
        ln -s /usr/share/swampd/quartz-stepwise-config.json /usr/share/swampd/config.json
   ;;
   "46"|"47"|"48")  # Ruby board_ids
        ln -s /usr/share/swampd/ruby-stepwise-config.json /usr/share/swampd/config.json
   ;;
   "49"|"4A"|"4B"|"4C"|"4D"|"4E"|"4F")  # Titanite board_ids
        ln -s /usr/share/swampd/titanite-stepwise-config.json /usr/share/swampd/config.json
   ;;
   *)  # Default set to Quartz board, as it have most fans connected
        ln -s /usr/share/swampd/quartz-stepwise-config.json /usr/share/swampd/config.json
esac

