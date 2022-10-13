#!/bin/bash
echo
echo "-----  Quartz FPGA Register Dump Utility  -----"
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

# FPGA FW Version Information
MAJOR=$(read_reg 0)
MINOR=$(read_reg 1)
echo FPGA FW version: $MAJOR.$MINOR

# Device ID
echo Device ID: $(read_reg 2)

# Scratchpad
echo Scratchpad: $(read_reg 4)

# OCP NIC status
data=$(read_reg 0x05)
echo -e "    OCP NIC STS             Default\tCurrent"
echo -e "    -----------             -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status FPGA_OCP_AUX_PWR_EN    $data 0x10 4 0
signal_status FPGA_OCP_MAIN_PWR_EN   $data 0x08 3 0
signal_status FPGA_OCP_SFF_PWR_GOOD  $data 0x04 2 0
signal_status OCP_AUX_PWR_EN         $data 0x02 1 0
signal_status PWRGD_NIC_PWR_GOOD     $data 0x01 0 0
printf "\n"

# PMbus Alert 1
data=$(read_reg 0x06)
echo -e "    PMbus Alert 1           Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status wFM_BMC_SYS_THROTTLE_N $data 0x20 5 1
signal_status wFM_CPU0_PWRBRK_R_N    $data 0x10 4 1
signal_status PMBUS_ALERT_N          $data 0x08 3 1
signal_status FM_MG9100_BMC_ALERT_N  $data 0x04 2 1
signal_status APML_CPU0_ALERT_N      $data 0x02 1 1
signal_status APML_CPU1_ALERT_N      $data 0x01 0 1
printf "\n"

# Button
data=$(read_reg 0x07)
echo -e "    Button                  Default\tCurrent"
echo -e "    ------                  -------\t-------"
signal_status RSVD                   $data 0x80 7 1
signal_status RSVD                   $data 0x40 6 1
signal_status FM_CPU0_PWR_BTN_N      $data 0x20 5 1
signal_status RSVD                   $data 0x10 4 1
signal_status SCM_SYS_PWRBTN_N       $data 0x08 3 1
signal_status WARM_RST_BTN_N         $data 0x04 2 1
signal_status FP_PWR_BTN_BUF_R_N     $data 0x02 1 1
signal_status FP_ID_BTN_R_N          $data 0x01 0 1
printf "\n"

# Thermtrip
data=$(read_reg 0x09)
echo -e "    Thermtrip               Default\tCurrent"
echo -e "    ---------               -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status RSVD                   $data 0x10 4 0
signal_status shutdown_error         $data 0x08 3 0
signal_status thermal_error          $data 0x04 2 0
signal_status FM_CPU1_THERMTRIP_N    $data 0x02 1 1
signal_status FM_CPU0_THERMTRIP_N    $data 0x01 0 1
printf "\n"

# PMbus Alert 2
data=$(read_reg 0x0A)
echo -e "    PMbus Alert 2           Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status RSVD                   $data 0x10 4 0
signal_status SCM_I2C_ALERT_N_6      $data 0x08 3 1
signal_status SCM_I2C_ALERT_N_3      $data 0x04 2 1
signal_status SCM_I2C_ALERT_N_2      $data 0x02 1 1
signal_status SCM_I2C_ALERT_N_1      $data 0x01 0 1
printf "\n"

# Group A PG
data=$(read_reg 0x0B)
echo -e "    Group A PG              Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status P12V_SCM_PG            $data 0x80 7 0
signal_status SCM_ROT_CPU_RST_N      $data 0x40 6 0
signal_status HPM_STBY_RST_N         $data 0x20 5 0
signal_status PWRGD_P1V0_AUX         $data 0x10 4 0
signal_status PWRGD_P1V8_AUX         $data 0x08 3 0
signal_status PWRGD_P1V2_AUX_A       $data 0x04 2 0
signal_status PWRGD_P1V2_AUX_B       $data 0x02 1 0
signal_status FM_PWRGD_P1V2_AUX      $data 0x01 0 0
printf "\n"

# Group B PG
data=$(read_reg 0x0C)
echo -e "    Group B PG              Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status RSVD                   $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status PWRGD_PVDD33_S5        $data 0x04 2 0
signal_status PWRGD_PVDD18_S5_P1     $data 0x02 1 0
signal_status PWRGD_PVDD18_S5_P0     $data 0x01 0 0
printf "\n"

