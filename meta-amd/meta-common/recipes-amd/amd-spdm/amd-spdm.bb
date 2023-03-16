SUMMARY = "libspdm"
DESCRIPTION = "Implementation of SPDM(DMTF DSP0274)"
LICENSE = "CLOSED"
FILESEXTRAPATHS_prepend := "${THISDIR}:"

BB_STRICT_CHECKSUM = "0"
SRC_URI = "git://git@er.github.amd.com/RoT/proto-apps.git;branch=openbmc_release-0.8;protocol=ssh"
SRCREV = "${AUTOREV}"

S="${WORKDIR}/git"

DEPENDS = "openssl"

# Export the arm-openssl path
export OPENSSL_ARM_DIR = "${WORKDIR}/recipe-sysroot/usr/lib"
export OPENSSL_INCLUDE_DIR = "${WORKDIR}/recipe-sysroot/usr/include"

inherit cmake python3native

EXTRA_OECMAKE = "-DAPP=spdm_requester -DPLAT_SHIM=arm-OpenBmc -DCOMPILER=arm-openbmc-linux-gnueabi"


do_patch_append() {
    bb.build.exec_func('do_update_submodules', d)
}

do_update_submodules () {
    cd ${S}
    python3  ${S}/scripts/git_module_update.py
}

cmake_do_compile() {
    cd ${S}
    cmake -DAPP=spdm_requester -DPLAT_SHIM=arm-OpenBmc -DCOMPILER=arm-openbmc-linux-gnueabi -B${S}/release/
    make -C release VERBOSE=1
}

cmake_do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/release/spdm_requester.elf ${D}${bindir}/
}

INSANE_SKIP_${PN} += "ldflags"
