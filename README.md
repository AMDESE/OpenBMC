# OpenBMC

The OpenBMC project can be described as a Linux distribution for embedded
devices that have a BMC; typically, but not limited to, things like servers,
top of rack switches or RAID appliances. The OpenBMC stack uses technologies
such as [Yocto](https://www.yoctoproject.org/),
[OpenEmbedded](https://www.openembedded.org/wiki/Main_Page),
[systemd](https://www.freedesktop.org/wiki/Software/systemd/), and
[D-Bus](https://www.freedesktop.org/wiki/Software/dbus/) to allow easy
customization for your server platform.


## Setting up your OpenBMC project

### 1) Prerequisite
- Ubuntu 18.04

```
sudo apt-get install -y git build-essential libsdl1.2-dev texinfo gawk chrpath diffstat
```

### 2) Download the source
```
mkdir OpenBMC
cd OpenBMC
git clone https://github.com/AMDESE/OpenBMC.git .
```

### 3) Target your hardware
Any build requires an environment set up according to your hardware target.
There is a special script in the root of this repository that can be used
to configure the environment as needed. The script is called `setup` and
takes the name of your hardware target as an argument.

The script needs to be sourced while in the top directory of the OpenBMC
repository clone, and, if run without arguments, will display the list
of supported hardware targets, see the following example:

```
$ . setup
Target machine must be specified.
```
Once you know the target (e.g. onyx), source the `setup` script as follows:

```
. setup sp5
```

### 4) Build

```
bitbake obmc-phosphor-image
```

Additional details can be found in the [docs](https://github.com/openbmc/docs)
repository.

## OpenBMC Development

The OpenBMC community maintains a set of tutorials new users can go through
to get up to speed on OpenBMC development out
[here](https://github.com/openbmc/docs/blob/master/development/README.md)

## Build Validation and Testing
This contains bring up code to port OpenBMC on AMD's customer reference boards.
meta-sp5 supports boards:
1. Onyx
2. Quartz
3. Ruby
4. Titanite

meta-sh5 supports boards:
1. sh5 d807

meta-sp6 supports boards:
1. Sunstone
2. Shale
3. Cinnabar

meta-turin supports boards:
1. Chalupa
2. Galena
3. Huambo
4. Purico
5. Recluse
6. Volcano

The builds are **beta** quality at this point in time.
Please check back for updates.

## Submitting Patches
AMD welcomes contributions. Please create pull requests to contribute: (https://github.com/AMDESE/OpenBMC/pulls)

## Bug Reporting
[Issues](https://github.com/AMDESE/OpenBMC/issues) are managed on
GitHub. It is recommended you search through the issues before opening
a new one.

## Questions

First, please do a search on the internet. There's a good chance your question
has already been asked.

For general questions, please use the openbmc tag on
[Stack Overflow](https://stackoverflow.com/questions/tagged/openbmc).
Please review the [discussion](https://meta.stackexchange.com/questions/272956/a-new-code-license-the-mit-this-time-with-attribution-required?cb=1)
on Stack Overflow licensing before posting any code.

For technical discussions, please see [contact info](#contact) below for IRC and
mailing list information. Please don't file an issue to ask a question. You'll
get faster results by using the mailing list or IRC.

## Supported Features:
 - WebUI
    - System at a glance
    - Network info
    - Unique host name
 - Control Interface
    - IPMI (OOB)
    - Redfish (OOB)
    - SSH Console (BMC)
 - Firmware Updates
    - BMC (OOB)
    - BIOS (OOB)
        - CLEAR CMOS via script
    - HAWAII FPGA (OOB) - Command line only, NO UI
    - Onyx/Quartz FPGA (OOB) - Command line only, NO UI
 - SOL Console
    - webui
    - ssh
 - Power Control
    - ON
    - OFF
    - State detection
 - New WebUI
    - webvue-ui
 - Fan Control
    - Adaptive fan Control
 - KVM
    - Keyboard, Video, Mouse
    - VNC Client support
 - APML
    - CPU temperature sensors
    - I3C tools supported
 - Locator/Chassis ID LEDs
 - Post Code Capture using eSPI
 - Inband IPMI over KCS (eSPI)
 - LCD Display
 - Display Port Enablement
 - BMC RAS
 - BMC Crashdump
 - Power Capping
 - PMIC Error Injection
 - MCTP Support
 - CPER format data for RAS
 - VR update
 - Single CPER file for RAS Error
 - FPGA dump script

## Features in Progress:
 - New platform support

## Finding out more

Dive deeper into OpenBMC by opening the
[docs](https://github.com/openbmc/docs) repository.

## Contact
- Mail: openbmc@lists.ozlabs.org [https://lists.ozlabs.org/listinfo/openbmc](https://lists.ozlabs.org/listinfo/openbmc) with the subject "meta-amd"
- Alternatively, you can copy the maintainer: Supreeth Venkatesh <supreeth.venkatesh@amd.com>
