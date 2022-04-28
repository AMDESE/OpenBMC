SUMMARY = "OpenBMC for AMD - Applications"
PR = "r1"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = " \
        ${PN}-chassis \
        ${PN}-fans \
        ${PN}-flash \
        ${PN}-system \
        "

PROVIDES += "virtual/obmc-chassis-mgmt"
PROVIDES += "virtual/obmc-flash-mgmt"
PROVIDES += "virtual/obmc-fan-mgmt"
PROVIDES += "virtual/obmc-system-mgmt"

RPROVIDES_${PN}-chassis += "virtual-obmc-chassis-mgmt"
RPROVIDES_${PN}-fans += "virtual-obmc-fan-mgmt"
RPROVIDES_${PN}-flash += "virtual-obmc-flash-mgmt"
RPROVIDES_${PN}-system += "virtual-obmc-system-mgmt"

SUMMARY_${PN}-chassis = "AMD Chassis"
RDEPENDS_${PN}-chassis = " \
        amd-power-control \
        phosphor-sel-logger \
        phosphor-logging \
        "

SUMMARY_${PN}-fans = "AMD Fans"
RDEPENDS_${PN}-fans = "phosphor-pid-control"

SUMMARY_${PN}-flash = "AMD Flash"
RDEPENDS_${PN}-flash = " \
        phosphor-software-manager \
        "

SUMMARY_${PN}-system = "AMD System"
RDEPENDS_${PN}-system = " \
        amd-apml \
        amd-clear-cmos \
        amd-dimm \
        amd-lcd-lib \
        amd-ras \
        amd-yaap \
        bmcweb \
        debug-apps \
        first-boot-set-hwmon-path \
        fpga-tools \
        i3c-tools \
        ipmitool \
        phosphor-hostlogger \
        phosphor-pid-control \
        phosphor-host-postd \
        phosphor-post-code-manager \
        power-capping \
        retimer-update \
        set-fan-speed \
        set-associations-path \
        vr-update \
        webui-vue \
        "
