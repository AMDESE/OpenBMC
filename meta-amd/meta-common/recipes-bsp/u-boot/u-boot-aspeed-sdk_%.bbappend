FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRCREV = "44a8c618c1215e0faac0f335f0afd56ed4240e76"

SRC_URI += "file://amd-ast2600-u-boot.cfg \
            file://0001-u-boot-aspeed-sdk-add-Initial-Hawaii-device-tree.patch \
            file://0002-u-boot-aspeed-sdk-add-spi-nor-MT25Q01G-set-MAC-addr-BMC-Root-cause.patch \
            file://0003-u-boot-aspeed-sdk-add-platform-based-board_id-and-hostname.patch \
            file://0004-u-boot-aspeed-sdk-modify-Platform-based-device-tree-selection.patch \
            "
