#!/bin/bash

echo 1e7a2000.i3c0 > /sys/bus/platform/drivers/dw-i3c-master/unbind
echo 1e7a2000.i3c0 > /sys/bus/platform/drivers/dw-i3c-master/bind
echo 1e7a3000.i3c1 > /sys/bus/platform/drivers/dw-i3c-master/unbind
echo 1e7a3000.i3c1 > /sys/bus/platform/drivers/dw-i3c-master/bind