# Group C PG
data=$(read_reg 0x0D)
echo -e "    Group C PG              Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status PWRGD_PVDD11_S3_P1     $data 0x80 7 0
signal_status PWRGD_PVDD11_S3_P0     $data 0x40 6 0
signal_status PWRGD_P0V9_RETIMER_B   $data 0x20 5 0
signal_status PWRGD_P0V9_RETIMER_A   $data 0x10 4 0
signal_status PWRGD_P1V8_RETIMER     $data 0x08 3 0
signal_status PWRGD_P3V3             $data 0x04 2 0
signal_status PWRGD_PS1_PWROK_BUF    $data 0x02 1 0
signal_status PWRGD_PS0_PWROK_BUF    $data 0x01 0 0
printf "\n"

# DIMM PG
data=$(read_reg 0x0E)
echo -e "       DIMM PG              Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status RSVD                   $data 0x10 4 0
signal_status PWRGD_CHGL_CPU1        $data 0x08 3 0
signal_status PWRGD_CHAF_CPU1        $data 0x04 2 0
signal_status PWRGD_CHGL_CPU0        $data 0x02 1 0
signal_status PWRGD_CHGAFCPU0        $data 0x01 0 0
printf "\n"

# Group D PG
data=$(read_reg 0x0F)
echo -e "    Group D PG              Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status PWRGD_PVDDCR_CPU1_P1   $data 0x80 7 0
signal_status PWRGD_PVDDCR_CPU1_P0   $data 0x40 6 0
signal_status PWRGD_PVDDCR_SOC_P1    $data 0x20 5 0
signal_status PWRGD_PVDDIO_P1        $data 0x10 4 0
signal_status PWRGD_PVDDCR_CPU0_P1   $data 0x08 3 0
signal_status PWRGD_PVDDCR_CPU0_P0   $data 0x04 2 0
signal_status PWRGD_PVDDCR_SOC_P0    $data 0x02 1 0
signal_status PWRGD_PVDDIO_P0        $data 0x01 0 0
printf "\n"

# Group B EN
data=$(read_reg 0x10)
echo -e "    Group B EN              Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status FM_P1V2_AUX_B_R_EN     $data 0x80 7 0
signal_status FM_P1V2_AUX_A_R_EN     $data 0x40 6 0
signal_status FM_USB_REAR_EN_R_N     $data 0x20 5 0
signal_status FM_USB_INT_EN_R_N      $data 0x10 4 0
signal_status FM_USB_FRONT_EN_R_N    $data 0x08 3 0
signal_status FM_PVDD33_S5_EN        $data 0x04 2 0
signal_status PVDD18_S5_P1_R_EN      $data 0x02 1 0
signal_status PVDD18_S5_P0_R_EN      $data 0x01 0 0
printf "\n"

# Group C EN
data=$(read_reg 0x11)
echo -e "    Group C EN              Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status FM_PVDD11_S3_P1_EN     $data 0x80 7 0
signal_status FM_PVDD11_S3_P0_EN     $data 0x40 6 0
signal_status FM_P0V9_RETIMER_B_EN   $data 0x20 5 0
signal_status FM_P0V9_RETIMER_A_EN   $data 0x10 4 0
signal_status FM_P1V8_RETIMER_EN     $data 0x08 3 0
signal_status FM_P3V3_EN             $data 0x04 2 0
signal_status FM_P12V_AUX_SW_R_EN    $data 0x02 1 0
signal_status FM_PS_ON_R             $data 0x01 0 0
printf "\n"

# Group D EN
data=$(read_reg 0x12)
echo -e "    Group D EN              Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status FM_PVDDCR_CPU1_P1_R_EN $data 0x80 7 0
signal_status PVDDCR_CPU0_P1_EN      $data 0x40 6 0
signal_status PVDDCR_SOC_P1_EN       $data 0x20 5 0
signal_status FM_PVDDIO_P1_EN        $data 0x10 4 0
signal_status FM_PVDDCR_CPU1_P0_R_EN $data 0x08 3 0
signal_status PVDDCR_CPU0_P0_EN      $data 0x04 2 0
signal_status PVDDCR_SOC_P0_EN       $data 0x02 1 0
signal_status FM_PVDDIO_P0_EN        $data 0x01 0 0
printf "\n"

# Group EN
data=$(read_reg 0x13)
echo -e "     Group EN               Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status RSVD                   $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status grpd_en                $data 0x04 2 0
signal_status grpc_en                $data 0x02 1 0
signal_status grpb_en                $data 0x01 0 0
printf "\n"

# Group PG
data=$(read_reg 0x14)
echo -e "    Group PG                Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status RSVD                   $data 0x10 4 0
signal_status grpd_pg                $data 0x08 3 0
signal_status grpc_pg                $data 0x04 2 0
signal_status grpb_pg                $data 0x02 1 0
signal_status grpa_pg                $data 0x01 0 0
printf "\n"

