#!/bin/sh
#
# BMC GPIO setting for BIOS Clear CMOS
set -e

GPIOCHIP=816
GPIO_CLR_CMOS=$((${GPIOCHIP} + 98))
choice=$1

# Host power controls
POWER_CMD_OFF="busctl set-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis RequestedPowerTransition s xyz.openbmc_project.State.Chassis.Transition.Off"
POWER_CMD_ON="busctl set-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis RequestedPowerTransition s xyz.openbmc_project.State.Chassis.Transition.On"

# Check Host power status
power_status() {
    st=$(busctl get-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis CurrentPowerState | cut -d"." -f6)
    if [ "$st" == "On\"" ]; then
        echo "on"
    else
        echo "off"
    fi
}

# Clear current  BIOS setting on CMOS
clear_cmos()
{
    # Set GPIO
    if [ ! -d /sys/class/gpio/gpio$GPIO_CLR_CMOS ]; then
        cd /sys/class/gpio
        echo $GPIO_CLR_CMOS > export
        cd gpio$GPIO_CLR_CMOS
    else
        cd /sys/class/gpio/gpio$GPIO_CLR_CMOS
    fi

    # check direction
    direction=`cat direction`
    if [ "$direction" == "in" ]; then
        echo "out" > direction
    fi

# Toggle the CLR_CMOS gpio for 5 sec.
    data=`cat value`
    if [ "$data" == '0' ]; then
        echo "Clearing CMOS..."
        echo 1 > value
        sleep 5
        echo 0 > value
    else
        echo "Clear CMOS failed.."
    fi

    #reset GPIO
    echo "in" > direction
    cd /sys/class/gpio
    echo $GPIO_CLR_CMOS > unexport
    }

# Check Host power status
if [ $(power_status) != "off" ];
then
    if [ -z $choice ]
    then
        echo "Warning : Host is powered 'ON'"
        echo "It will be powered OFF before clearing CMOS\n"
        read -r -p  "Do You want to continue? (Y/N): " choice
    fi
    if [ "$choice" != 'Y' ] && [ "$choice" != 'y' ]; then
        exit -1
    fi
    # power off the system
    echo "Powering down the Host..."
    $POWER_CMD_OFF
    sleep 10
    # Perform clear CMOS
    clear_cmos
    sleep 1
    echo "Powering up the Host..."
    $POWER_CMD_ON
else
    # Perform clear CMOS
    clear_cmos
fi
