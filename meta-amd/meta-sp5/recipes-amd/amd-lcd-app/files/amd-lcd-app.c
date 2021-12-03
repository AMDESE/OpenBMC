#include <ctype.h>
#include <errno.h>
#include <getopt.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


#include <lcdlib_common.h>

#define ARGS_MAX 64
#define BMCIP_FILE    "/var/lib/private/bmc_ip"
#define BMC_FILE      "/etc/os-release"
#define HOST_FILE     "/etc/hostname"
#define BIOS_FILE     "/var/lib/phosphor-bmc-code-mgmt/bios_ver"
#define SCM_FILE      "/var/lib/phosphor-bmc-code-mgmt/scm_ver"
#define HPM_FILE      "/var/lib/phosphor-bmc-code-mgmt/hpm_ver"
#define PC_FILE_PATH  "/var/lib/phosphor-post-code-manager/host0/"
#define PC_INDEX      "/var/lib/phosphor-post-code-manager/host0/CurrentBootCycleIndex"
#define LCD_I2C_BUS   1
#define LCD_MAX_LINE  4
#define LCD_MAX_INDEX 7
#define LCD_MAX_CHAR  20
#define LCD_CHAR      40
#define MAX_CHAR      200

// LCD Line Index
#define POST_CODE_INDEX  0
#define BMC_IP_INDEX     1
#define BMC_VER_INDEX    2
#define HOST_INDEX       3
#define BIOS_VER_INDEX   4
#define HPM_VER_INDEX    5
#define SCM_VER_INDEX    6

// LCD Line Char Cnt
#define POST_CODE_CNT    8
#define BMC_IP_CNT       15
#define BMC_VER_CNT      15
#define HOST_CNT         14
#define BIOS_VER_CNT     14
#define HPM_VER_CNT      9
#define SCM_VER_CNT      9

//#define LCD_DEBUG 1
#ifdef LCD_DEBUG
#define print_debug(fmt, args...) printf(fmt, ## args);
#else
#define print_debug(fmt, args...)
#endif

static void rerun_sudo(int argc, char **argv)
{
    static char *args[ARGS_MAX];
    char sudostr[] = "sudo";
    int i;

    args[0] = sudostr;
    for (i = 0; i < argc; i++) {
        args[i + 1] = argv[i];
    }
    args[i + 1] = NULL;
    execvp("sudo", args);
}

static void system_check(char * tmp)
{
    if (system(tmp) < 0 )
        printf("system call failed for %s\n", tmp);
}

