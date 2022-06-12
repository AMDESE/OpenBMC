#include "common.h"

extern "C"
{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <linux/i2c.h>
#include <linux/i2c-dev.h>
#include <i2c/smbus.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include "renesas-vr-update.h"
}

static int fd = FAILURE;
static FILE *fp = NULL;
static u_int8_t nvm_slots = 0;

int vr_update_open_dev(void)
{
    char i2c_devname[FILEPATHSIZE];
    snprintf(i2c_devname, FILEPATHSIZE, "/dev/i2c-%d", vr_context.i2c_bus);
    if (fd < SUCCESS) {
        fd = open(i2c_devname, O_RDWR);
        if (fd < SUCCESS) {
            printf("Error: Failed to open i2c device\n");
            return FAILURE;
        }

        if (ioctl(fd, I2C_SLAVE, vr_context.i2c_slave_addr) < SUCCESS) {
            printf("i2c_devname %s vr_context.i2c_slave_addr %x \n",i2c_devname,vr_context.i2c_slave_addr);
            printf("Error: Failed setting i2c dev addr\n");
            return FAILURE;
        }
    } else {
        printf("Error: failed to open VR device");
        return FAILURE;
    }
    usleep(SLEEP_1000);
    return SUCCESS;
}

int vr_update_header_file_open(void)
{

    fp = fopen(vr_context.update_file_path, "r");

    if (fp == NULL) {
        printf("Couldnt open the update file \n");
        return FAILURE;
    }

    return SUCCESS;
}

int vr_update_header_file_close(void)
{
    if (fp != NULL) {
        close(fd);
    }

    fp = NULL;
    return SUCCESS;

}

int renesas_vr_update_close_dev(void)
{
    if (fd >= SUCCESS) {
        close(fd);
    }
    fd = FAILURE;
    return SUCCESS;
}

int disable_packet_capture(void)
{

    u_int8_t rdata[MAXIMUM_SIZE] = { 0 };
    int length;
    int ret = FAILURE;

    //write to DMA Address Register
    ret = i2c_smbus_write_word_data(fd, DMA_WRITE, DISABLE_PACKET);
    if (ret < SUCCESS) {
        printf("%s:write to DMA Address Register failed \n", __func__);
    return FAILURE;
    }

    //read from DMA Address Register
    ret = i2c_smbus_read_i2c_block_data(fd, DMA_READ, BYTE_COUNT_4, rdata);
    if (ret < SUCCESS) {
        printf("%s:Read to DMA Address Register failed with ret value %d\n",__func__,ret);
        return FAILURE;
    }

    rdata[INDEX_0] = rdata[INDEX_0] & 0xDF;

    ret = i2c_smbus_write_i2c_block_data(fd, DMA_READ, BYTE_COUNT_4, rdata);
    if (ret < SUCCESS) {
        printf("%s:Writing block data to the device failed \n", __func__);
    return FAILURE;
    }

    //finish disabling packet capture
    ret = i2c_smbus_write_word_data(fd, FINISH_CMD_CODE, FINISH_CAPTURE);
    if (ret < SUCCESS) {
        printf("%s:write to DMA Address Register failed \n", __func__);
        return FAILURE;
    }

    return SUCCESS;
}

int check_available_nvm_slots(u_int16_t nvm_slot_addr)
{

    u_int8_t rdata[MAXIMUM_SIZE] = { 0 };
    int length;
    int ret = -1;

    //write to DMA Address Register
    ret = i2c_smbus_write_word_data(fd,DMA_WRITE, nvm_slot_addr);
    if (ret < SUCCESS) {
    printf("%s:write to DMA Address Register failed ret = %d\n",__func__, ret);
    return FAILURE;
    }

    //read from DMA Address Register
    ret = i2c_smbus_read_i2c_block_data(fd,DMA_READ, BYTE_COUNT_4, rdata);
    if (ret > SUCCESS) {
        nvm_slots = (rdata[INDEX_3] << SHIFT_24) | (rdata[INDEX_2] << SHIFT_16)
                    | (rdata[INDEX_1] << SHIFT_8) | rdata[INDEX_0];

        printf("Number of available NVM slots = %d \n", nvm_slots);
        if (nvm_slots <= 5) {
            printf("Available NVM slots are less than 5. Hence stopping the update\n");
            return FAILURE;
        }
    } else {
        printf("Read to DMA Address Register failed with ret value %d\n",ret);
        return FAILURE;
    }

    return SUCCESS;
}

