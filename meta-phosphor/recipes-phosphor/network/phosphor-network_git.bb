SUMMARY = "Network DBUS object"
DESCRIPTION = "Network DBUS object"
HOMEPAGE = "http://github.com/openbmc/phosphor-networkd"
PR = "r1"
PV = "1.0+git${SRCPV}"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=fa818a259cbed7ce8bc2a22d35a464fc"

inherit autotools pkgconfig
inherit python3native
inherit systemd

SRC_URI += "git://github.com/openbmc/phosphor-networkd;protocol=https"
SRCREV = "1e710d04a61092b45ff4ccd58656cb5cee3cba5b"

DEPENDS += "systemd"
DEPENDS += "autoconf-archive-native"
DEPENDS += "sdbusplus ${PYTHON_PN}-sdbus++-native"
DEPENDS += "sdeventplus"
DEPENDS += "phosphor-dbus-interfaces"
DEPENDS += "phosphor-logging"
DEPENDS += "libnl"
DEPENDS += "stdplus"
DEPENDS += "nlohmann-json"

PACKAGECONFIG ??= "uboot-env default-link-local-autoconf default-ipv6-accept-ra"

UBOOT_ENV_RDEPENDS = "${@d.getVar('PREFERRED_PROVIDER_u-boot-fw-utils', True) or 'u-boot-fw-utils'}"
PACKAGECONFIG[uboot-env] = "--with-uboot-env,--without-uboot-env,,${UBOOT_ENV_RDEPENDS}"
PACKAGECONFIG[default-link-local-autoconf] = "--enable-link-local-autoconfiguration,--disable-link-local-autoconfiguration,,"
PACKAGECONFIG[default-ipv6-accept-ra] = "--enable-ipv6-accept-ra,--disable-ipv6-accept-ra,,"
PACKAGECONFIG[nic-ethtool] = "--enable-nic-ethtool,--disable-nic-ethtool,,"
PACKAGECONFIG[sync-mac] = "--enable-sync-mac,--disable-sync-mac,,"

S = "${WORKDIR}/git"

SERVICE_FILE = "xyz.openbmc_project.Network.service"
SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE_${PN} += "${SERVICE_FILE}"

EXTRA_OECONF = " \
  SYSTEMD_TARGET="multi-user.target" \
"
