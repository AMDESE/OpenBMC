#!/bin/bash
echo
echo "-----  Ruby FPGA Register Dump Utility  -----"
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

# Reg map version
echo "Register Map version: $(read_reg 2)"

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
signal_status PS2_POK                $data 0x80 7 U
signal_status PS2_VIN_GOOD_BUF       $data 0x40 6 U
signal_status PS2_PRESENT_L          $data 0x20 5 U
signal_status RSVD                   $data 0x10 4 1
signal_status PS1_POK                $data 0x08 3 U
signal_status PS1_VIN_GOOD_BUF       $data 0x04 2 U
signal_status PS1_PRESENT_L          $data 0x02 1 U
signal_status RSVD                   $data 0x01 0 1
printf "\n"

# VR enable signals
data=$(read_reg 0x0C)
echo -e "    VR En Signal            Default\tCurrent"
echo -e "    ------------            -------\t-------"
signal_status PS2_ON_L               $data 0x80 7 U
signal_status PS1_ON_L_              $data 0x40 6 U
signal_status FM_AUX_SW_EN           $data 0x20 5 U
signal_status RSVD                   $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status VDD_33_EN              $data 0x04 2 U
signal_status VDD_3V3_AUX_EN         $data 0x02 1 U
signal_status VDD_5_AUX_EN           $data 0x01 0 U
printf "\n"

# VR PWR_GD
data=$(read_reg 0x0D)
echo -e "    VR PWR_GD Signal        Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status SCM_VDD_12_ALW_PG      $data 0x10 4 U
signal_status NIC_3V3_PG_BUF         $data 0x08 3 U
signal_status PWRGD_P_3V3            $data 0x04 2 U
signal_status VDD_33_SUS_P0_PG       $data 0x02 1 U
signal_status PWRGD_P_5V_AUX         $data 0x01 0 U
printf "\n"


# P0 Signal
data=$(read_reg 0x0E)
echo -e "        P0 Signal           Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status P0_PWROK               $data 0x10 4 U
signal_status P0_SLP_S5_L            $data 0x08 3 U
signal_status P0_SLP_S3_L            $data 0x04 2 U
signal_status P0_PRSNT_L             $data 0x02 1 U
signal_status RSVD                   $data 0x01 0 0
printf "\n"

# P1 Signal
data=$(read_reg 0x0F)
echo -e "        P1 Signal           Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status RSVD                   $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status RSVD                   $data 0x04 2 0
signal_status RSVD                   $data 0x02 1 0
signal_status RSVD                   $data 0x01 0 0
printf "\n"

# P0 ID Signal
data=$(read_reg 0x10)
echo -e "     P0 ID Signal           Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status P0_SP5R_4              $data 0x80 7 U
signal_status P0_SP5R_3              $data 0x40 6 U
signal_status P0_SP5R_2              $data 0x20 5 U
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
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status RSVD                   $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status RSVD                   $data 0x04 2 0
signal_status RSVD                   $data 0x02 1 0
signal_status RSVD                   $data 0x01 0 0
printf "\n"

# P0 Power En
data=$(read_reg 0x12)
echo -e "    P0 PWR_EN Signal        Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status VDDCR_CPU1_RUN_EN      $data 0x40 6 U
signal_status VDDCR_CPU0_RUN_EN      $data 0x20 5 U
signal_status VR_VDD_SOC_RUN_P0_EN   $data 0x10 4 U
signal_status VDDIO_RUN_P0_EN        $data 0x08 3 U
signal_status VR_VDD_11_SUS_P0_EN    $data 0x04 2 U
signal_status VDD_18_SUS_P0_EN       $data 0x02 1 U
signal_status VDD_33_SUS_EN          $data 0x01 0 U
printf "\n"

# P0 Power Good Signals
data=$(read_reg 0x13)
echo -e "    P0 PWR_GD Signal        Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status P0_PWR_GOOD            $data 0x80 7 U
signal_status VDDCR_CPU1_RUN_PG      $data 0x40 6 U
signal_status VDDCR_CPU0_RUN_PG      $data 0x20 5 U
signal_status VDDCR_SOC_RUN_PG       $data 0x10 4 U
signal_status VDDIO_RUN_P0_PG        $data 0x08 3 U
signal_status P_VDD_11_SUS_P0_PG     $data 0x04 2 U
signal_status PWRGD_P_VDD_18_SUS     $data 0x02 1 U
signal_status VDD_33_SUS_P0_PG       $data 0x01 0 U
printf "\n"

# Debug Signal 1
data=$(read_reg 0x14)
echo -e "    Debug Signal - 1        Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status P0_PWROK               $data 0x80 7 U
signal_status P0_SLP_S5_L            $data 0x40 6 U
signal_status P0_SLP_S3_L            $data 0x20 5 U
signal_status PWRSEQ_4               $data 0x10 4 U
signal_status PWRSEQ_3               $data 0x08 3 U
signal_status PWRSEQ_2               $data 0x04 2 U
signal_status PWRSEQ_1               $data 0x02 1 U
signal_status PWRSEQ_0               $data 0x01 0 U
printf "\n"

# Debug Signal 2
data=$(read_reg 0x15)
echo -e "    Debug Signal - 2        Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status P0_PWR_GOOD            $data 0x80 7 U
signal_status VDDCR_CPU1_RUN_PG      $data 0x40 6 U
signal_status VDDCR_CPU0_RUN_PG      $data 0x20 5 U
signal_status VDDCR_SOC_RUN_PG       $data 0x10 4 U
signal_status VDDIO_RUN_P0_PG        $data 0x08 3 U
signal_status P_VDD_11_SUS_P0_PG     $data 0x04 2 U
signal_status PWRGD_P_VDD_18_SUS     $data 0x02 1 U
signal_status VDD_33_SUS_P0_PG       $data 0x01 0 U
printf "\n"

