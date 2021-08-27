#!/bin/bash

# HPM FPGA upgrade
# Below are the BMC GPIO settings to access HPM FPGA SPI flash
# GPIOs: [HPM_BMC_GPIOO1:HPM_BMC_GPIOO0]
#   	[00] = Run Mode
#   	[01] = Local BIOS SPI
#   	[10] = HPM FPGA SPI
#   	[11] = HPM LOM SPI
#

set +e

IMAGE_DIR=$1

GPIOCHIP=816
GPIOO0=$((${GPIOCHIP} + 112 + 0))
GPIOO1=$((${GPIOCHIP} + 112 + 1))

SPI_DEV="1e631000.spi"
SPI_PATH="/sys/bus/platform/drivers/aspeed-smc"

set_gpio_to_bmc()
{
    echo "switch HPM FPGA GPIO to bmc"
    if [ ! -d /sys/class/gpio/gpio$GPIOO0 ]; then
        cd /sys/class/gpio
        echo $GPIOO0 > export
        cd gpio$GPIOO0
    else
        cd /sys/class/gpio/gpio$GPIOO0
    fi
    direc=`cat direction`
    if [ $direc == "in" ]; then
        echo "out" > direction
    fi
    data=`cat value`
    if [ "$data" == "1" ]; then
        echo 0 > value
    fi

    if [ ! -d /sys/class/gpio/gpio$GPIOO1 ]; then
        cd /sys/class/gpio
        echo $GPIOO1 > export
        cd gpio$GPIOO1
    else
        cd /sys/class/gpio/gpio$GPIOO1
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

set_gpio_to_hpm_fpga()
{
    # Set back the GPIOO0 and GPIOO1 to Run Mode '00'
    echo "switch GPIO to HPM FPGA"
    if [ ! -d /sys/class/gpio/gpio$GPIOO0 ]; then
        cd /sys/class/gpio
        echo $GPIOO0 > export
        cd gpio$GPIOO0
    else
        cd /sys/class/gpio/gpio$GPIOO0
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
    echo $GPIOO0 > /sys/class/gpio/unexport

    if [ ! -d /sys/class/gpio/gpio$GPIOO1 ]; then
        cd /sys/class/gpio
        echo $GPIOO1 > export
        cd gpio$GPIOO1
    else
        cd /sys/class/gpio/gpio$GPIOO1
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
    echo $GPIOO1 > /sys/class/gpio/unexport

    return 0
}

echo "HPM FPGA upgrade started at $(date)"

#Flip GPIO to access SPI flash used by HPM FPGA.
echo "Set GPIO $GPIO to access SPI flash from BMC used by hpm fpga"
set_gpio_to_bmc

#Bind spi driver to access flash
echo "bind aspeed-smc spi driver"
echo -n $SPI_DEV > $SPI_PATH/bind
if [ $? -eq 0 ];
then
    echo "SPI Driver Bind Successful"
else
    echo "SPI Driver Bind Failed"
    set_gpio_to_hpm_fpga
    sleep 5
    exit -1
fi
sleep 1

#Flashcp image to device.
echo $IMAGE_DIR
pushd $IMAGE_DIR
IMAGE_FILE=$(find -type f -name '*.bin')
if [ -e "$IMAGE_FILE" ];
then
    echo "Hpm fpga image is $IMAGE_FILE"
    for d in mtd6 mtd7 ; do
        if [ -e "/dev/$d" ]; then
            mtd=`cat /sys/class/mtd/$d/name`
            if [ $mtd == "pnor" ]; then
                echo "Flashing hpm fpga image to $d..."
                flashcp -v $IMAGE_FILE /dev/$d
                if [ $? -eq 0 ]; then
                    echo "hpm fpga updated successfully..."
                else
                    echo "hpm fpga update failed..."
                fi
                break
            fi
            echo "$d is not a pnor device"
        fi
        echo "$d not available"
    done
else
    echo "Hpm fpga image $IMAGE_FILE doesn't exist"
fi
popd

#Unbind spi driver
sleep 1
echo "Unbind aspeed-smc spi driver"
echo -n $SPI_DEV > $SPI_PATH/unbind
sleep 10

#Flip GPIO back for HPM FPGA to access SPI flash
echo "Set GPIO $GPIO back for HPM FPGA to access SPI flash"
set_gpio_to_hpm_fpga
sleep 5

#reboot HOST
echo "WARNING!! AC POWER CYCLE required to activate HPM FPGA"
