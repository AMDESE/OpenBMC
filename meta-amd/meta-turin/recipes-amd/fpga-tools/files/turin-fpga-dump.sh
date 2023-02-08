#!/bin/bash

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

#Board ID
board_id=$(read_reg 1)
case "$board_id" in
    "102" | "110" | "111")
        printf '\nChalupa FPGA Register Dump \n'
        echo   '=============================='
        ;;
    "103")
        printf '\nHuambo FPGA Register Dump \n'
        echo   '=============================='
        ;;
    "104" | "112" | "113")
        printf '\nGalena FPGA Register Dump \n'
        echo   '=============================='
        ;;
    "105")
        printf '\nRecluse FPGA Register Dump \n'
        echo   '=============================='
        ;;
    "106" | "114" | "115")
        printf '\nPurico FPGA Register Dump \n'
        echo   '=============================='
        ;;
    "107" | "116" | "117")
        printf '\nVolcano FPGA Register Dump \n'
        echo   '=============================='
        ;;
    *)
        echo " Unknown platform"
        echo " Please program board FRU EEPROM"
        ;;
esac
# FPGA FW Version Information
printf 'Magic Byte:\t 0x%x \n' $(read_reg 0)
printf 'I2C Map Version:   %d \n'  $(read_reg 2)
if [ $(read_reg 2) -ne $SCRIPT_REG_MAP_VER ] ; then
        echo "Register map version mismatch"
fi
REV_W=$(read_reg 6)
REV_X=$(read_reg 5)
REV_Y=$(read_reg 4)
REV_Z=$(read_reg 3)
echo "FPGA FW version:  "   $REV_W.$REV_X.$REV_Y.$REV_Z
printf 'SGPIO Map Version: %x \n' $(read_reg 7)
printf '\n'
printf 'Reg 0x08 (S1 Switch)=\t 0x%x \n' $(read_reg 8)
printf 'Reg 0x09 (S2 Switch)=\t 0x%x \n' $(read_reg 9)
printf 'Reg 0x0A (S3 Switch)=\t 0x%x \n' $(read_reg 0x0A)
printf '\n'
# PSU
printf 'Reg 0x0B (PSU Signals)=\t 0x%x \n' $(read_reg 0x0B)
data=$(read_reg 0x0B)
echo  "   PSU Signals             Default  Current "
echo  "------------------------------------------- "

signal_status PSU_PWROK_BUF_1        $data 0x80 7 0
signal_status PSU_VIN_GOOD_BUF_1     $data 0x40 6 0
signal_status PSU_PRSNT_BUF_L_1      $data 0x20 5 0
signal_status PWR_CONN_PRSNT_L_1     $data 0x10 4 0
signal_status PSU_PWROK_BUF_0        $data 0x08 3 0
signal_status PSU_VIN_GOOD_BUF_0     $data 0x04 2 0
signal_status PSU_PRSNT_BUF_L_0      $data 0x02 1 0
signal_status PWR_CONN_PRSNT_L_0     $data 0x01 0 0
printf "\n"

printf 'Reg 0x0C (VR Enable)=\t 0x%x \n' $(read_reg 0x0C)
data=$(read_reg 0x0C)
echo  "    VR Enable              Default  Current "
echo  "------------------------------------------- "

signal_status PSU_PSON_L_1           $data 0x80 7 0
signal_status PSU_PSON_L_0           $data 0x40 6 0
signal_status VDD_12_RUN_DUAL_EN     $data 0x20 5 0
signal_status VDD_12_ALW_DUAL_EN     $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status VDD_33_RUN_EN          $data 0x04 2 0
signal_status VDD_33_DUAL_EN         $data 0x02 1 0
signal_status VDD_5_DUAL_EN          $data 0x01 0 0
printf "\n"

printf 'Reg 0x0D (Common VR)=\t 0x%x \n' $(read_reg 0x0D)
data=$(read_reg 0x0D)
echo  "    Common VR              Default  Current "
echo  "------------------------------------------- "

signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status SCM_VDD_12_ALW_PG      $data 0x10 4 0
signal_status LOM_VDD_33_ALW_PG_BUF  $data 0x08 3 0
signal_status VDD_33_RUN_PG          $data 0x04 2 0
signal_status VDD_33_DUAL_PG         $data 0x02 1 0
signal_status VDD_5_DUAL_PG          $data 0x01 0 0
printf "\n"

