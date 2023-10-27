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
   "5C"|"5D"|"5E"|"6C"|"6D")  # SH5 board_ids
        ln -s /usr/share/swampd/sh5-stepwise-config.json /usr/share/swampd/config.json
   ;;
   *)  # Default set to Sh5 board, as it have most fans connected
        ln -s /usr/share/swampd/sh5-stepwise-config.json /usr/share/swampd/config.json
esac

