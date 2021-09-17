FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRCREV = "44a8c618c1215e0faac0f335f0afd56ed4240e76"

SRC_URI += "file://0001-Add-Initial-u-boot-configuration.patch \
            file://0002-spi-nor-Porting-MT25Q01G-flash-part.patch \
            file://0003-net-eth-mac-address-reading-from-eeprom.patch \
            file://0004-u-boot-set-board-id-env.patch \
            file://0005-u-boot-Add-spi2-entry-to-device-tree-enable-local-sp.patch \
            file://0006-u-boot-sdk-eeprom-board_id-offset-change.patch \
            file://0007-u-boot-sdk-Add-device-tree-selection-code.patch \
            file://0008-u-boot-sdk-Add-additional-board_id-codes.patch \
            file://0010-u-boot-aspeed-sdk-Enable-display-port-for-HAWAII.patch \
            file://sp5-u-boot.cfg \
            "
