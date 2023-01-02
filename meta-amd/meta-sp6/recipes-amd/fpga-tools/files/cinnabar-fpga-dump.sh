#!/bin/bash
echo
echo "-----  Onyx FPGA Register Dump Utility  -----"
echo
I2CBUS=0
FPGAADDR=0x50

SCRIPT_REG_MAP_VER=1

#---------------------------------------------------

function read_reg()
{
        local FPGA_REG=$1
        local DATA=$(i2cget -y $I2CBUS $FPGAADDR $(printf "0x%x" $FPGA_REG))
        echo -ne $((DATA))
}

function switch_status()
{
        local data=$1
        local bitmask=$2
        local bitshift=$3
        [[ $((((data & bitmask)) >> bitshift)) -eq 0 ]] && echo -ne "Off" || echo -ne "On"
}

function signal_status()
{
        local name=$1
        local data=$2
        local bitmask=$3
        local bitshift=$4
        local default_val=$5
        local curr_val=$((((data & bitmask)) >> bitshift))
        printf "%-30s %-8s %-8s\n" $1 $default_val $curr_val
}

#----------------------------------------------------

# MAGIC BYTE
printf "Magic Byte: $(printf %x $(read_reg 0))\n"

# Board ID
echo "Board ID: $(read_reg 1)"

if [ $(read_reg 1) -ne 99 ] ; then  # hex ID 0x63
        echo "FPGA Board ID is not Cinnabar"
        exit 1
fi

# Reg map version
echo "Register Map version: $(read_reg 2)"

if [ $(read_reg 2) -ne $SCRIPT_REG_MAP_VER ] ; then
        echo "Register map version mismatch"
        exit 1
fi

# FPGA FW Version Information
MAJOR=$(read_reg 3)
MINOR=$(read_reg 4)
REV=$(printf "\x$(printf %x $(read_reg 5))")
echo FPGA FW version: $MAJOR.$MINOR.$REV

# SGPIO Map version
echo SGPIO Map version $(read_reg 7)
printf "\n"

# S1 switch status (0=OFF, 1=ON)
data=$(read_reg 8)
echo Switch S1 effective state
echo "   SW 1.0: $(switch_status $data 0x01 0)"
echo "   SW 1.1: $(switch_status $data 0x02 1)"
echo "   SW 1.2: $(switch_status $data 0x04 2)"
echo "   SW 1.3: $(switch_status $data 0x08 3)"
echo "   SW 1.4: $(switch_status $data 0x10 4)"
echo "   SW 1.5: $(switch_status $data 0x20 5)"
echo "   SW 1.6: $(switch_status $data 0x40 6)"

printf "\n"

# S2 switch status (0=OFF, 1=ON)
data=$(read_reg 9)
echo Switch S2 effective state
echo "   SW 2.0: $(switch_status $data 0x01 0)"
echo "   SW 2.1: $(switch_status $data 0x02 1)"
echo "   SW 2.2: $(switch_status $data 0x04 2)"
echo "   SW 2.3: $(switch_status $data 0x08 3)"
echo "   SW 2.4: $(switch_status $data 0x10 4)"
echo "   SW 2.5: $(switch_status $data 0x20 5)"
echo "   SW 2.6: $(switch_status $data 0x40 6)"
echo "   SW 2.7: $(switch_status $data 0x80 7)"
printf "\n"

# S3 switch status (0=OFF, 1=ON)
data=$(read_reg 0x0A)
echo Switch S3 effective state
echo "   SW 3.0: $(switch_status $data 0x01 0)"
echo "   SW 3.1: $(switch_status $data 0x02 1)"
echo "   SW 3.2: $(switch_status $data 0x04 2)"
echo "   SW 3.3: $(switch_status $data 0x08 3)"
echo "   SW 3.4: $(switch_status $data 0x10 4)"
echo "   SW 3.5: $(switch_status $data 0x20 5)"
echo "   SW 3.6: $(switch_status $data 0x40 6)"
echo "   SW 3.7: $(switch_status $data 0x80 7)"
printf "\n"

# PSU signals
data=$(read_reg 0x0B)
echo -e "    PSU Signal              Default\tCurrent"
echo -e "    ----------              -------\t-------"
signal_status PSU_PWROK_BUF_1        $data 0x80 7 0
signal_status PSU_VIN_GOOD_BUF_1     $data 0x40 6 1
signal_status PSU_PRSNT_BUF_L_1      $data 0x20 6 1
signal_status PSU_CONN_PRSNT_L_1     $data 0x10 4 0
signal_status PSU_PWROK_BUF_0        $data 0x08 3 1
signal_status PSU_VIN_GOOD_BUF_0     $data 0x04 2 1
signal_status PSU_PRSNT_BUF_L_0      $data 0x02 1 1
signal_status PSU_CONN_PRSNT_L_0     $data 0x01 0 0
printf "\n"

