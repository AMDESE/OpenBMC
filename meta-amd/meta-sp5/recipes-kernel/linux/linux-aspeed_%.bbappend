FILESEXTRAPATHS_prepend := "${THISDIR}/linux-aspeed:"

SRC_URI += "file://sp5.cfg \
            file://0001-ARM-dts-aspeed-Initial-device-tree-for-AMD-Onyx-Plat.patch \
            file://0002-ARM-dts-aspeed-Add-UART-changes-to-dts-for-SOL-enabl.patch \
            file://0003-ARM-dts-aspeed-Add-I2C-updates-to-dts-for-sensors.patch \
            file://0004-ARM-dts-aspeed-Add-kcs-ports-in-onyx.patch \
            "

