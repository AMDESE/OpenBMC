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
        amd-bmc-ubm \
        amd-clear-cmos \
        amd-dimm \
        amd-lcd-lib \
        amd-mctp-tool \
        amd-ras \
        amd-spdm \
        amd-yaap \
        auto-notify \
        bmcweb \
        cpu-info \
        debug-apps \
        first-boot-set-hwmon-path \
        fpga-tools \
        i3c-tools \
        ipmitool \
        iodevices-inventory \
        phosphor-hostlogger \
        phosphor-pid-control \
        phosphor-host-postd \
        phosphor-post-code-manager \
        power-capping \
        phosphor-misc-usb-ctrl \
        retimer-update \
        set-fan-speed \
        set-associations-path \
        usb-network \
        vr-update \
        webui-vue \
        "