int gen2_device_id_validation(void)
{

    u_int8_t rdata[MAXIMUM_SIZE];
    int length, i, num;
    int ret = FAILURE;
    u_int32_t device_id = 0;
    u_int32_t device_rev = 0;
    char *line = NULL;
    size_t len = 0;
    char dev_id[32];

    //Read device_id from the device
    ret = i2c_smbus_read_i2c_block_data(fd, DEV_ID_CMD, BYTE_COUNT_5, rdata);

    if (ret < SUCCESS) {
        printf("Read device_id from the device failed with ret value %d\n",ret);
        return FAILURE;
    }

    printf("Device id from the device = %x\n", rdata[INDEX_2]);

    if (vr_update_header_file_open() != SUCCESS) {
        return FAILURE;
    }

    //Extract device id from HEX file
    if (getline(&line, &len, fp) != -1) {
        length = strlen(line) - 4;
        line[length] = '\0';

        for (i = 8; i < strlen(line); i++) {
            dev_id[i - 8] = line[i];
        }
        dev_id[i - 8] = '\0';

        num = (int) strtol(dev_id, NULL, BASE_16);

        num = (num >> 8) & INT_255;
        printf("Device id from the hex file = %x\n", num);

        //Check if device_id from device and the HEX file matches
        if (rdata[2] != num) {
            printf("Device id not matched.\nUpdate failed\n");
            return FAILURE;
        } else {
            printf("Device id matched\n");
        }
    }
    return SUCCESS;
}

int gen3_device_id_validation(void)
{
    u_int8_t rdata[MAXIMUM_SIZE];
    int length, i;
    u_int32_t num;
    int ret = FAILURE;
    u_int32_t device_id = 0;
    u_int32_t device_rev = 0;
    char *line = NULL;
    size_t len = 0;
    char dev_id[32];

    //Read device_id from the device
    ret = i2c_smbus_read_i2c_block_data(fd, DEV_ID_CMD, BYTE_COUNT_5, rdata);

    if (ret > SUCCESS) {
        device_id = (rdata[INDEX_4] << SHIFT_24) |
                    (rdata[INDEX_3] << SHIFT_16) | (rdata[INDEX_2] << SHIFT_8) | rdata[INDEX_1];
    } else {
        printf("Read device_id from the device failed with ret value %d\n",ret);
        return FAILURE;
    }

    printf("Device id from the device = %x\n", device_id);

    if (vr_update_header_file_open() != SUCCESS) {
        return FAILURE;
    }

    //Extract device id from HEX file
    if (getline(&line, &len, fp) != -1) {
        length = strlen(line) - 4;
        line[length] = '\0';

        for (i = 8; i < strlen(line); i++) {
            dev_id[i - 8] = line[i];
        }

        dev_id[i - 8] = '\0';

        num = (u_int32_t ) strtol(dev_id, NULL, BASE_16);

        printf("Device id from hex file = %x\n", num);
        //Check if device_id from device and the HEX file matches
        if (device_id != num) {
            printf("Device id not matched.\nUpdate failed\n");
            return FAILURE;
        } else {
            printf("Device id matched\n");
        }
    }
    return SUCCESS;
}

