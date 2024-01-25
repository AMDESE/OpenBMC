SUMMARY = "AMD IO Devices Inventory"
DESCRIPTION = "IO Devices Inventory get the PCIe Data from BIOS and set the dbus interface \
xyz.openbmc_project.PCIe.service for IO Device (PCIe and Storage) fetch the data from BIOS \
and set the DBus interface for Redfish API."

SRC_URI = "git://git@github.com/AMDESE/amd-iodevices-inventory.git;branch=main;protocol=ssh"
SRCREV = "80e197eb2d95e149ede9fb8fb596ed8014d2b079"

S = "${WORKDIR}/git"

LICENSE = "CLOSED"

inherit cmake pkgconfig systemd

def get_service(d):
      return "xyz.openbmc_project.PCIe.service"

SYSTEMD_SERVICE_${PN} = "${@get_service(d)}"

DEPENDS += " \
    i2c-tools \
    libgpiod \
    phosphor-dbus-interfaces \
    phosphor-logging \
    sdbusplus \
    "

FILES_${PN}  += "${systemd_system_unitdir}/xyz.openbmc_project.PCIe.service"
