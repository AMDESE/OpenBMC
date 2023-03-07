FILESEXTRAPATHS_prepend := "${THISDIR}/linux-aspeed:"

SRC_URI += "file://amd-bmc-baseline.cfg \
            file://0001-drivers-soc-aspeed-Add-MCTP-driver.patch \
            file://0002-drivers-i3c-Modify-I3C-driver.patch \
            file://0003-drivers-soc-aspeed-Add-eSPI-drivers.patch \
            file://0004-drivers-jtag-Add-JTAG-driver.patch \
            file://0005-drivers-soc-Add-uart-DMA-driver.patch \
            file://0006-drivers-soc-aspeed-Add-UART-Routing-driver.patch \
            file://0007-drivers-media-Ignore-known-bogus-interrupts-in-Video.patch \
            file://0008-drivers-hwmon-Add-amd_cpld-and-emc2301-fan-sensor-dr.patch \
            file://0009-drivers-hwmon-Add-tmp468-temperature-sensor-driver.patch \
            file://0010-drivers-mtd-Add-support-for-gigadevice-and-macronix-.patch \
            file://0011-drivers-hwmon-Extend-support-for-infineon-xdpe19283-.patch \
            file://0012-drivers-net-Suppress-warning-message-from-network-dr.patch \
            file://0013-drivers-i2c-Hack-to-restrict-i2c-bus-to-50-KHz-for-l.patch \
            file://0014-linux-aspeed-modify-MP2975-VR-driver-to-support-MP2862-controller.patch \
            file://0015-drivers-misc-Add-APML-SB-TSI-and-SB-RMI-drivers.patch \
            file://0016-ARM-dts-aspeed-Initial-device-tree-for-AMD-Genoa-Pla.patch \
            file://0017-ARM-dts-aspeed-Initial-device-tree-for-AMD-Siena-Pla.patch \
            file://0018-ARM-dts-aspeed-Initial-device-tree-for-AMD-Turin-Pla.patch \
            file://0019-ARM-dts-aspeed-Initial-device-tree-for-AMD-MI-300-Pl.patch \
            file://0020-ARM-dts-aspeed-Add-UART-routing-to-Turin.patch \
            file://0021-drivers-hwmon-add-aspeed-chassis-driver.patch \
            file://0022-ARM-dts-aspeed-Initial-device-tree-for-Galena-Recluse.patch \
            file://0023-ARM-dts-aspeed-initial-Huambo-DTS-file-for-AMD-Turin.patch \
            file://0024-drivers-hwmon-Add-nct7362-fan-controller-driver.patch \
            file://0025-ARM-dts-aspeed-Add-new-HWMON-for-Turin-Lenovo.patch \
            file://0026-ARM-dts-aspeed-Add-UART-routing-to-sh5.patch \
            file://0027-drivers-hwmon-modify-nct7362-driver-for-setting-default-pwm.patch \
            file://0028-ARM-dts-aspeed-modify-Volcano-device-tree-for-VR-device-id.patch \
            file://0029-linux-aspeed-modify-sh5d807-device-tree-for-VR-sensors.patch \
            file://0030-linux-aspeed-driver-Modify-disable-watchdog-timer-in-nct7362.patch \
            file://0031-ARM-dts-aspeed-Initial-device-tree-for-AMD-G304-Plat.patch \
            file://0032-ARM-dts-aspeed-Add-Volcano-sensors.patch \
            file://0033-ARM-dts-aspeed-APML-over-I2C.patch \
            file://0034-drivers-usb-gadget-aspeed-virtual-hub-updates.patch \
            file://0035-ARM-dts-aspeed-Add-Turin-Lenovo-UBM.patch \
           "
