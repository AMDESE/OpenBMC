FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-phosphor-post-code-manager-Add-LCD-write-POST-CODE.patch \
            file://0002-phosphor-post-code-manager-Del-POST-Index-from-LCD.patch \
            file://0003-fixed-delete-all-method-and-added-enhancements.patch \
            file://0004-add-thread-to-flush-post-codes-periodically.patch \
            file://0005-dump-current-boot-post-code-to-text-file.patch \
            file://0006-Limit-maximum-post-code-entries-per-boot.patch \
            file://0007-post_code-Increase-the-maximum-number-of-post-codes-.patch \
            "

DEPENDS += "amd-lcd-lib"

TARGET_LDFLAGS = " -llcdlib32 -lpthread"

S = "${WORKDIR}/git"