int device_revision_verification(void)
{
    u_int8_t rdata[MAXIMUM_SIZE];
    int length, i, num;
    int ret = -1;
    u_int32_t file_rev = 0;
    u_int32_t device_rev = 0;
    char *line = NULL;
    size_t len = 0;
    char dev_id[32];

    //Read IC_DEV_REVISION from the device
    ret = i2c_smbus_read_i2c_block_data(fd, DEV_REV_REV, BYTE_COUNT_5, rdata);

    if (ret > SUCCESS) {
        device_rev = (rdata[INDEX_4] << SHIFT_24) | (rdata[INDEX_3] << SHIFT_16)
                     | (rdata[INDEX_2] << SHIFT_8) | rdata[INDEX_1];
    } else {
        printf("Read device revision from the device failed with ret value %d\n",ret);
        return FAILURE;
    }

    printf("Device revision from the device = %x\n", device_rev);

    if ((strncmp(vr_context.gen, GEN2, strlen(GEN2))) == SUCCESS) {
        if (device_rev < DEVICE_REVISON) {
            printf("Device revision lesser than 2.0.0.3\nUpdate failed\n");
            return FAILURE;
        }
    } else if ((strncmp(vr_context.gen, GEN3, strlen(GEN3))) == SUCCESS) {
        if (device_rev < 3) {
            printf("Device revision lesser than 3\nUpdate failed\n");
            return FAILURE;
        }
    }

    if (getline(&line, &len, fp) != -1) {
        length = strlen(line) - 4;
        line[length] = '\0';

        for (i = 8; i < strlen(line); i++) {
            dev_id[i - 8] = line[i];
        }
        dev_id[i - 8] = '\0';

        num = (int) strtol(dev_id, NULL, BASE_16);

        file_rev = (( num & INT_255 ) | (( num >> SHIFT_8) & INT_255 )
                   | ((num >> SHIFT_16) & INT_255 ) | ((num >> SHIFT_24) & INT_255 ));

        printf("Device version from the HEX File = %x\n",file_rev);

        if ((strncmp(vr_context.gen, GEN2, strlen(GEN2))) == SUCCESS)
        {
            if ((file_rev & INT_255) == ((device_rev >> 24) & 0xFF))
            {
                printf("Device revision from the device and the HEX file matched\n");
            }
            else
            {
                printf("Device revision from the device and the HEX file not matched\n");
                printf("Update Failed\n");
                return FAILURE;
            }
        }
        if ((strncmp(vr_context.gen, GEN3, strlen(GEN3))) == SUCCESS)
        {
            if (((file_rev & INT_255) >= ((device_rev >> 24) & 0xFF)))
            {
                    printf("Device revision from the device and the HEX file matched\n");
            }
            else
            {
                printf("Device revision from the device and the HEX file not matched\n");
                printf("Update Failed\n");
                return FAILURE;
            }
        }
    }
    return SUCCESS;
}

int write_hex_file_to_device(void)
{

    int num, i, length, j, k, m;
    char *line = NULL;
    size_t len = 0;
    u_int8_t byte_data[2] = {0};
    int ret = -1;
    char data_write[MAXIMUM_SIZE];
    char str[8];
    int data[MAXIMUM_SIZE];
    u_int8_t wdata[4] = {0};

    printf("Writing data to the H/W from HEX file !!!!!!!!!!!!\n");
    //Reading each line from HEX file
    while (getline(&line, &len, fp) != EOF) {

        j = 0;
        //Parse the data in each line
        for (i = 0; i < 8; i = i + 2) {
            data_write[0] = *(line + i);
            data_write[1] = *(line + i + 1);
            data_write[2] = '\0';
            num = (int) strtol(data_write, NULL, BASE_16);

            data[j++] = num;
        }
        //0x00 in the header byte indicates that the line should be written to hardware
        if (data[0] != 0)
            continue;

        length = strlen(line);
        //Extract the data to be written to the device
        for (k = 8; k < length - 4; k++) {
            data_write[k - 8] = line[k];
        }
        data_write[k - 8] = '\0';

        //Writing word(2 Bytes) to the device
        if (strlen(data_write) == 4) {
            m = 0;
            j = 0;
            for (k = 0; k <= 1; k++) {
                str[j++] = data_write[m++];
                str[j++] = data_write[m++];
                str[j++] = '\0';
                j = 0;
                num = (int) strtol(str, NULL, BASE_16);
                byte_data[k] = num;
            }

            //ret = i2c_smbus_write_word_data(fd, data[3], byte_data);
            ret = i2c_smbus_write_i2c_block_data(fd, data[3], BYTE_COUNT_2, byte_data);
            if (ret < SUCCESS) {
                printf("Writing word data to the device failed \n");
                return FAILURE;
            }
        }
        //Writing 4 bytes to the device
        else if (strlen(data_write) == 8) {
            m = 0;
            j = 0;
            for (k = 0; k <= 3; k++) {
                str[j++] = data_write[m++];
                str[j++] = data_write[m++];
                str[j++] = '\0';
                j = 0;
                num = (int) strtol(str, NULL, BASE_16);
                wdata[k] = num;
            }
            ret = i2c_smbus_write_i2c_block_data(fd, data[INDEX_3], BYTE_COUNT_4, wdata);
            if (ret < SUCCESS) {
                printf("Writing block data to the device failed \n");
                return FAILURE;
            }
        } else {
            /*TBH */
            printf("Unsupported data format \n");
            return FAILURE;
        }
    }
    printf("Data from Hex File written to the device\n");
    return SUCCESS;
}