printf 'Reg 0x0E (P0 Signals)=\t 0x%x \n' $(read_reg 0x0E)
data=$(read_reg 0x0E)
echo  "    P0 Signas              Default  Current "
echo  "------------------------------------------- "

signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status P0_PWROK               $data 0x10 4 0
signal_status P0_SLP_S5_L            $data 0x08 3 0
signal_status P0_SLP_S3_L            $data 0x04 2 0
signal_status P0_PRSNT_L             $data 0x02 1 0
signal_status P0_ORIENTATION_OK      $data 0x01 0 0
printf "\n"

printf 'Reg 0x0F (P1 Signals)=\t 0x%x \n' $(read_reg 0x0F)
data=$(read_reg 0x0F)
echo  "    P1 Signas              Default  Current "
echo  "------------------------------------------- "

signal_status RSVD                   $data 0x80 7 0
signal_status RSVD                   $data 0x40 6 0
signal_status RSVD                   $data 0x20 5 0
signal_status P1_PWROK               $data 0x10 4 0
signal_status P1_SLP_S5_L            $data 0x08 3 0
signal_status P1_SLP_S3_L            $data 0x04 2 0
signal_status P1_PRSNT_L             $data 0x02 1 0
signal_status P1_ORIENTATION_OK      $data 0x01 0 0
printf "\n"

printf 'Reg 0x10 (P0 ID Signals)=\t 0x%x \n' $(read_reg 0x10)
data=$(read_reg 0x10)
echo  "    P0 ID Signas           Default  Current "
echo  "------------------------------------------- "

signal_status P0_SP5R_4              $data 0x80 7 0
signal_status P0_SP5R_3              $data 0x40 6 0
signal_status P0_SP5R_2              $data 0x20 5 0
signal_status P0_SP5R_1              $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status P0_CORETYPE_2          $data 0x04 2 0
signal_status P0_CORETYPE_1          $data 0x02 1 0
signal_status P0_CORETYPE_0          $data 0x01 0 0
printf "\n"

printf 'Reg 0x11 (P1 ID Signals)=\t 0x%x \n' $(read_reg 0x11)
data=$(read_reg 0x11)
echo  "    P1 ID Signas           Default  Current "
echo  "------------------------------------------- "

signal_status P1_SP5R_4              $data 0x80 7 0
signal_status P1_SP5R_3              $data 0x40 6 0
signal_status P1_SP5R_2              $data 0x20 5 0
signal_status P1_SP5R_1              $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status P1_CORETYPE_2          $data 0x04 2 0
signal_status P1_CORETYPE_1          $data 0x02 1 0
signal_status P1_CORETYPE_0          $data 0x01 0 0
printf "\n"

printf 'Reg 0x12 (P0 PWR Enable)=\t 0x%x \n' $(read_reg 0x12)
data=$(read_reg 0x12)
echo  "    P0 PWR Enable          Default  Current "
echo  "------------------------------------------- "

signal_status RSVD                   $data 0x80 7 0
signal_status P0_VDD_CORE_1_RUN_EN   $data 0x40 6 0
signal_status P0_VDD_CORE_0_RUN_EN   $data 0x20 5 0
signal_status P0_VDD_SOC_0_RUN_EN    $data 0x10 4 0
signal_status P0_VDD_VDDIO_RUN_EN    $data 0x08 3 0
signal_status P0_VDD_11_SUS_EN       $data 0x04 2 0
signal_status P0_VDD_18_DUAL_EN      $data 0x02 1 0
signal_status P0_VDD_33_DUAL_EN      $data 0x01 0 0
printf "\n"

printf 'Reg 0x13 (P0 PWR Good)=\t 0x%x \n' $(read_reg 0x13)
data=$(read_reg 0x13)
echo  "     P0 PWR Good           Default  Current "
echo  "------------------------------------------- "

signal_status P0_PWR_GOOD            $data 0x80 7 0
signal_status P0_VDD_CORE_1_RUN_PG   $data 0x40 6 0
signal_status P0_VDD_CORE_0_RUN_PG   $data 0x20 5 0
signal_status P0_VDD_SOC_0_RUN_PG    $data 0x10 4 0
signal_status P0_VDD_VDDIO_RUN_PG    $data 0x08 3 0
signal_status P0_VDD_11_SUS_PG       $data 0x04 2 0
signal_status P0_VDD_18_DUAL_PG      $data 0x02 1 0
signal_status P0_VDD_33_DUAL_PG      $data 0x01 0 0
printf "\n"

