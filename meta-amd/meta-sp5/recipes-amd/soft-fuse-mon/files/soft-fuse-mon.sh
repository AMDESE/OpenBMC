#!/bin/bash

set -e

echo "Initiating Soft-fuse Configuration"

GPIOCHIP0_BASE=816
GPIO_NOTIFY=$((${GPIOCHIP0_BASE} + 104 + 6))
GPIO_XTRIG5=$((${GPIOCHIP0_BASE} + 112 + 3))
GPIO_XTRIG6=$((${GPIOCHIP0_BASE} + 112 + 4))

GPIODIR="/sys/class/gpio"
GPIOEXPORT="$GPIODIR/export"
GPIOUNEXPORT="$GPIODIR/unexport"


sfmon_init()
{
	echo $GPIO_XTRIG5 > $GPIOEXPORT
	echo $GPIO_XTRIG6 > $GPIOEXPORT

	echo "out" > $GPIODIR/gpio$GPIO_XTRIG5/direction
	echo "out" > $GPIODIR/gpio$GPIO_XTRIG6/direction
}

sfmon_exit()
{
        echo $GPIO_XTRIG5 > $GPIOUNEXPORT
        echo $GPIO_XTRIG6 > $GPIOUNEXPORT
}

sfmon_coolreset()
{
	#200ms delay and toggle after 100ms
	echo "Cool reset initiated sucessfully"
	sleep 0.2
	echo 1 > $GPIODIR/gpio$GPIO_XTRIG5/value
	echo 1 > $GPIODIR/gpio$GPIO_XTRIG6/value
	sleep 0.1
	echo 0 > $GPIODIR/gpio$GPIO_XTRIG5/value
	echo 0 > $GPIODIR/gpio$GPIO_XTRIG6/value
	echo "Cool reset completed"
	#echo "Exiting Soft-fuse monitor"
	#sfmon_exit
}

# gpiomon blocks until gpio event
# bash executes cool reset after gpiomon catches event
#sfmon_init && gpiomon --num-events=1 --rising-edge gpiochip0 $GPIO_NOTIFY && sfmon_coolreset
sfmon_init
for((;;))
do
	gpiomon --num-events=1 --rising-edge gpiochip0 $GPIO_NOTIFY
	sfmon_coolreset
done
echo "Exiting Soft-fuse monitor"
sfmon_exit