int gen2_poll_programmer_status_register(void)
{
    u_int8_t rdata[MAXIMUM_SIZE] = { 0 };
    int length, timeout = 0, ret = 0, status = 0;

    //Poll PROGRAMMER_STATUS Register
    while (timeout < MAX_RETRY) {
        timeout++;
        usleep(SLEEP_1000);

        if (i2c_smbus_write_word_data(fd,DMA_WRITE, GEN2_PRGM_STATUS) != SUCCESS) {
            printf("%s:Write to DMA Address Register failed\n", __func__);
            return FAILURE;
        }

        ret = i2c_smbus_read_i2c_block_data(fd,DMA_READ, BYTE_COUNT_4, rdata);
        if (ret < SUCCESS) {
            printf("%s:Read from DMA Address Register failed\n", __func__);
            return FAILURE;
        }
        if ((rdata[0] & 1) == 1) {
            status = SUCCESS;
            break;
        } else {
            status = SUCCESS;
        }
    }

    //Programming Failure
    if (status == FAILURE) {
        printf("Bit 0 of programmer status register is 0.Programming has failed. Decoding the bits\n");

        if (((rdata[INDEX_0] >> SHIFT_4) & STATUS_BIT_1) == BIT_ENABLE) {
            printf("a CRC mismatch exists within the configuration data\n");
        }
        if (((rdata[INDEX_0] >> SHIFT_6) & STATUS_BIT_1) == BIT_ENABLE) {
            printf("the CRC check fails on the OTP memory\n");
        }
        if ((rdata[INDEX_1] & STATUS_BIT_1) == BIT_ENABLE) {
            printf("the HEX file contains more configurations than are available\n");
        }
    return FAILURE;
    }
    printf("PROGRAMMER_STATUS register polling success\n");

    return SUCCESS;
}

int gen3_poll_programmer_status_register(void)
{

    u_int8_t rdata[MAXIMUM_SIZE] = { 0 };
    int length, timeout = 0, ret = 0, status = 0;

    //Poll PROGRAMMER_STATUS Register
    while (timeout < 10) {
        timeout++;
        usleep(SLEEP_2500);

        if (i2c_smbus_write_word_data(fd,DMA_WRITE, GEN3_PRGM_STATUS) != SUCCESS) {
            printf("%s:Write to DMA Address Register failed\n", __func__);
            return FAILURE;
        }

        ret = i2c_smbus_read_i2c_block_data(fd,DMA_READ, BYTE_COUNT_4, rdata);
        if (ret < SUCCESS) {
            printf("%s:Read from DMA Address Register failed\n", __func__);
            return FAILURE;
        }
        if ((rdata[0] & 1) == 1) {
            status = SUCCESS;
            break;
        } else {
            status = SUCCESS;
        }
    }

    //Programming Failure
    if (status == FAILURE) {
        printf("Bit 0 of programmer status register is 0.Programming has failed. Decoding the bits\n");

        if (((rdata[INDEX_0] >> STATUS_BIT_1) & STATUS_BIT_1) == BIT_ENABLE) {
            printf("Bit 1 is set\nProgramming has failed\n");
        }
        if (((rdata[INDEX_0] >> STATUS_BIT_2) & STATUS_BIT_1) == BIT_ENABLE) {
            printf("The HEX file contains more configurations than are available\n");
        }
        if (((rdata[INDEX_0] >> STATUS_BIT_3) & STATUS_BIT_1) == BIT_ENABLE) {
            printf("CRC mismatch exists within the configuration data\n");
        }
        if (((rdata[INDEX_0] >> STATUS_BIT_4) & STATUS_BIT_1) == BIT_ENABLE) {
            printf("CRC check fails on the OTP memory\n");
        }
        if (((rdata[INDEX_0] >> STATUS_BIT_5) & STATUS_BIT_1) == BIT_ENABLE) {
            printf("Programming has failed! OTP banks consumed\n");
        }
        return FAILURE;
    }
    printf("PROGRAMMER_STATUS register polling success\n");
    return SUCCESS;
}

