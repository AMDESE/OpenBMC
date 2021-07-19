FILESEXTRAPATHS_prepend := "${THISDIR}/linux-aspeed:"

SRC_URI += "file://sp5.cfg \
            file://0001-ARM-dts-aspeed-Initial-device-tree-for-AMD-Onyx-Plat.patch \
            file://0002-ARM-dts-aspeed-Add-UART-changes-to-dts-for-SOL-enabl.patch \
            file://0003-ARM-dts-aspeed-Add-I2C-updates-to-dts-for-sensors.patch \
            file://0004-ARM-dts-aspeed-Add-kcs-ports-in-onyx.patch \
            file://0005-ARM-dts-aspeed-Add-device-tree-entry-for-SPI2.patch \
            file://0006-ARM-dts-aspeed-Add-device-tree-entry-for-GPIO0-bank.patch \
            file://0007-ARM-dts-aspeed-Add-device-tree-entry-for-JTAG.patch \
            file://0008-drivers-jtag-Add-Aspeed-SoC-24xx-25xx-26xx-families-.patch \
            "