# CPU power good
data=$(read_reg 0x15)
echo -e "    CPU Power Good          Default\tCurrent"
echo -e "    --------------          -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status FM_PWRGD_CPU1_PWROK    $data 0x20 5 0
signal_status FM_PWRGD_CPU0_PWROK    $data 0x10 4 0
signal_status CPU1_PWRGD_OUT         $data 0x08 3 0
signal_status FM_CPU1_PWRGD          $data 0x04 2 0
signal_status CPU0_PWRGD_OUT         $data 0x02 1 0
signal_status FM_CPU0_PWRGD          $data 0x01 0 0
printf "\n"

# Reset
data=$(read_reg 0x16)
echo -e "    Reset                   Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status CPU0_KBRST_N           $data 0x40 6 0
signal_status FM_CPU0_SYS_RESET_N    $data 0x20 5 0
signal_status FM_RST_CPU0_RESET_N    $data 0x10 4 0
signal_status FM_RST_CPU1_RESET_N    $data 0x08 3 0
signal_status RST_RETIMER_CPU0_N     $data 0x04 2 0
signal_status FM_CPU1_RSMRST_N       $data 0x02 1 0
signal_status FM_CPU0_RSMRST_N       $data 0x01 0 0
printf "\n"

# PERESET
data=$(read_reg 0x17)
echo -e "     Group EN               Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status RST_CPU1_PERST1_N      $data 0x80 7 0
signal_status RST_CPU1_PERST0_N      $data 0x40 6 0
signal_status RST_CPU0_PERST1_N      $data 0x20 5 0
signal_status RST_CPU0_PERST0_N      $data 0x10 4 0
signal_status PERST_RETIMER_CPU1_N   $data 0x08 3 0
signal_status PERST_RETIMER_CPU0_N   $data 0x04 2 0
signal_status PERST_FPGA_CPU1_R_N    $data 0x02 1 0
signal_status PERST_FPGA_CPU0_R_N    $data 0x01 0 0
printf "\n"

# PERESET
data=$(read_reg 0x18)
echo -e "     Group EN               Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status FPGA_CPU0_PCIE_RST_N_1 $data 0x40 6 0
signal_status FM_UBM5_PERST_N        $data 0x20 5 0
signal_status FM_UBM4_PERST_N        $data 0x10 4 0
signal_status FM_UBM3_PERST_N        $data 0x08 3 0
signal_status FM_UBM2_PERST_N        $data 0x04 2 0
signal_status FM_UBM1_PERST_N        $data 0x02 1 0
signal_status FM_UBM0_PERST_N        $data 0x01 0 0
printf "\n"

# Misc 1
data=$(read_reg 0x19)
echo -e "    MISC 1                  Default\tCurrent"
echo -e "    ---------               -------\t-------"
signal_status CPU0_SLP_S5_N          $data 0x80 7 0
signal_status CPU0_SLP_S3_N          $data 0x40 6 0
signal_status CPU1_CORETYPE2         $data 0x20 5 0
signal_status CPU1_CORETYPE1         $data 0x10 4 0
signal_status CPU1_CORETYPE0         $data 0x08 3 0
signal_status CPU0_CORETYPE2         $data 0x04 2 0
signal_status CPU0_CORETYPE1         $data 0x02 1 0
signal_status CPU0_CORETYPE0         $data 0x01 0 0
printf "\n"

# Misc 2
data=$(read_reg 0x1A)
echo -e "    Misc 2                  Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status CPU1_SP5R4             $data 0x80 7 0
signal_status CPU1_SP5R3             $data 0x40 6 0
signal_status CPU1_SP5R2             $data 0x20 5 0
signal_status CPU1_SP5R1             $data 0x10 4 0
signal_status CPU0_SP5R4             $data 0x08 3 0
signal_status CPU0_SP5R3             $data 0x04 2 0
signal_status CPU0_SP5R2             $data 0x02 1 0
signal_status CPU0_SP5R1             $data 0x01 0 0
printf "\n"

# PRSNT 1
data=$(read_reg 0x1B)
echo -e "    PRSNT 1                 Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status RISER2_SLOT3_PRSNT_N   $data 0x80 7 0
signal_status RISER2_SLOT2_PRSNT_N   $data 0x40 6 0
signal_status RISER1_SLOT1_PRSNT_N   $data 0x20 5 0
signal_status PSU1_PRSNT_BUF_N       $data 0x10 4 0
signal_status PSU0_PRSNT_BUF_N       $data 0x08 3 0
signal_status PRSNT_FPGA_SCM         $data 0x04 2 0
signal_status PRNST_CPU1_N           $data 0x02 1 0
signal_status PRNST_CPU0_N           $data 0x01 0 0
printf "\n"

