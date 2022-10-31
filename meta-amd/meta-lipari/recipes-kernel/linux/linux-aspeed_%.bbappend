FILESEXTRAPATHS_prepend := "${THISDIR}/linux-aspeed"

KBRANCH = "dev-5.15"
LINUX_VERSION = "5.15.50"

SRCREV="478951fa4a5903ebcee4ea12a11718b8f5736c1b"

DEPENDS += "lzop-native"
SRC_URI += "file://lipari.cfg \
            file://0001-ARM-dts-aspeed-g6-Add-PCC-support.patch \
            file://0002-soc-aspeed-Add-Post-Code-Control.patch \
            file://0003-ipmi-kcs-aspeed-g6-Use-v1-binding.patch \
            file://0004-ARM-dts-aspeed-g6-Fix-missing-KCS-channel.patch \
            file://0005-macronix-address-3Bytes.patch \
            file://0006-Add-Pinctrl-for-EMMC-8-bit-configs.patch \
            file://0007-lipari-dts-file.patch \
            file://0008-enable-lpc-modules.patch \
            file://0009-GPIO-and-LED-configs-in-DTS.patch \
            file://0010-serial-8250-Add-Aspeed-UART-driver-with-DMA-supporte.patch \
            file://0011-soc-aspeed-udma-Reset-TX-RX-DAM-at-UART-shutdown.patch \
            file://0012-vuart-dts-changes.patch \
            "
RRECOMMENDS_${KERNEL_PACKAGE_NAME}-base = ""
RDEPENDS_${KERNEL_PACKAGE_NAME}-base = ""
