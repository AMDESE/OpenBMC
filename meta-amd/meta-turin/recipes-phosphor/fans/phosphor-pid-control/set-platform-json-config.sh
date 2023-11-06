#!/bin/bash
# Set all the fans to run at full speed at boot time

set -e

boardID=0
CPU1Present=0

# First remove the old link to make sure we set correct path
rm -f /usr/share/swampd/config.json

# Read Board ID from u-boot env
boardID=`fw_printenv board_id | sed -n "s/^board_id=//p"`

# Check if CPU1 is present.
# load stepwise config of 1P config if 2nd socket not found
#
# <platform_name>-stepwise-config.json => 2P config (CPU0 and CPU1 sensors)
# <platform_name>1P-stepwise-config.json => 1P config (without CPU1 sensors)

if [ `gpioget 0 15` -eq 0 ] ; then
    CPU1Present=1
else
    CPU1Present=0
fi

# Set soflink for platform dependent config.json file
case $boardID in
   "68"|"70"|"71")  # Galena board_ids
        ln -s /usr/share/swampd/galena-stepwise-config.json /usr/share/swampd/config.json
   ;;
   "69")  # Recluse board_ids
        ln -s /usr/share/swampd/recluse-stepwise-config.json /usr/share/swampd/config.json
   ;;
   "66"|"6E"|"6F")  # Chalupa board_ids
        if [ $CPU1Present -eq 1 ] ; then
            ln -s /usr/share/swampd/chalupa-stepwise-config.json /usr/share/swampd/config.json
        else
            ln -s /usr/share/swampd/chalupa1P-stepwise-config.json /usr/share/swampd/config.json
        fi
   ;;
   "6A"|"72"|"73")  # Purico board_ids
        ln -s /usr/share/swampd/purico-stepwise-config.json /usr/share/swampd/config.json
   ;;
   "6B"|"74"|"75")  # Volcano board_ids
        if [ $CPU1Present -eq 1 ] ; then
            ln -s /usr/share/swampd/volcano-stepwise-config.json /usr/share/swampd/config.json
        else
            ln -s /usr/share/swampd/volcano1P-stepwise-config.json /usr/share/swampd/config.json
        fi
   ;;
   "67")  # Huambo board_ids
        if [ $CPU1Present -eq 1 ] ; then
            ln -s /usr/share/swampd/huambo-stepwise-config.json /usr/share/swampd/config.json
        else
            ln -s /usr/share/swampd/huambo1P-stepwise-config.json /usr/share/swampd/config.json
        fi
   ;;
   *)  # Default set to Chalupa board, as it have most fans connected
        ln -s /usr/share/swampd/chalupa-stepwise-config.json /usr/share/swampd/config.json
esac