# P0 Error Signals
data=$(read_reg 0x16)
echo -e "    P0 Error Signal         Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 U
signal_status P0_SMERR_L             $data 0x40 6 U
signal_status P0_PROCHOT_L           $data 0x20 5 U
signal_status P0_THERMTRIP_L         $data 0x10 4 U
signal_status RSVD                   $data 0x08 3 U
signal_status PMIC_ERROR             $data 0x04 2 U
signal_status P0_DIMM_GL_ERROR       $data 0x02 1 U
signal_status P0_DIMM_AF_ERROR       $data 0x01 0 U
printf "\n"

# P1 Error Signals
data=$(read_reg 0x17)
echo -e "    P1 Error Signal         Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status RSVD                   $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status RSVD                   $data 0x04 2 0
signal_status RSVD                   $data 0x02 1 0
signal_status RSVD                   $data 0x01 0 0
printf "\n"

# I2C Alert Signals
data=$(read_reg 0x18)
echo -e "    I2C Alert Signal        Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status P0_I3C_APML_ALERT_L    $data 0x40 6 U
signal_status SCM_I2C_7_ALERT_L_7    $data 0x20 5 U
signal_status SCM_I2C_6_ALERT_L_6    $data 0x10 4 U
signal_status SCM_I2C_5_ALERT_L_5    $data 0x08 3 U
signal_status RSVD                   $data 0x04 2 1
signal_status SCM_I2C_2_ALERT_L_2    $data 0x02 1 U
signal_status SCM_I2C_1_ALERT_L_1    $data 0x01 0 U
printf "\n"

# I2C Reset Signals
data=$(read_reg 0x19)
echo -e "    I2C Reset Signal        Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 1
signal_status FPGA_P0_PCIE1_RST_L    $data 0x20 5 U
signal_status FPGA_SCM_PCIE_RST_L    $data 0x10 4 U
signal_status P0_SYS_RESEST_L        $data 0x08 3 U
signal_status P0_RSMRST_L            $data 0x04 2 U
signal_status P0_KBRST_L             $data 0x02 1 U
signal_status P0_RESET_L             $data 0x01 0 U
printf "\n"

# P conn Signals
data=$(read_reg 0x1A)
echo -e "    P conn Signal           Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status RSVD                   $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status RSVD                   $data 0x04 2 0
signal_status RSVD                   $data 0x02 1 0
signal_status RSVD                   $data 0x01 0 0
printf "\n"

# G conn Signals
data=$(read_reg 0x1B)
echo -e "    P conn Signal           Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status RSVD                   $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status RSVD                   $data 0x04 2 0
signal_status RSVD                   $data 0x02 1 0
signal_status RSVD                   $data 0x01 0 0
printf "\n"

# Debug Signals 3
data=$(read_reg 0x1C)
echo -e "    Debug 3 Signal           Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status stb_data_count_7       $data 0x80 7 U
signal_status stb_data_count_6       $data 0x40 6 U
signal_status stb_data_count_5       $data 0x20 5 U
signal_status stb_data_count_4       $data 0x10 4 U
signal_status stb_data_count_3       $data 0x08 3 U
signal_status stb_data_count_2       $data 0x04 2 U
signal_status stb_data_count_1       $data 0x02 1 U
signal_status stb_data_count_0       $data 0x01 0 U
printf "\n"

# Debug FPGA Signals
data=$(read_reg 0x1D)
echo -e "    Dbg FPGA Signal         Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status hawaii_installed       $data 0x40 6 U
signal_status bmc_ready              $data 0x20 5 U
signal_status enable_dimms           $data 0x10 4 U
signal_status P0_S5_pwr_goods        $data 0x08 3 U
signal_status P0_AGPIO_109           $data 0x04 2 U
signal_status prog_mode_1            $data 0x02 1 U
signal_status prog_mode_0            $data 0x01 0 U
printf "\n"

# Hawaii Signals
data=$(read_reg 0x1E)
echo -e "    Hawaii Signal           Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status SCM_SPARE1             $data 0x80 7 U
signal_status ESPI_BOOT_MODE_int     $data 0x40 6 U
signal_status SCM_IRQ_L              $data 0x20 5 U
signal_status HPM_STBY_RSTT_L        $data 0x10 4 U
signal_status SCM_ROT_CPU_RST_L      $data 0x08 3 U
signal_status SCM_SYS_PWROK          $data 0x04 2 U
signal_status SCM_SYS_PWRBTN_L       $data 0x02 1 U
signal_status SCM_VDD_12_ALW_PG      $data 0x01 0 U
printf "\n"

# Debug Signals
data=$(read_reg 0x1F)
echo -e "    Debug Signals           Default\tCurrent"
echo -e "    ----------------        -------\t-------"
signal_status FM_CLR_CMOS            $data 0x80 7 U
signal_status MGMT_HDT_SEL           $data 0x40 6 U
signal_status BIOS_SPD_CTRL_REL_L    $data 0x20 5 U
signal_status pwrseq_state_4         $data 0x10 4 U
signal_status pwrseq_state_3         $data 0x08 3 U
signal_status pwrseq_state_2         $data 0x04 2 U
signal_status pwrseq_state_1         $data 0x02 1 U
signal_status pwrseq_state_0         $data 0x01 0 U
printf "\n"

## Registers after these are Remote control registers
## to set/unset various signals. skipping them as
## they are not required for registry dump.

exit 0