int bank_status_bits(int status, int bank)
{

    if (status == STATUS_BIT_8) {
        printf("CRC mismatch OTP for bank %d\n", bank);
        return FAILURE;
    } else if (status == STATUS_BIT_4) {
        printf("CRC mismatch RAM for bank %d\n", bank);
        return FAILURE;
    } else if (status == STATUS_BIT_2) {
        printf("Bank %d: Reserverd \n", bank);
        return SUCCESS;
    } else if (status == STATUS_BIT_1) {
        printf("Bank %d: Bank Written (No Failures)\n", bank);
        return SUCCESS;
    } else if (status == STATUS_BIT_0) {
        printf("Bank %d: Unaffected\n", bank);
        return SUCCESS;
    }
    return SUCCESS;
}

int read_bank_status_register(u_int16_t bank_status_reg)
{

    u_int8_t rdata[MAXIMUM_SIZE] = { 0 };
    int length, timeout = 0, ret = 0, status = 0;
    int bank = 0;
    sleep(2);
    //write to DMA Address Register
    if (i2c_smbus_write_word_data(fd,DMA_WRITE, bank_status_reg) != SUCCESS) {
        printf("%s: Write to DMA Address Register failed\n", __func__);
        return FAILURE;
    }
    //Read from DMA Address Register
    ret = i2c_smbus_read_i2c_block_data(fd,DMA_READ, BYTE_COUNT_4, rdata);
    if (ret < SUCCESS) {
        printf("%s: Reading data to the device failed \n", __func__);
        return FAILURE;
    }

    if (bank_status_reg == GEN2_8_15_BANK_REG)
        bank = 8;

    //Bank 0/8 check
    if (bank_status_bits(rdata[INDEX_0] & 0x0F, STATUS_BIT_0 + bank) != SUCCESS)
        return FAILURE;

    //Bank 1/9 check
    if (bank_status_bits(rdata[INDEX_0] >> SHIFT_4, STATUS_BIT_1 + bank) != SUCCESS)
        return FAILURE;

    //Bank 2/10 check
    if (bank_status_bits(rdata[INDEX_1] & 0x0F, STATUS_BIT_2 + bank) != SUCCESS)
        return FAILURE;

    //Bank 3/11 check
    if (bank_status_bits(rdata[INDEX_1] >> SHIFT_4, STATUS_BIT_3 + bank) != SUCCESS)
        return FAILURE;

    //Bank 4/12 check
    if (bank_status_bits(rdata[INDEX_2] & 0x0F, STATUS_BIT_4 + bank) != SUCCESS)
        return FAILURE;

    //Bank 5/13 check
    if (bank_status_bits(rdata[INDEX_2] >> SHIFT_4, STATUS_BIT_5 + bank) != SUCCESS)
        return FAILURE;

    //Bank 6/14 check
    if (bank_status_bits(rdata[INDEX_3] & 0x0F, STATUS_BIT_6 + bank) != SUCCESS)
        return FAILURE;

    //Bank 7/15 check
    if (bank_status_bits(rdata[INDEX_3] >> SHIFT_4, STATUS_BIT_7 + bank) != SUCCESS)
        return FAILURE;

    return SUCCESS;
}