# VR enable signals
data=$(read_reg 0x0C)
echo -e "    VR En Signal            Default\tCurrent"
echo -e "    ------------            -------\t-------"
signal_status PSU_PSON_L_1           $data 0x80 7 0
signal_status PSU_PSON_L_0           $data 0x40 6 0
signal_status VDD_12_RUN_DUAL_EN     $data 0x20 6 0
signal_status VDD_12_ALW_DUAL_EN     $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status VDD_33_RUN_EN          $data 0x04 2 1
signal_status VDD_33_DUAL_EN         $data 0x02 1 1
signal_status VDD_5_DUAL_EN          $data 0x01 0 1
printf "\n"

# VR PWR_GD
data=$(read_reg 0x0D)
echo -e "    VR PWR_GD Signal        Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 6 0
signal_status SCM_VDD_12_ALW_PG      $data 0x10 4 1
signal_status LOM_VDD_33_ALW_PG_BUF  $data 0x08 3 1
signal_status VDD_33_RUN_PG          $data 0x04 2 0
signal_status VDD_33_DUAL_PG         $data 0x02 1 1
signal_status VDD_5_DUAL_PG          $data 0x01 0 1
printf "\n"


# P0 Signal
data=$(read_reg 0x0E)
echo -e "        P0 Signal           Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 6 0
signal_status P0_PWROK               $data 0x10 4 U
signal_status P0_SLP_S5_L            $data 0x08 3 U
signal_status P0_SLP_S3_L            $data 0x04 2 U
signal_status P0_PRSNT_L             $data 0x02 1 U
signal_status P0_ORIENTATION_OK      $data 0x01 0 U
printf "\n"

# P1 Signal
data=$(read_reg 0x0F)
echo -e "        P1 Signal           Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 6 0
signal_status P0_PWROK               $data 0x10 4 0
signal_status P0_SLP_S5_L            $data 0x08 3 0
signal_status P0_SLP_S3_L            $data 0x04 2 0
signal_status P0_PRSNT_L             $data 0x02 1 0
signal_status P0_ORIENTATION_OK      $data 0x01 0 0
printf "\n"

# P0 ID Signal
data=$(read_reg 0x10)
echo -e "     P0 ID Signal           Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status P0_SP5R_4              $data 0x80 7 U
signal_status P0_SP5R_3              $data 0x40 6 U
signal_status P0_SP5R_2              $data 0x20 6 U
signal_status P0_SP5R_1              $data 0x10 4 U
signal_status RSVD                   $data 0x08 3 0
signal_status P0_CORETYPE_2          $data 0x04 2 U
signal_status P0_CORETYPE_1          $data 0x02 1 U
signal_status P0_CORETYPE_0          $data 0x01 0 U
printf "\n"

# P1 ID Signal
data=$(read_reg 0x11)
echo -e "     P1 ID Signal           Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status P1_SP5R_4              $data 0x80 7 U
signal_status P1_SP5R_3              $data 0x40 6 U
signal_status P1_SP5R_2              $data 0x20 6 U
signal_status P1_SP5R_1              $data 0x10 4 U
signal_status RSVD                   $data 0x08 3 0
signal_status P1_CORETYPE_2          $data 0x04 2 U
signal_status P1_CORETYPE_1          $data 0x02 1 U
signal_status P1_CORETYPE_0          $data 0x01 0 U
printf "\n"

# P0 Power En
data=$(read_reg 0x12)
echo -e "    P0 PWR_EN Signal        Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 U
signal_status P0_VDD_CORE_1_RUN_EN   $data 0x40 6 U
signal_status P0_VDD_CORE_0_RUN_EN   $data 0x20 6 U
signal_status P0_VDD_SOC_0_RUN_EN    $data 0x10 4 U
signal_status P0_VDD_VDDIO_RUN_EN    $data 0x08 3 U
signal_status P0_VDD_11_SUS_EN       $data 0x04 2 U
signal_status P0_VDD_18_DUAL_EN      $data 0x02 1 U
signal_status P0_VDD_33_DUAL_EN      $data 0x01 0 U
printf "\n"

