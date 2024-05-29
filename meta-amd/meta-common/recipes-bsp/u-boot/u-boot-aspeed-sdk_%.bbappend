FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRCREV = "44a8c618c1215e0faac0f335f0afd56ed4240e76"

SRC_URI += "file://amd-ast2600-u-boot.cfg \
            file://0001-u-boot-aspeed-sdk-add-Initial-Hawaii-device-tree.patch \
            file://0002-u-boot-aspeed-sdk-add-spi-nor-MT25Q01G-set-MAC-addr-BMC-Root-cause.patch \
            file://0003-u-boot-aspeed-sdk-add-platform-based-board_id-and-hostname.patch \
            file://0004-u-boot-aspeed-sdk-modify-Platform-based-device-tree-selection.patch \
            file://0005-u-boot-add-new-env-param-for-all-platforms.patch \
            file://0006-u-boot-Turin-APML-over-i2c-i3c.patch  \
            file://0007-u-boot-SP5-APML-over-i2c-i3c.patch \
            file://0008-u-boot-Add-Turin-Volcano-with-4-Pump-Fans.patch \
            file://0009-u-boot-Boot-from-first-DTB-on-unknown-board-ID.patch \
            file://0010-u-boot-Add-Board-rev-to-UBOOT-parameters.patch \
            file://0011-u-boot-Add-enable-gpios-to-mount-Lanai-flash.patch \
            file://0012-u-boot-Add-env-variable-for-SAFS-boot.patch \
            "
