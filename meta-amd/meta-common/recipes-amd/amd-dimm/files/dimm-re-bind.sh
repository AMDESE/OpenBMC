#!/bin/bash

cd /sys/bus/platform/drivers/dw-i3c-master/

echo 1e7a2000.i3c0 > unbind
echo 1e7a3000.i3c1 > unbind
echo 1e7a4000.i3c2 > unbind
echo 1e7a5000.i3c3 > unbind
sleep 5
echo 1e7a2000.i3c0 > bind
echo 1e7a3000.i3c1 > bind
echo 1e7a4000.i3c2 > bind
echo 1e7a5000.i3c3 > bind
