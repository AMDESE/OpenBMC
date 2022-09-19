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
   "61"|"64")  # Sunstone board_ids
        ln -s /usr/share/swampd/sunstone-stepwise-config.json /usr/share/swampd/config.json
   ;;
   "63")  # Cinnabar board_ids
        ln -s /usr/share/swampd/cinnabar-stepwise-config.json /usr/share/swampd/config.json
   ;;
   "59"|"62"|"65")  # Shale board_ids
        ln -s /usr/share/swampd/shale-stepwise-config.json /usr/share/swampd/config.json
   ;;
   *)  # Default set to Sunstone board, as it have most fans connected
        ln -s /usr/share/swampd/sunstone-stepwise-config.json /usr/share/swampd/config.json
esac