int crc_check_verification(int argc, char* argv[],int crc_value)
{
    u_int8_t rdata[MAXIMUM_SIZE] = { 0 };
    int length;
    int ret = FAILURE;
    u_int32_t device_crc;
    u_int16_t crc_data;

    vr_context.i2c_bus = atoi(argv[ARGV_5]);
    vr_context.i2c_slave_addr = strtoul(argv[ARGV_6], NULL, BASE_16);

    if ((strncmp(argv[ARGV_7], RAA229613, strlen(RAA229613)) == SUCCESS)
        || (strncmp(argv[ARGV_7], RAA229625, strlen(RAA229625)) == SUCCESS)
        || ((strncmp(argv[ARGV_7], RAA229620, strlen(RAA229620)) == SUCCESS)))
    {
        strncpy(vr_context.gen, GEN3, strlen(GEN3));
    }
    else if (strncmp(argv[ARGV_7], ISL68220, strlen(ISL68220)) == SUCCESS)
    {
        strncpy(vr_context.gen, GEN2, strlen(GEN2));
    }
    else {
        printf("Invalid model number %s\n",argv[ARGV_7]);
        return -1;
    }

    if(strncmp(vr_context.gen,GEN2, strlen(GEN2)) == SUCCESS )
    {
        crc_data = GEN2_CRC_ADDR;
    }
    else if(strncmp(vr_context.gen, GEN3, strlen(GEN3)) == SUCCESS )
    {
        crc_data = GEN3_CRC_ADDR;
    }
    else {
        printf("Incorrect Generation provided\n");
        goto clean_vr_update;
    }

    if (vr_update_open_dev() != SUCCESS) {
        goto clean_vr_update;
    }

    //write to DMA Address Register
    ret = i2c_smbus_write_word_data(fd,DMA_WRITE, crc_data );
    if (ret < SUCCESS) {
        printf("%s:write to DMA Address Register failed ret = %d\n",__func__, ret);
        goto clean_vr_update;
    }

    //read from DMA Address Register
    ret = i2c_smbus_read_i2c_block_data(fd,DMA_READ, BYTE_COUNT_4, rdata);
    if (ret > SUCCESS) {
        device_crc = (rdata[INDEX_3] << SHIFT_24) | (rdata[INDEX_2] << SHIFT_16)
                     | (rdata[INDEX_1] << SHIFT_8) | rdata[INDEX_0];
        printf("CRC value is 0x%x\n",device_crc);
    } else {
        printf("Read to DMA Address Register failed with ret value %d\n",ret);
        goto clean_vr_update;
    }

    if(device_crc == crc_value)
        printf("CRC verification passed. VR Programming successful\n");
    else
        printf("CRC verification failed. VR Programming Failure\n");

clean_vr_update:
    vr_update_header_file_close();

    return SUCCESS;
}

int validate_previous_image_crc(u_int16_t crc_data, u_int32_t config_file_crc)
{

    u_int8_t rdata[MAXIMUM_SIZE] = { 0 };
    u_int32_t device_crc;
    int ret = FAILURE;

    //write to DMA Address Register
    ret = i2c_smbus_write_word_data(fd,DMA_WRITE,crc_data );
    if (ret < SUCCESS) {
        printf("%s:write to DMA Address Register failed ret = %d\n",__func__, ret);
        return FAILURE;
    }

    //read from DMA Address Register
    ret = i2c_smbus_read_i2c_block_data(fd,DMA_READ, BYTE_COUNT_4, rdata);
    if (ret > SUCCESS) {
        device_crc = (rdata[INDEX_3] << SHIFT_24) | (rdata[INDEX_2] << SHIFT_16)
                     | (rdata[INDEX_1] << SHIFT_8) | rdata[INDEX_0];
        printf("CRC value is 0x%x\n",device_crc);
    } else {
        printf("Read to DMA Address Register failed with ret value %d\n",ret);
        return FAILURE;
    }
    if(device_crc == config_file_crc)
    {
       printf("CRC matches with previous image. Skipping the update\n");
       return FAILURE;
    }
    else
    {
        printf("CRC didnot match with previous image. Continuing the update\n");

    }

    return SUCCESS;
}

