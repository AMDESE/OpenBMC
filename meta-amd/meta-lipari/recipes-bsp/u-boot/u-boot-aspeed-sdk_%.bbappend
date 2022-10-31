FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

require conf/machine/distro/include/uboot-distrovars.inc

SRCREV = "a7c723fdd887cf1ac9202de518e9669c7cd09ed6"

SRC_URI += "file://0001-lipari-spl-defconfig.patch \
            file://0002-lipari-dts-file.patch \
            file://0003-lpc-mode-config.patch \
            "
SRC_URI_append_uboot-flash-65536 += "file://u-boot_flash_64M.cfg \
                                     "