static void get_bmc_param (int i, char * param)
{
    FILE *fp;
    char tmp[MAX_CHAR], val[LCD_CHAR];
    char file[MAX_CHAR];
    int ret;

    switch(i) {
        case BMC_IP_INDEX:
            sprintf(tmp, "ipmitool lan print |grep \"IP Address  \"| cut -c 27-46 >> %s ", BMCIP_FILE);
            system_check(tmp);
            sprintf(file, "%s", BMCIP_FILE);
            fp = fopen(file, "r");
            if(fp == NULL) {
                sprintf(param, "IP: No Data ");
                break;
            }
            ret = fscanf(fp, "%s", tmp);
            if(ret == EOF) {
                sprintf(param, "IP: No Data ");
                break;
            }
            strncpy(val, tmp, BMC_IP_CNT);
            sprintf(param, "IP: %s ", val);
            sprintf(tmp, "rm %s", file);
            system_check(tmp);
            break;
        case BMC_VER_INDEX:
            sprintf(file, "%s", BMC_FILE);
            fp = fopen(file, "r");
            if(fp == NULL) {
                sprintf(param, "BMC: No Data ");
                break;
            }
            ret = fscanf(fp, "%s", tmp);
            if(ret == EOF) {
                sprintf(param, "BMC: No Data ");
                break;
            }
            while(strstr(tmp, "VERSION=") == 0){
                ret = fscanf(fp, "%s", tmp);
                if(ret == EOF) {
                    sprintf(param, "BMC: No Data ");
                    break;
                }
            }
            strncpy(val,&tmp[8], BMC_VER_CNT);
            sprintf(param, "BMC: %s ", val);
            break;
        case HOST_INDEX:
            sprintf(file, "%s", HOST_FILE);
            fp = fopen(file, "r");
            if(fp == NULL) {
                sprintf(param, "HOST: No Data ");
                break;
            }
            ret = fscanf( fp, "%s", tmp);
            if (ret == EOF) {
                sprintf(param, "HOST: No Data ");
                break;
            }
            strncpy(val, tmp, HOST_CNT);
            sprintf(param, "HOST: %s ", val);
            break;
        case BIOS_VER_INDEX:
            sprintf(file, "%s", BIOS_FILE);
            fp = fopen(file, "r");
            if(fp == NULL) {
                sprintf(param, "BIOS: No Data ");
                break;
            }
            ret = fscanf(fp, "%s", tmp);
            if(ret == EOF) {
                sprintf(param, "BIOS: No Data ");
                break;
            }
            while(strstr(tmp, "active") == 0){
                ret = fscanf(fp, "%s", tmp);
                if(ret == EOF) {
                    sprintf(param, "BIOS: No Data ");
                    break;
                }
            }
            ret = fscanf(fp, "%s", tmp);
            if(ret == EOF) {
                sprintf(param, "BIOS: No Data ");
                break;
            }
            strncpy(val,tmp, BIOS_VER_CNT);
            sprintf(param, "BIOS: %13s ", val);
            break;
        case HPM_VER_INDEX:
            sprintf(file, "%s", HPM_FILE);
            fp = fopen(file, "r");
            if(fp == NULL) {
                sprintf(param, "HPM_FPGA: No Data ");
                break;
            }
            ret = fscanf(fp, "%s", tmp);
            if(ret == EOF) {
                sprintf(param, "HPM_FPGA: No Data ");
                break;
            }
            while(strstr(tmp, "active") == 0){
                ret = fscanf(fp, "%s", tmp);
                if(ret == EOF) {
                    sprintf(param, "HPM_FPGA: No Data ");
                    break;
                }
            }
            ret = fscanf(fp, "%s", tmp);
            if(ret == EOF) {
                sprintf(param, "HPM_FPGA: No Data ");
                break;
            }
            strncpy(val,tmp, HPM_VER_CNT);
            sprintf(param, "HPM_FPGA: %9s ", val);
            break;
        case SCM_VER_INDEX:
            sprintf(file, "%s", SCM_FILE);
            fp = fopen(file, "r");
            if(fp == NULL) {
                sprintf(param, "SCM_FPGA: No Data ");
                break;
            }
            ret = fscanf(fp, "%s", tmp);
            if(ret == EOF) {
                sprintf(param, "SCM_FPGA: No Data ");
                break;
            }
            while(strstr(tmp, "active") == 0){
                ret = fscanf(fp, "%s", tmp);
                if(ret == EOF) {
                    sprintf(param, "SCM_FPGA: No Data ");
                    break;
                }
            }
            ret = fscanf(fp, "%s", tmp);
            if(ret == EOF) {
                sprintf(param, "SCM_FPGA: No Data ");
                break;
            }
            strncpy(val,tmp, SCM_VER_CNT);
            sprintf(param, "SCM_FPGA: %9s ", val);
            break;
        default:
            break;
    } // end of switch
    if(fp != NULL)
        fclose(fp);
}

static int write_lcd(LCD_msgType_t msg, char * data)
{
    int size;
    size = strlen(data);
    if(size > LCD_MAX_CHAR)
        size = LCD_MAX_CHAR;
    if ( lcdlib_write_string(msg, data, size) !=0 ) {
        printf("LCD Error : writting Line %d: %s\n", msg, data);
        return (-1);
    }
    print_debug("LCD Line %d: %s \n", msg, data);
    return (0);
}