# PRSNT 2
data=$(read_reg 0x1C)
echo -e "    PRSNT 2                 Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status RSVD                   $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status RSVD                   $data 0x04 2 0
signal_status PRSNT_SATA_N           $data 0x02 1 0
signal_status FPGA_FACTORY_MODE_N    $data 0x01 0 0
printf "\n"

# SGPO A
data=$(read_reg 0x1D)
echo -e "    SGPO A                  Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status FM_CLR_CMOS            $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status SCM_IRQ_N              $data 0x20 5 1
signal_status SCM_SPARE_1            $data 0x10 4 0
signal_status SCM_SPARE_0            $data 0x08 3 0
signal_status FAN_P12V_DISABLE       $data 0x04 2 0
signal_status FM_FP_ID_LED_FP        $data 0x02 1 0
signal_status FM_FP_FAULT_LED        $data 0x01 0 0
printf "\n"

# SGPO B
data=$(read_reg 0x1E)
echo -e "       SGPO B                Default\tCurrent"
echo -e "    -------------            -------\t-------"
signal_status FM_I3C_MUX_OE_L_1       $data 0x80 7 0
signal_status FM_I3C_MUX_OE_L_0       $data 0x40 6 0
signal_status FM_HDT_CPU0_XLTR_SEL1_N $data 0x20 5 0
signal_status FM_HDT_CPU0_XLTR_SEL0_N $data 0x10 4 1
signal_status FM_CPU1_HDT_BYPASS_SEL  $data 0x08 3 1
signal_status FM_CPU0_HDT_BYPASS_SEL  $data 0x04 2 1
signal_status CPU1_HDT_R_SEL_N        $data 0x02 1 0
signal_status CPU0_HDT_R_SEL_N        $data 0x01 0 0
printf "\n"

# SGPO C
data=$(read_reg 0x1F)
echo -e "    SGPO C                  Default\tCurrent"
echo -e "    -------------           -------\t-------"
signal_status JTAG_SCM_TRST_R_N      $data 0x80 7 1
signal_status FM_SCM_JTAG_MUX_SEL    $data 0x40 6 0
signal_status FM_I3C_MUX_SEL_3       $data 0x20 5 0
signal_status FM_I3C_MUX_SEL_2       $data 0x10 4 0
signal_status FM_I3C_MUX_SEL_1       $data 0x08 3 0
signal_status FM_I3C_MUX_SEL_0       $data 0x04 2 0
signal_status FM_I3C_MUX_OE_L_3      $data 0x02 1 0
signal_status FM_I3C_MUX_OE_L_2      $data 0x01 0 0
printf "\n"

# SGPO D
data=$(read_reg 0x20)
echo -e "    SGPO D                   Default\tCurrent"
echo -e "    -------------            -------\t-------"
signal_status RST_PCA9848_CPU1_I2C5_N $data 0x80 7 1
signal_status RST_PCA9848_CPU0_I2C5_N $data 0x40 6 0
signal_status SPI_MUX_SEL_8           $data 0x20 5 1
signal_status SPI_MUX_SEL_7           $data 0x10 4 1
signal_status SPI_MUX_SEL_5           $data 0x08 3 0
signal_status SPI_MUX_SEL_3           $data 0x04 2 1
signal_status SPI_MUX_SEL_2           $data 0x02 1 1
signal_status SPI_MUX_SEL_0           $data 0x01 0 0
printf "\n"

# SGPO E
data=$(read_reg 0x21)
echo -e "    SGPO E                       Default\tCurrent"
echo -e "    -------------                -------\t-------"
signal_status FM_CPU1_NMI_SYNC_FLOOD_N    $data 0x80 7 1
signal_status FM_CPU0_NMI_SYNC_FLOOD_N    $data 0x40 6 1
signal_status RST_CPU0_I2C4_HP_UBM_MUX_N  $data 0x20 5 1
signal_status RST_CPU0_I2C4_N             $data 0x10 4 1
signal_status RST_PCA9848_SCM_I2C6_N      $data 0x08 3 1
signal_status RST_PCA9848_SCM_I2C8_N      $data 0x04 2 1
signal_status RST_PCA9848_SCM_I2C7_MUX2_N $data 0x02 1 1
signal_status RST_PCA9848_SCM_I2C7_MUX1_N $data 0x01 0 1
printf "\n"

for reg in {34..127}
do
    data=$(read_reg $reg)
    printf ' Reg 0x%x (%d) = 0x%x \n' $reg $reg $data
done

exit 0