int gen2_programming(void)
{

    u_int16_t nvm_slot_addr = 0;
    u_int16_t bank_status_register = 0;
    int ret = 0;

    if (vr_update_open_dev() != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }

    if(vr_context.crc != 0)
    {
        if(validate_previous_image_crc(GEN2_CRC_ADDR,vr_context.crc) != SUCCESS) {
            ret = FAILURE;
            goto clean_vr_update;
        }
    }

    nvm_slot_addr = GEN2_NVM_SLOT_ADDR;

    if (check_available_nvm_slots(nvm_slot_addr) != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }

    if (gen2_device_id_validation() != SUCCESS) {
       ret = FAILURE;
        goto clean_vr_update;
    }

    if (device_revision_verification() != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }

    if (write_hex_file_to_device() != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }

    if (gen2_poll_programmer_status_register() != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }

    bank_status_register = GEN2_0_7_BANK_REG;
    if (read_bank_status_register(bank_status_register) != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }

    bank_status_register = GEN2_8_15_BANK_REG;
    if (read_bank_status_register(bank_status_register) != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }
    printf("Upgrade complete. Please cycle VCC\n");

clean_vr_update:
    vr_update_header_file_close();
    renesas_vr_update_close_dev();

   return ret;
}

int gen3_programming(void)
{

    u_int16_t nvm_slot_addr = 0;
    u_int16_t bank_status_register = 0;
    int ret = SUCCESS;

    if (vr_update_open_dev() != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }

    if(vr_context.crc != 0)
    {
        if(validate_previous_image_crc(GEN3_CRC_ADDR,vr_context.crc) != SUCCESS) {
            ret = FAILURE;
            goto clean_vr_update;
        }
    }

    if (disable_packet_capture() != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }

    nvm_slot_addr = GEN3_NVM_SLOT_ADDR;
    if (check_available_nvm_slots(nvm_slot_addr) != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }

    if (gen3_device_id_validation() != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }

    if (device_revision_verification() != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }

    if (write_hex_file_to_device() != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }

    if (gen3_poll_programmer_status_register() != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }

    bank_status_register = GEN3_BANK_REG;
    if (read_bank_status_register(bank_status_register) != SUCCESS) {
        ret = FAILURE;
        goto clean_vr_update;
    }
    printf("Upgrade complete. Please cycle VCC\n");

clean_vr_update:

    vr_update_header_file_close();
    renesas_vr_update_close_dev();

    return ret;
}

int renesas_vr_update(int argc, char* argv[])
{
    char *update_file;
    char *generation;
    int ret = SUCCESS;

    if (argc < MAX_CMD_LINE_ARGUMENT )
    {
        printf("Not enough arguments\n");
        return FAILURE;
    }

    vr_context.i2c_bus = atoi(argv[ARGV_3]);
    vr_context.i2c_slave_addr = strtoul(argv[ARGV_4], NULL, BASE_16);
    vr_context.update_file_path = argv[ARGV_5];

    vr_context.crc = 0;
    if(argv[ARGV_7] != NULL)
        vr_context.crc = strtoul(argv[ARGV_7], NULL, 16);

    if ((strncmp(argv[ARGV_6], RAA229613, strlen(RAA229613)) == SUCCESS) ||
        (strncmp(argv[ARGV_6], RAA229625, strlen(RAA229625)) == SUCCESS)
        || ((strncmp(argv[ARGV_6], RAA229620, strlen(RAA229620)) == SUCCESS)))
    {
        strncpy(vr_context.gen, GEN3, strlen(GEN3));
    }
    else if (strncmp(argv[ARGV_6], ISL68220, strlen(ISL68220)) == SUCCESS)
    {
        strncpy(vr_context.gen, GEN2, strlen(GEN2));
    }
    else {
        printf("Invalid model number\n");
        return FAILURE;
    }

    if ((strncmp(vr_context.gen, GEN2, strlen(GEN2))) == SUCCESS)
    {
        printf("Initiating VR update for Gen2\n");
        ret = gen2_programming();

    } else if ((strncmp(vr_context.gen, GEN3, strlen(GEN3))) == SUCCESS)
    {
        printf("Initiating VR update for Gen3\n");
        ret = gen3_programming();

    } else {
        printf("Invalid generation option \n");
        ret = FAILURE;
    }
    return ret;

}