/**
Main program.
@param argc number of command line parameters
@param argv list of command line parameters
*/
int main(int argc, char **argv)
{
    FILE *fp;
    char line[LCD_MAX_INDEX][LCD_CHAR];
    char tmp1[LCD_MAX_CHAR], tmp2[MAX_CHAR], tmp3[MAX_CHAR];
    int i=0;
    int line_fw_ver_index = BMC_VER_INDEX;
    int size  = 0;
    int pc_index = 1;
    int ret;
    union {
      unsigned int  postcode;
      unsigned char bytes[4];
    } pc;
    LCD_msgType_t msgType;

    if (getuid() !=0) {
        rerun_sudo(argc, argv);
    }
    /* Initialize i2c device */
    if (lcdlib_open_dev(LCD_I2C_BUS) != 0 ) {
       printf("LCD Error: Cannot open LCD I2C Bus %d\n", LCD_I2C_BUS);
    }

    /* Read LCD Config file */
    for (i=1; i < LCD_MAX_INDEX; i++) {
        get_bmc_param(i, line[i]);
    }

    // write to LCD, 1st line is POST Code
    for(i=1; i < LCD_MAX_LINE; i++) {
        msgType = i+1;
        if (write_lcd(msgType, line[i]) != 0)
            return (-1);
    }

    // write the POSt Code
    pc.postcode = 0;
    while(1)
    {
        sleep(2);
        // get BMC IP
        msgType = BMC_IPADDR;
        if (strstr(line[msgType-1], "IP: No Data")!= 0) {
            get_bmc_param(msgType-1, line[msgType-1]);
            if (write_lcd(msgType, line[msgType-1]) != 0)
	        return (-1);
        }
        //alternate Line FW_VER
        if (line_fw_ver_index == BMC_VER_INDEX)
            line_fw_ver_index = BIOS_VER_INDEX;
        else if ((line_fw_ver_index == BIOS_VER_INDEX) ||
                 (line_fw_ver_index == HPM_VER_INDEX))
            line_fw_ver_index++;
        else
            line_fw_ver_index = BMC_VER_INDEX;
        msgType = FW_VER;
        if (write_lcd(msgType, line[line_fw_ver_index]) != 0)
            return (-1);

        // get the POST Code
        fp =  fopen(PC_INDEX, "r");
        if(fp == NULL)
            continue;
        ret = fscanf(fp, "%s", tmp2);
        if(ret == EOF ) {
            fclose(fp);
            continue;
        }
        while(strstr(tmp2, "value0") == 0){
            ret = fscanf(fp, "%s", tmp2);
            if(ret == EOF)
                break;
        }
        ret = fscanf(fp, "%s", tmp1);
        if(ret == EOF ) {
            fclose(fp);
            continue;
        }
        fclose(fp);
        print_debug("PC Index %s\n", tmp1);
        sprintf(tmp2, "%s%s", PC_FILE_PATH, tmp1);
        fp = fopen(tmp2, "r");
        if(fp == NULL)
            continue;
        sprintf(tmp2, "tail %s%s |grep \"tuple_element0\"|cut -c 34-44 >> %s%slast ", PC_FILE_PATH, tmp1, PC_FILE_PATH, tmp1);
        print_debug("cmd line %s\n", tmp2);
        system_check(tmp2);
        sprintf(tmp2, "%s%slast", PC_FILE_PATH, tmp1);
        fp =  fopen(tmp2, "r");
        if(fp == NULL)
            continue;
        ret = fscanf(fp, "%u", &pc.postcode);
        fclose(fp);
        sprintf(tmp3, "rm %s", tmp2);
        system_check(tmp3);
        print_debug("PC = %u %02x %02x %02x %02x \n", pc.postcode, pc.bytes[3], pc.bytes[2], pc.bytes[1], pc.bytes[0]);
        sprintf(line[0], "POSTCODE: %02x%02x%02x%02x ", pc.bytes[3], pc.bytes[2], pc.bytes[1], pc.bytes[0]);
        msgType = POST_CODE;
        if (write_lcd(msgType, line[0]) != 0)
            return (-1);
    }  // end of while(1)

    //Close the device and exit
    if  (lcdlib_close_dev() != 0 ) {
        printf("LCD Error : failed to close LCD device\n");
        return (-1);
    }
    /* Normal program termination */
    return(0);

}
