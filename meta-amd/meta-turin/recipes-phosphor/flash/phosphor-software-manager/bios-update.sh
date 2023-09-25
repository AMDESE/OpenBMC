#!/bin/bash

# Below are the BMC GPIO settings to access BIOS SPI flash
# GPIOs: [HPM_BMC_GPIOO1:HPM_BMC_GPIOO0]
#   	[00] = Run Mode
#   	[01] = Local BIOS SPI
#   	[10] = HPM FPGA SPI
#   	[11] = HPM LOM SPI
#

set +e

POWER_CMD_OFF="busctl set-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis RequestedPowerTransition s xyz.openbmc_project.State.Chassis.Transition.Off"
POWER_CMD_ON="busctl set-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis RequestedPowerTransition s xyz.openbmc_project.State.Chassis.Transition.On"
IMAGE_DIR=$1

GPIOCHIP=816
GPIOO0=$((${GPIOCHIP} + 112 + 0))
GPIOO1=$((${GPIOCHIP} + 112 + 1))

# Lanai
GPIOV0=$((${GPIOCHIP} + 168 + 0))
GPIOV1=$((${GPIOCHIP} + 168 + 1))
LANAI_SPI_DEV="1e630000.spi"

SPI_DEV="1e631000.spi"
SPI_PATH="/sys/bus/platform/drivers/aspeed-smc"

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
    echo "switch bios GPIO to bmc"
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
    if [ "$data" == "0" ]; then
        echo 1 > value
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
    if [ "$data" == "1" ]; then
        echo 0 > value
    fi

    return 0
}
set_lanai_gpio_to_bmc()
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
set_lanai_gpio_to_host()
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

flash_image_to_mtd() {
	echo $IMAGE_DIR
	pushd $IMAGE_DIR
	IMAGE_FILE=$(find -type f -name '*.FD')
	if [ -e "$IMAGE_FILE" ];
	then
		echo "Bios image is $IMAGE_FILE"
		# mtd7 - motherboard local spi (after bind)
		# mtd6 - already bound lanai spi (refer line no 281)
		for d in $mtd_num ; do
			if [ -e "/dev/$d" ]; then
				mtd=`cat /sys/class/mtd/$d/name`
				if [ $mtd == "pnor" ]; then
					echo "Flashing bios image to $d..."
					flash_eraseall /dev/$d
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
}

echo "Bios upgrade started at $(date)"
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
    echo "Bios upgrade failed"
    exit -1
fi
echo "Host server powered off"


#Flip GPIO to access SPI flash used by host.
echo "Set GPIO $GPIO to access SPI flash from BMC used by host"
set_gpio_to_bmc

#Bind spi driver to access flash
echo "bind aspeed-smc spi driver"
echo -n $SPI_DEV > $SPI_PATH/bind
if [ $? -eq 0 ];
then
    echo "SPI Driver Bind Successful"
else
    echo "SPI Driver Bind Failed.Run micron_v2.ini or micron_v3.ini using DediProg."
    set_gpio_to_host
    sleep 5
    exit -1
fi
sleep 1

#Flashcp image to device.
get_mtd_info $SPI_DEV
flash_image_to_mtd

#Unbind spi driver
sleep 1
echo "Unbind aspeed-smc spi driver"
echo -n $SPI_DEV > $SPI_PATH/unbind
sleep 1

#Flip GPIO back for host to access SPI flash
echo "Set GPIO $GPIO back for host to access SPI flash"
set_gpio_to_host
sleep 1

# Lanai flash start--------------------------
# (ignore errors but capture return status)
lanai_ret=0
get_mtd_info $LANAI_SPI_DEV
flash_image_to_mtd || lanai_ret=$?
echo "Lanai flashcp status: $lanai_ret"
sleep 1
# Lanai flash end----------------------------

if [ "$power_state" != "off" ];
then
$POWER_CMD_ON
sleep 1
fi
exit 0

