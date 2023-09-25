#!/bin/bash

set +e

IMAGE_DIR=$1

GPIOCHIP=816
GPIOV0=$((${GPIOCHIP} + 168 + 0))
GPIOV1=$((${GPIOCHIP} + 168 + 1))

SPI_DEV="1e630000.spi"
SPI_PATH="/sys/bus/platform/drivers/aspeed-smc"

POWER_CMD_OFF="busctl set-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis RequestedPowerTransition s xyz.openbmc_project.State.Chassis.Transition.Off"
POWER_CMD_ON="busctl set-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis RequestedPowerTransition s xyz.openbmc_project.State.Chassis.Transition.On"

get_mtd_info() {
	mtd_num=1000    #/if spi is not detected, default to mtd1000 and fail
	spi_part=$(basename `find $SPI_PATH/$1/mtd/ -type d -maxdepth 1 | grep "mtd[6-9]$"`)
	mbsize=$(expr `cat $SPI_PATH/$1/mtd/*/size` / 1048576) # convert to MB (divide by 1024*1024)
	echo "SPI size: $mbsize MB"
	mtd_num=$spi_part
}

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

# Lanai Flash SPI is muxed to same fmc controller
# power-off lanai BIOS flash and unbind
power_state=$(power_status)
echo "Current Host state is $power_state"

if [ "$power_state" != "off" ];
then
#Power off host server.
echo "Power off host server"
$POWER_CMD_OFF
sleep 10
fi

if [ $(power_status) != "off" ];
then
    echo "Host server didn't power off"
    echo "SCM upgrade failed"
    exit -1
fi
echo "Host server powered off"

# stop SAFS application using Lanai SPI
systemctl stop safs-addr-translator.service
sleep 3

#Unbind spi driver to remove Lanai flash
sleep 1
echo "Unbind aspeed-smc spi driver"
echo -n $SPI_DEV > $SPI_PATH/unbind
sleep 5

#Flip GPIO to access SPI flash used by SCM FPGA.
echo "Set GPIO $GPIO to access SPI flash from BMC used by scm fpga"
set_gpio_to_bmc

#Bind spi driver to access flash
echo "bind aspeed-smc spi driver"
echo -n $SPI_DEV > $SPI_PATH/bind
if [ $? -eq 0 ];
then
    echo "SPI Driver Bind Successful"
else
    echo "SPI Driver Bind Failed.Run micron_v2.ini or micron_v3.ini using DediProg."
    set_gpio_to_scm_fpga
    sleep 5
    exit -1
fi
sleep 1

get_mtd_info $SPI_DEV
#Flashcp image to device.
echo $IMAGE_DIR
pushd $IMAGE_DIR
IMAGE_FILE=$(find -type f -name '*.bin')
if [ -e "$IMAGE_FILE" ];
then
    echo "Scm fpga image is $IMAGE_FILE"
    for d in $mtd_num ; do
        if [ -e "/dev/$d" ]; then
            mtd=`cat /sys/class/mtd/$d/name`
            if [ $mtd == "pnor" ]; then
                echo "Flashing scm fpga image to $d..."
                flash_eraseall /dev/$d
                dd if=$IMAGE_FILE of=/dev/$d bs=4096
                if [ $? -eq 0 ]; then
                    echo "scm fpga updated successfully."
                else
                    echo "scm fpga update failed."
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
