#!/bin/bash

set -e

IMAGE_DIR=$1

GPIOCHIP=816
GPIOV0=$((${GPIOCHIP} + 168 + 0))
GPIOV1=$((${GPIOCHIP} + 168 + 1))

SPI_DEV="1e630000.spi"
SPI_PATH="/sys/bus/platform/drivers/aspeed-smc"

set_gpio_to_bmc()
{
    echo "switch SCM FPGA GPIO to bmc"
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
    if [ "$data" == "1" ]; then
        echo 0 > value
    fi

    return 0
}

set_gpio_to_scm_fpga()
{
    echo "switch GPIO to SCM FPGA"
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

echo "SCM FPGA upgrade started at $(date)"

#Flip GPIO to access SPI flash used by SCM FPGA.
echo "Set GPIO $GPIO to access SPI flash from BMC used by scm fpga"
set_gpio_to_bmc

#Bind spi driver to access flash
echo "bind aspeed-smc spi driver"
echo -n $SPI_DEV > $SPI_PATH/bind
sleep 1

#Flashcp image to device.
echo $IMAGE_DIR
pushd $IMAGE_DIR
IMAGE_FILE=$(find -type f -name '*.bin')
if [ -e "$IMAGE_FILE" ];
then
    echo "Scm fpga image is $IMAGE_FILE"
    for d in mtd6 mtd7 ; do
        if [ -e "/dev/$d" ]; then
            mtd=`cat /sys/class/mtd/$d/name`
            if [ $mtd == "pnor" ]; then
                echo "Flashing scm fpga image to $d..."
                flashcp -v $IMAGE_FILE /dev/$d
                if [ $? -eq 0 ]; then
                    echo "scm fpga updated successfully..."
                else
                    echo "scm fpga update failed..."
                fi
                break
            fi
            echo "$d is not a pnor device"
        fi
        echo "$d not available"
    done
else
    echo "Scm fpga image $IMAGE_FILE doesn't exist"
fi
popd

#Unbind spi driver
sleep 1
echo "Unbind aspeed-smc spi driver"
echo -n $SPI_DEV > $SPI_PATH/unbind
sleep 10

#Flip GPIO back for SCM FPGA to access SPI flash
echo "Set GPIO $GPIO back for SCM FPGA to access SPI flash"
set_gpio_to_scm_fpga
sleep 5

#reboot BMC
echo "WARNING!! AC POWER CYCLE required to activate SCM FPGA"
