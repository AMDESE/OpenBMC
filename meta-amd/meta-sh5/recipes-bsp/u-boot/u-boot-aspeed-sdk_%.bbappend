FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRCREV = "44a8c618c1215e0faac0f335f0afd56ed4240e76"

SRC_URI += "file://sh5-u-boot.cfg \
        file://0001-u-boot-aspeed-sdk-Add-initial-device-tree-for-MI300-SH5-platforms.patch \
        file://0002-u-boot-aspeed-sdk-Add-merged-changes-from-SP5-code-base.patch \
            "
