#!/bin/bash

BACKUP_FILE=/etc/obmc-console/backup_conf

if [ "$#" -ne 1 ] ; then
        echo Choose UART for SOL - "default" or "espi"
        echo -e "example:\n\t $0 default\t(ttyS0)\n\t $0 espi\t\t(ttyVUART0/0x3F8)"
        exit
fi

disable_sol() {
        systemctl stop obmc-console@ttyS0.service
        systemctl stop obmc-console@ttyVUART0.service
        systemctl stop hostlogger@ttyS0.service
        systemctl stop hostlogger@ttyVUART0.service
}
# recover/recreate conf file
if [ "$1" == "reset" ] ; then
        echo -ne "local-tty = ttyS0\n" > /etc/obmc-console/server.ttyS0.conf
        echo -ne "baud = 115200\n" >> /etc/obmc-console/server.ttyS0.conf
        echo -ne "lpc-address = 0x3f8\n" > /etc/obmc-console/server.ttyVUART0.conf
        echo -ne "sirq = 4\n" >> /etc/obmc-console/server.ttyVUART0.conf
        [[ -f $BACKUP_FILE ]] && rm $BACKUP_FILE
        exit
fi
# status of services and conf for debug
if [ "$1" == "debug" ] ; then
        ls -al /etc/obmc-console/
        cat /etc/obmc-console/*
        ps | grep -i tty
        systemctl status obmc-console@ttyS0.service obmc-console@ttyVUART0.service
        systemctl status hostlogger@ttyS0.service hostlogger@ttyVUART0.service
fi
# set physical uart ttyS0 as SOL port
if [ "$1" == "default" ] ; then
        disable_sol
        [[ -f $BACKUP_FILE ]] && cat $BACKUP_FILE > /etc/obmc-console/server.ttyS0.conf
        cat /etc/obmc-console/server.ttyVUART0.conf > $BACKUP_FILE
        rm /etc/obmc-console/server.ttyVUART0.conf
        systemctl start obmc-console@ttyS0.service
        systemctl start hostlogger@ttyS0.service
        echo SOL set to uart ttyS0
fi
# set eSPI virtual uart as SOL port
if [ "$1" == "espi" ] ; then
        disable_sol
        [[ -f $BACKUP_FILE ]] && cat $BACKUP_FILE > /etc/obmc-console/server.ttyVUART0.conf
        cat /etc/obmc-console/server.ttyS0.conf > $BACKUP_FILE
        rm /etc/obmc-console/server.ttyS0.conf
        systemctl start obmc-console@ttyVUART0.service
        systemctl start hostlogger@ttyVUART0.service
        echo SOL set to eSPI virtual uart 0x3F8
fi

