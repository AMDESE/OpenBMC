FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://amd-g304-u-boot.cfg \
            file://0001-common-main.c-Hardcode-G304-SMC-hostname.patch \
            file://0002-u-boot-aspped-Modify-u-boot-code-to-support-G304-platform.patch \
            file://0003-u-boot-aspeed-sdk-Modify-dts-for-SPI-frequency.patch \
            file://0004-u-boot-aspeed-sdk-Modify-i2c-driver-to-unlock-the-i2c-frequency.patch \
            "