# P0 Power Good Signals
data=$(read_reg 0x13)
echo -e "    P0 PWR_GD Signal        Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status P0_PWR_GOOD            $data 0x80 7 U
signal_status P0_VDD_CORE_1_RUN_PG   $data 0x40 6 U
signal_status P0_VDD_CORE_0_RUN_PG   $data 0x20 6 U
signal_status P0_VDD_SOC_0_RUN_PG    $data 0x10 4 U
signal_status P0_VDD_VDDIO_RUN_PG    $data 0x08 3 U
signal_status P0_VDD_11_SUS_PG       $data 0x04 2 U
signal_status P0_VDD_18_DUAL_PG      $data 0x02 1 U
signal_status P0_VDD_33_DUAL_PG      $data 0x01 0 U
printf "\n"

# P1 Power En
data=$(read_reg 0x14)
echo -e "    P1 PWR_EN Signal        Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 U
signal_status P1_VDD_CORE_1_RUN_EN   $data 0x40 6 U
signal_status P1_VDD_CORE_0_RUN_EN   $data 0x20 6 U
signal_status P1_VDD_SOC_0_RUN_EN    $data 0x10 4 U
signal_status P1_VDD_VDDIO_RUN_EN    $data 0x08 3 U
signal_status P1_VDD_11_SUS_EN       $data 0x04 2 U
signal_status P1_VDD_18_DUAL_EN      $data 0x02 1 U
signal_status P1_VDD_33_DUAL_EN      $data 0x01 0 U
printf "\n"

# P1 Power Good Signals
data=$(read_reg 0x15)
echo -e "    P1 PWR_GD Signal        Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status P1_PWR_GOOD            $data 0x80 7 U
signal_status P1_VDD_CORE_1_RUN_PG   $data 0x40 6 U
signal_status P1_VDD_CORE_0_RUN_PG   $data 0x20 6 U
signal_status P1_VDD_SOC_0_RUN_PG    $data 0x10 4 U
signal_status P1_VDD_VDDIO_RUN_PG    $data 0x08 3 U
signal_status P1_VDD_11_SUS_PG       $data 0x04 2 U
signal_status P1_VDD_18_DUAL_PG      $data 0x02 1 U
signal_status P1_VDD_33_DUAL_PG      $data 0x01 0 U
printf "\n"

# P0 Error Signals
data=$(read_reg 0x16)
echo -e "    P0 Error Signal         Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 U
signal_status P0_SMERR_L             $data 0x40 6 U
signal_status P0_PROCHOT_L           $data 0x20 6 U
signal_status P0_THERMTRIP_L         $data 0x10 4 U
signal_status RSVD                   $data 0x08 3 U
signal_status RSVD                   $data 0x04 2 U
signal_status P0_DIMM_GL_ERROR       $data 0x02 1 U
signal_status P0_DIMM_AF_ERROR       $data 0x01 0 U
printf "\n"

# P1 Error Signals
data=$(read_reg 0x17)
echo -e "    P1 Error Signal         Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 U
signal_status P1_SMERR_L             $data 0x40 6 U
signal_status P1_PROCHOT_L           $data 0x20 6 U
signal_status P1_THERMTRIP_L         $data 0x10 4 U
signal_status RSVD                   $data 0x08 3 U
signal_status RSVD                   $data 0x04 2 U
signal_status P1_DIMM_GL_ERROR       $data 0x02 1 U
signal_status P1_DIMM_AF_ERROR       $data 0x01 0 U
printf "\n"

# I2C Alert Signals
data=$(read_reg 0x18)
echo -e "    I2C Alert Signal        Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 U
signal_status P0_I3C_APML_ALERT_L    $data 0x40 6 U
signal_status SCM_I2C_ALERT_L_7      $data 0x20 6 U
signal_status SCM_I2C_ALERT_L_6      $data 0x10 4 U
signal_status SCM_I2C_ALERT_L_5      $data 0x08 3 U
signal_status SCM_I2C_ALERT_L_3      $data 0x04 2 U
signal_status SCM_I2C_ALERT_L_2      $data 0x02 1 U
signal_status SCM_I2C_ALERT_L_1      $data 0x01 0 U
printf "\n"

# GPIO Bus 0
data=$(read_reg 0x20)
echo -e "     GPIO Bus 0             Default\tCurrent"
echo -e "    ----------------        -------\t-------"
echo -ne "NIC Mode                    LOM   \t"
case $data in
  0)
	echo LOM
	;;
  1)
	echo OCP 3.0
	;;
  2)
	echo Smart NIC
	;;
  *)
	echo Invalid Mode
	;;
esac
exit 0
