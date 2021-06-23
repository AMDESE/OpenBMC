#!/bin/bash

set -e

POWER_CMD_OFF="busctl set-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis RequestedPowerTransition s xyz.openbmc_project.State.Chassis.Transition.Off"
POWER_CMD_ON="busctl set-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis RequestedPowerTransition s xyz.openbmc_project.State.Chassis.Transition.On"
IMAGE_DIR=$1

GPIOCHIP=816
GPIOV0=$((${GPIOCHIP} + 168 + 0))
GPIOV1=$((${GPIOCHIP} + 168 + 1))

SPI_DEV="1e630000.spi"
SPI_PATH="/sys/bus/platform/drivers/aspeed-smc"

power_status() {
	st=$(busctl get-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis CurrentPowerState | cut -d"." -f6)
	if [ "$st" == "On\"" ]; then
		echo "on"
	else
		echo "off"
	fi
}

set_gpio_to_bmc()
{
    echo "switch bios GPIO to bmc"
    if [ ! -d /sys/class/gpio/gpio$GPIOV0 ]; then
        cd /sys/class/gpio
        echo $GPIOV0 > export
        cd gpio$GPIOV0
    else
        cd /sys/class/gpio/gpio$GPIOV0
    fi
    direc=`cat direction`
    if [ $direc == "in" ]; then
        echo "out" > direction
    fi
    data=`cat value`
    if [ "$data" == "0" ]; then
        echo 1 > value
    fi

    if [ ! -d /sys/class/gpio/gpio$GPIOV1 ]; then
        cd /sys/class/gpio
        echo $GPIOV1 > export
        cd gpio$GPIOV1
    else
        cd /sys/class/gpio/gpio$GPIOV1
    fi
    direc=`cat direction`
    if [ $direc == "in" ]; then
        echo "out" > direction
    fi
    data=`cat value`
    if [ "$data" == "0" ]; then
        echo 1 > value
    fi

    return 0
}

set_gpio_to_host()
{
    echo "switch bios GPIO to host"
    if [ ! -d /sys/class/gpio/gpio$GPIOV0 ]; then
        cd /sys/class/gpio
        echo $GPIOV0 > export
        cd gpio$GPIOV0
    else
        cd /sys/class/gpio/gpio$GPIOV0
    fi
    direc=`cat direction`
    if [ $direc == "in" ]; then
        echo "out" > direction
    fi
    data=`cat value`
    if [ "$data" == "1" ]; then
        echo 0 > value
    fi
    echo "in" > direction
    echo $GPIOV0 > /sys/class/gpio/unexport

    if [ ! -d /sys/class/gpio/gpio$GPIOV1 ]; then
        cd /sys/class/gpio
        echo $GPIOV1 > export
        cd gpio$GPIOV1
    else
        cd /sys/class/gpio/gpio$GPIOV1
    fi
    direc=`cat direction`
    if [ $direc == "in" ]; then
        echo "out" > direction
    fi
    data=`cat value`
    if [ "$data" == "1" ]; then
        echo 0 > value
    fi
    echo "in" > direction
    echo $GPIOV1 > /sys/class/gpio/unexport

    return 0
}

echo "Bios upgrade started at $(date)"

#Power off host server.
echo "Power off host server"
#The following lines to be uncommented, once amd-power-control application is enabled
#$POWER_CMD_OFF
#sleep 15
#if [ $(power_status) != "off" ];
#then
#    echo "Host server didn't power off"
#    echo "Bios upgrade failed"
#    exit -1
#fi
echo "Host server powered off"


#Flip GPIO to access SPI flash used by host.
echo "Set GPIO $GPIO to access SPI flash from BMC used by host"
set_gpio_to_bmc

#Bind spi driver to access flash
echo "bind aspeed-smc spi driver"
echo -n $SPI_DEV > $SPI_PATH/bind
sleep 1

#Flashcp image to device.
echo $IMAGE_DIR
pushd $IMAGE_DIR
IMAGE_FILE=$(find -type f -name '*.FD')
if [ -e "$IMAGE_FILE" ];
then
    echo "Bios image is $IMAGE_FILE"
    for d in mtd6 mtd7 ; do
        if [ -e "/dev/$d" ]; then
            mtd=`cat /sys/class/mtd/$d/name`
            if [ $mtd == "pnor" ]; then
                echo "Flashing bios image to $d..."
                dd if=$IMAGE_FILE of=/dev/$d bs=4096
                if [ $? -eq 0 ]; then
                    echo "bios updated successfully..."
                else
                    echo "bios update failed..."
                fi
                break
            fi
            echo "$d is not a pnor device"
        fi
        echo "$d not available"
    done
else
    echo "Bios image $IMAGE_FILE doesn't exist"
fi
popd

#Unbind spi driver
sleep 1
echo "Unbind aspeed-smc spi driver"
echo -n $SPI_DEV > $SPI_PATH/unbind
sleep 10

#Flip GPIO back for host to access SPI flash
echo "Set GPIO $GPIO back for host to access SPI flash"
set_gpio_to_host
sleep 5

