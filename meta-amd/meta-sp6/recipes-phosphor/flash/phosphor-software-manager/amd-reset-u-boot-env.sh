#!/bin/sh
#
#Remove the u-boot env vars and /etc/hostname file
#to factory reset the MAC and hostname settings
#
# This solution is added to handle the frequent MAC changes at factory

set -e

echo "Resetting u-boot envs ..."

rm -f /etc/hostname
/sbin/fw_setenv ethaddr
/sbin/fw_setenv eth1addr
/sbin/fw_setenv bootargs console=ttyS4,115200n8 vmalloc=1024MB root=/dev/ram rw
/sbin/fw_setenv board_id