printf 'Reg 0x14 (P1 PWR Enable)=\t 0x%x \n' $(read_reg 0x14)
data=$(read_reg 0x14)
echo  "    P1 PWR Enable          Default  Current "
echo  "------------------------------------------- "

signal_status RSVD                   $data 0x80 7 0
signal_status P1_VDD_CORE_1_RUN_EN   $data 0x40 6 0
signal_status P1_VDD_CORE_0_RUN_EN   $data 0x20 5 0
signal_status P1_VDD_SOC_0_RUN_EN    $data 0x10 4 0
signal_status P1_VDD_VDDIO_RUN_EN    $data 0x08 3 0
signal_status P1_VDD_11_SUS_EN       $data 0x04 2 0
signal_status P1_VDD_18_DUAL_EN      $data 0x02 1 0
signal_status P1_VDD_33_DUAL_EN      $data 0x01 0 0
printf "\n"

printf 'Reg 0x15 (P1 PWR Good)=\t 0x%x \n' $(read_reg 0x15)
data=$(read_reg 0x15)
echo  "     P0 PWR Good           Default  Current "
echo  "------------------------------------------- "

signal_status P1_PWR_GOOD            $data 0x80 7 0
signal_status P1_VDD_CORE_1_RUN_PG   $data 0x40 6 0
signal_status P1_VDD_CORE_0_RUN_PG   $data 0x20 5 0
signal_status P1_VDD_SOC_0_RUN_PG    $data 0x10 4 0
signal_status P1_VDD_VDDIO_RUN_PG    $data 0x08 3 0
signal_status P1_VDD_11_SUS_PG       $data 0x04 2 0
signal_status P1_VDD_18_DUAL_PG      $data 0x02 1 0
signal_status P1_VDD_33_DUAL_PG      $data 0x01 0 0
printf "\n"

printf 'Reg 0x16 (P0 Error)=\t 0x%x \n' $(read_reg 0x16)
data=$(read_reg 0x16)
echo  "      P0 Error             Default  Current "
echo  "------------------------------------------- "

signal_status RSVD                   $data 0x80 7 0
signal_status P0_SMERR_L             $data 0x40 6 0
signal_status P0_PROCHOT_L           $data 0x20 5 0
signal_status P0_THERMTRIP_L         $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status RSVD                   $data 0x04 2 0
signal_status P0_DIMM_GL_error       $data 0x02 1 0
signal_status P0_DIMM_AF_error       $data 0x01 0 0
printf "\n"

printf 'Reg 0x17 (P1 Error)=\t 0x%x \n' $(read_reg 0x17)
data=$(read_reg 0x17)
echo  "      P1 Error             Default  Current "
echo  "------------------------------------------- "

signal_status RSVD                   $data 0x80 7 0
signal_status P1_SMERR_L             $data 0x40 6 0
signal_status P1_PROCHOT_L           $data 0x20 5 0
signal_status P1_THERMTRIP_L         $data 0x10 4 0
signal_status RSVD                   $data 0x08 3 0
signal_status RSVD                   $data 0x04 2 0
signal_status P1_DIMM_GL_error       $data 0x02 1 0
signal_status P1_DIMM_AF_error       $data 0x01 0 0
printf "\n"

printf 'Reg 0x18 (I2C Alert)=\t 0x%x \n' $(read_reg 0x18)
data=$(read_reg 0x18)
echo  "      I2C Alert            Default  Current "
echo  "------------------------------------------- "

signal_status RSVD                   $data 0x80 7 0
signal_status P0_I3C_APML_ALERT_L    $data 0x40 6 0
signal_status SCM_I2C_ALERT_L_7      $data 0x20 5 0
signal_status SCM_I2C_ALERT_L_6      $data 0x10 4 0
signal_status SCM_I2C_ALERT_L_5      $data 0x08 3 0
signal_status SCM_I2C_ALERT_L_3      $data 0x04 2 0
signal_status SCM_I2C_ALERT_L_2      $data 0x02 1 0
signal_status SCM_I2C_ALERT_L_1      $data 0x01 0 0
printf "\n"

# for future use
for reg in {25..31}
do
    data=$(read_reg $reg)
    printf ' Reg 0x%x (%d) = 0x%x \n' $reg $reg $data
done

exit 0
