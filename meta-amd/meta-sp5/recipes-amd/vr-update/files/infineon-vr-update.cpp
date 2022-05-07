#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <cerrno>
#include <cstdlib>
#include <cstring>
#include <sys/ioctl.h>
#include "infineon-vr-update.h"
#include "common.h"

extern "C"
{
#include <linux/i2c.h>
#include <i2c/smbus.h>
#include <linux/i2c-dev.h>
}

static int fd = FAILURE;    // File Descriptor
static int verbose = FAILURE;    // Verbose Flag
static int rc;    // Return Code Flag

int find_next_usr_img_ptr(int *);

int vr_update_open_dev(int i2c_bus, uint8_t i2c_addr)
{
    char i2c_devname[FILEPATHSIZE];
    std::snprintf(i2c_devname, FILEPATHSIZE, "/dev/i2c-%d", i2c_bus);
    if (fd < 0) {
        fd = open(i2c_devname, O_RDWR);
        if (fd < 0) {
            std::cout << "Error: Failed to open i2c device" << std::endl;
            return FAILURE;
        }

        if (ioctl(fd, I2C_SLAVE, i2c_addr) < 0) {
            std::cout << "Error: Failed setting i2c dev addr" << std::endl;
            return FAILURE;
        }
    } else {
        std::cout << "Error: failed to open VR device" << std::endl;
        return FAILURE;
    }
    usleep(MINWAITTIME);
    return SUCCESS;
}

int vr_update_close_dev(void)
{
    if (fd >= 0) {
        close(fd);
    }
    fd = FAILURE;
    return SUCCESS;
}

std::string getDeviceType()
{
    uint8_t wdata[MAXBUFFERSIZE];
    uint8_t rdata[MAXBUFFERSIZE];
    int length;
    std::string device_type;
    wdata[0] = DDBD0;
    wdata[1] = DDBD1;
    wdata[2] = DDBD2;
    wdata[3] = DDBD3;
    rc = i2c_smbus_write_block_data(fd, RPTR, (uint8_t)LENGTHOFBLOCK, wdata);
    if (rc != SUCCESS) {
        std::cout << "Error: Failed to write data" << std::endl;
        perror("Error");
        return "None";
    }
    length = i2c_smbus_read_block_data(fd, MFR_REG_READ, rdata);
    if (length > 0) {
        if (rdata[1] == PART1 || rdata[1] == PART2 || rdata[1] == PART3 || rdata[1] == PART4 || rdata[1] == PART5){
            std::cout << "Infineon device detected" << std::endl;
            device_type = "Infineon";
        } else {
            std::cout << "Error: No device detected" << std::endl;
            device_type = "None";
        }
    } else {
        std::cout << "Error: Read failed" << std::endl;
        perror("Error");
    }
    return device_type;
}

int checkifSpaceAvailableOnOtp()
{
    uint8_t wdata[MAXBUFFERSIZE];
    uint8_t rdata[MAXBUFFERSIZE];
    int length;
    int size;
    memset(wdata, 0x0, MAXBUFFERSIZE);
    rc = i2c_smbus_write_block_data(fd, BLOCK_PREFIX, (uint8_t)LENGTHOFBLOCK, wdata);
    if (rc != SUCCESS) {
        std::cout << "Error: Failed to write data" << std::endl;
        perror("Error");
        return FAILURE;
    }
    rc = i2c_smbus_write_byte_data(fd, BYTE_PREFIX, AVAIL_SPACE_BYTE);
    if (rc != SUCCESS) {
        std::cout << "Error: Failed to write data" << std::endl;
        perror("Error");
        return FAILURE;
    }
    length = i2c_smbus_read_block_data(fd, BLOCK_PREFIX, rdata);
    if (length > 0)
    {
        size = (256 * rdata[1] + rdata[0]);    // size = d0 + 256 * d1. Formula provided in Infineon document
        std::cout << "Available size (bytes):" << size << std::endl;
    }
    else
    {
        std::cout << "Error: Failed to read data" << std::endl;
        perror("Error");
        return FAILURE;
    }
    if (size < MINOTPSIZE)
    {
        std::cout << "Available space is less, program manually" << std::endl;
        return FAILURE;
    }
    else
    {
        std::cout << "Proceeding with programming" << std::endl;
        return SUCCESS;
    }
}

std::string getUpdateType(const char *filename)
{
    return "cfg";
}

std::string get_file_contents(const char *filename)
{
  std::ifstream in(filename, std::ifstream::in);
  if (in)
  {
    std::ostringstream contents;
    contents << in.rdbuf();
    in.close();
    return(contents.str());
  }
  throw(errno);
}

std::vector<std::vector<std::string>> get_each_section_data(std::string data)
{
    std::vector<std::string> blobs;
    std::string start_pat = "[Configuration Data]";
    std::string end_pat = "[End Configuration Data]";
    size_t start_delim = data.find(start_pat);
    size_t end_delim = data.find(end_pat);
    data = data.substr(start_delim + start_pat.length(), end_delim - start_delim - start_pat.length());
    unsigned first = data.find("//XV");
    while(first <= data.length())
    {
        unsigned second = data.find("//XV", first + 2);    // Adjust position of index to get required data
        std:: string blob = data.substr(first + 2, second - first - 2);
        std::stringstream ss(blob);
        std::string line;
        std::string n_blob = "";
        while(getline(ss, line))
        {
            if(size_t foundxv = line.find("XV") != std::string::npos)
            {
                blob.erase(foundxv - 1, line.length());
            }
            else
            {
                std::string row_num = line.substr(0,4);    // Row number always contains 3 digits hence (0,4)
                if(size_t foundrn = line.find(row_num) != std::string::npos)
                {
                    line.erase(foundrn - 1, row_num.length());
                    n_blob.append(line + " ");
                }
            }
        }
        blobs.push_back(n_blob);
        first = second;
    }
    std::vector<std::vector<std::string>> matrix;
    for (int i = 0; i < blobs.size(); i++)
    {
        std::vector<std::string> row;
        std::stringstream sd(blobs[i]);
        std::string dword;
        while (getline(sd, dword, ' '))
        {
            row.push_back(dword);
        }
        matrix.push_back(row);
    }
    return matrix;
}

std::vector<uint8_t> formatDword(std::string s_dword)
{
    unsigned long ul;
    std::vector<uint8_t> v_dword;
    uint8_t dword[4] = {0};
    ul = std::strtoul(s_dword.c_str(), NULL, BASE_16);
    memcpy(dword,&ul,4);
    for(int i=0; i<4; i++)
    {
        v_dword.push_back(dword[i]);
    }
    return v_dword;
}

std::vector<std::vector<std::string>> parseCfgFile(const char *filename)
{
    std::string content = get_file_contents(filename);
    std::vector<std::vector<std::string>> sections = get_each_section_data(content);
    return sections;
}

int invalidateOtp(uint8_t xv, uint8_t hc)
{
    uint8_t wdata[MAXBUFFERSIZE];
    wdata[0] = hc;
    wdata[1] = xv;
    wdata[2] = 0x00;
    wdata[3] = 0x00;
    if(verbose > 0)
    {
        std::cout << "Invalidate OTP Block Write with cmd 0xfd" << std::endl;
        std::cout << std::hex << unsigned(wdata[3]) << unsigned(wdata[2]) << unsigned(wdata[1]) << unsigned(wdata[0]) << std::endl;
    }
    rc = i2c_smbus_write_block_data(fd, BLOCK_PREFIX, (uint8_t)LENGTHOFBLOCK, wdata);
    usleep(MINWAITTIME);
    if(rc != SUCCESS)
    {
        perror("Error while writing block data to invalidate OTP");
        return FAILURE;
    }
    if(verbose > 0)
    {
        std::cout << "Invalidate OTP Byte Write with cmd 0xfe" << std::endl;
        std::cout << std::hex << unsigned(INVAL_BYTE) << std::endl;
    }
    rc = i2c_smbus_write_byte_data(fd, BYTE_PREFIX, INVAL_BYTE);
    usleep(MINWAITTIME);
    if( rc != SUCCESS)
    {
        perror("Error while writing byte data to invalidate OTP");
        return FAILURE;
    }
    return SUCCESS;
}

int writeDataToScratchpad(std::vector<std::string> section)
{
    uint8_t wdata[MAXBUFFERSIZE];
    wdata[0] = SPBD0;
    wdata[1] = SPBD1;
    wdata[2] = SPBD2;
    wdata[3] = SPBD3;
    if(verbose > 0)
    {
        std::cout << "ScratchPad Initial Block Write with cmd 0xce" << std::endl;
        std::cout << std::hex << unsigned(wdata[3]) << unsigned(wdata[2]) << unsigned(wdata[1]) << unsigned(wdata[0]) << std::endl;
    }
    rc = i2c_smbus_write_block_data(fd, RPTR, (uint8_t)LENGTHOFBLOCK, wdata);
    usleep(MINWAITTIME);
    if(rc != SUCCESS)
    {
        perror("Error while writing initial block data request to scratchpad");
        return FAILURE;
    }
    if(verbose > 0)
    {
        std::cout << "Write Block Data to Scratchpad with cmd 0xde" << std::endl;
    }
    for(int i=0; i < section.size(); i++)
    {
        uint8_t sdata[MAXBUFFERSIZE];
        std::vector<uint8_t> dword = formatDword(section[i]);
        sdata[0] = dword[0];
        sdata[1] = dword[1];
        sdata[2] = dword[2];
        sdata[3] = dword[3];
        if(verbose > 0)
        {
            std::cout << std::hex << unsigned(sdata[0]) << unsigned(sdata[1]) << unsigned(sdata[2]) << unsigned(sdata[3]) << std::endl;
        }
        rc = i2c_smbus_write_block_data(fd, MFR_REG_WRITE, (uint8_t)LENGTHOFBLOCK, sdata);
        usleep(MINWAITTIME);
        if(rc !=SUCCESS)
        {
            perror("Error while writing block data request to scratchpad");
            return FAILURE;
        }
    }
    return SUCCESS;
}

int uploadDataToOtp(std::string s_dword)
{
    uint8_t wdata[MAXBUFFERSIZE];
    std::vector<uint8_t> dword = formatDword(s_dword);
    wdata[0] = dword[0];
    wdata[1] = dword[1];
    wdata[2] = 0x00;
    wdata[3] = 0x00;
    if(verbose > 0)
    {
        std::cout << "Upload Block Data to OTP with cmd 0xfd" << std::endl;
        std::cout << std::hex << unsigned(wdata[3]) << unsigned(wdata[2]) << unsigned(wdata[1]) << unsigned(wdata[0]) << std::endl;
    }
    rc = i2c_smbus_write_block_data(fd, BLOCK_PREFIX, (uint8_t)LENGTHOFBLOCK, wdata);
    usleep(MINWAITTIME);
    if ( rc != SUCCESS)
    {
        perror("Error while uploading block data from scratchpad to OTP");
        return FAILURE;
    }
    if (verbose > 0)
    {
        std::cout << "Upload Byte data to OTP with cmd 0xfe" << std::endl;
        std::cout << std::hex << unsigned(UPLOAD_BYTE) << std::endl;
    }
    rc = i2c_smbus_write_byte_data(fd, BYTE_PREFIX, UPLOAD_BYTE);
    usleep(MAXWAITTIME);
    if ( rc != SUCCESS)
    {
        perror("Error while executing byte write command for uploading data from scratchpad to OTP");
        return FAILURE;
    }
    return SUCCESS;
}

int doCfgUpdate(const char *filename)
{
    int exit_status = SUCCESS;
    std::vector<std::vector<std::string>> sections = parseCfgFile(filename);
    std::string trim_header = "00000002";    // Trim header programming needs to be ignored according to Infineon FAE
    for(int i=0; i < sections.size(); i++)
    {
        if(sections[i][0] == trim_header)
        {
            continue;
        }
        std::vector<uint8_t> xvhc = formatDword(sections[i][0]);
        exit_status=invalidateOtp(xvhc[1], xvhc[0]);
        if(exit_status != SUCCESS) {
            std::cout << "Invalidate OTP Data has failed. Skipping other steps." << std::endl;
            return FAILURE;
        }
        exit_status=writeDataToScratchpad(sections[i]);
        if(exit_status != SUCCESS) {
            std::cout << "Writing Data to Scratchpad has failed. Skipping other steps." << std::endl;
            return FAILURE;
        }
        exit_status=uploadDataToOtp(sections[i][1]);
    }
    return(exit_status);
}

int doPatchUpdate(const char *filename)
{
    int exit_status = SUCCESS;
    return (exit_status);
}

int xdpe_vr_update(int argc, char *argv[])
{
    int exit_status = SUCCESS;
    std::fstream file;
    int i2c_bus = atoi(argv[ARGV_3]);
    uint8_t i2c_addr = std::strtoul(argv[ARGV_4], NULL, BASE_16);
    const char *file_name = argv[ARGV_5];
    std::string mode(argv[ARGV_6]);

    if(mode == "verbose")
    {
        verbose = 1;
        std::cout << "Running in Verbose mode. Output will be redirected to screen" << std::endl;
        std::streambuf* stream_buffer_cout = std::cout.rdbuf();
        std::cout.rdbuf(stream_buffer_cout);
    }
    else if(mode == "debug")
    {
        verbose = 1;
        std::cout << "Running in Debug mode. Output will be redirected to file" << std::endl;
        char log_name[FILEPATHSIZE];
        std::snprintf(log_name, FILEPATHSIZE, "/tmp/%d_%xh_vr-update.log", i2c_bus, i2c_addr);
        file.open(log_name, std::ios::out);
        std::streambuf* stream_buffer_file = file.rdbuf();
        std::cout.rdbuf(stream_buffer_file);
    }
    exit_status = vr_update_open_dev(i2c_bus, i2c_addr);
    if (exit_status != SUCCESS)
    {
        std::cout << "Error: Failed to open file descriptor" << std::endl;
        return FAILURE;
    }
    std::string device_type = getDeviceType();
    exit_status = checkifSpaceAvailableOnOtp();
    if(exit_status != SUCCESS)
    {
        return (exit_status);
    }
    std::cout << "The detected device type is " << device_type << std::endl;
    std::string update_type = getUpdateType(file_name);
    if (update_type == "cfg")
    {
       exit_status = doCfgUpdate(file_name);
    } else if (update_type == "patch")
    {
        exit_status = doPatchUpdate(file_name);
    }
    if(mode == "debug")
    {
        file.close();
    }
    vr_update_close_dev();
    return (exit_status);
}

bool write_user_section_data(const char *filename)
{

   std::fstream newfile;
   newfile.open(filename,std::ios::in);

   if (newfile.is_open())
   {
      std::string tp;
      int data_section = 0;
      int current_page_num = -1;
      while(getline(newfile, tp))
      {
            /*Starting of user section */
            if (tp.find("[Config Data]") != std::string::npos) {
                data_section = 1;
                continue;
            }

            /*Starting of user section */
            if (tp.find("[Configuration Data]") != std::string::npos) {
                data_section = 1;
                continue;
            }

            /*Ending of user section */
            if (tp.find("[End Config Data]") != std::string::npos) {
                data_section = 1;
                break;
            }

            /*Ending of user section */
            if (tp.find("[End Configuration Data]") != std::string::npos) {
                data_section = 1;
                break;
            }

            if(data_section == 1)
            {
                int index = 0;
                int page_number = 0;
                std::string page_num;
                std::string word;
                std::string starting_index;
                std::string userdata;
                int index_num = 0;
                int user_data  = 0;
                int index_range = 0;

                std::stringstream iss(tp);
                while (iss >> word)
                {
                    /*First word which containes page num and index*/
                    if(index == 0 )
                    {
                            index_range = std::stoi(word, nullptr, BASE_16);
                            if(index_range < INDEX_40)
                                break;
                            else if(index_range > INDEX_70 && index_range < INDEX_200)
                                break;
                            else if(index_range > INDEX_2FF)
                                break;

                            std::cout << word << std::endl;
                            page_num = "";
                            page_num.push_back(word[0]);
                            page_num.push_back(word[1]);
                            page_number = std::stoi(page_num, nullptr, BASE_16);

                            if(current_page_num != page_number)
                            {
                                current_page_num = page_number;
                                std::cout << "Writing " << page_number << " to page number register" << std::endl;
                                rc = i2c_smbus_write_byte_data(fd, PAGE_NUM_REG, page_number);
                                if (rc != 0) {
                                    std::cout << "Error: Failed to write data" << std::endl;
                                    perror("Error");
                                    return FAILURE;
                                }
                            }
                            starting_index="";
                            starting_index.push_back(word[2]);
                            starting_index.push_back(word[3]);
                            index_num = std::stoi(starting_index, nullptr, BASE_16);
                            index++;
                            continue;
                    }

                    userdata = "";
                    userdata.push_back(word[0]);
                    userdata.push_back(word[1]);
                    user_data = std::stoi(userdata, nullptr, BASE_16);
                    std::cout << "Index number = " << std::hex << index_num << " user_data = " << std::hex << user_data << std::endl;
                    rc = i2c_smbus_write_byte_data(fd, index_num, user_data);
                    if (rc != 0) {
                        std::cout << "Error: Failed to write data" << std::endl;
                        perror("Error");
                        return FAILURE;
                    }
                    index_num++;
                }
            }
      }
      newfile.close();
   }
   return true;
}

int user_section_programming(const char *filename)
{

    uint16_t rdata = 0;
    int exit_status = SUCCESS;
    int next_img_ptr;

    /* Change to page 0 by writing 0 to register 0xFF */
    rc = i2c_smbus_write_byte_data(fd, PAGE_NUM_REG, 0);
    if (rc != 0) {
        std::cout << "Error: Failed to write data" << std::endl;
        perror("Error");
        return FAILURE;
    }

    /* Read register 0x0B4 [15:0] + 0x0B6 [15:0] + 0x0B8 [15:0]
       to determine next USER image pointer*/

    if(find_next_usr_img_ptr(&next_img_ptr) != 0)
        return FAILURE;

    std::cout << "Next image pointer = " << next_img_ptr << std::endl;
    if(next_img_ptr > 40 )
    {
        std::cout << "OTP for user section is not available\n";
        return FAILURE;
    }
    /* Write data 0x03 to register 0xD4 to
       unlock i2 and PMBus address registers*/
   rc = i2c_smbus_write_byte_data(fd, UNLOCK_REG, 0x03);
    if (rc != 0) {
        std::cout << "Error: Failed to write data" << std::endl;
        perror("Error");
        return FAILURE;
    }

    /*Write configuration data following
      the order listed in the .xsf file*/
    write_user_section_data(filename);

    uint16_t user_prog_cmd = 0x42;

    /*Write programming command 0xPP42 to register 0x00D6*/
    user_prog_cmd = ( next_img_ptr << 8) | user_prog_cmd;

    rc = i2c_smbus_write_word_data(fd, USER_PROG_CMD , user_prog_cmd);
    if (rc < 0) {
        std::cout << "Error: Failed to write data" << std::endl;
        perror("Error");
        return FAILURE;
    }

    /*Wait for 200ms */
    usleep(200 * 1000);

    /*Check register 0xD7 [7] for programming progress.
      0 = fail. 1 = done*/

    uint8_t read_data = 0;

    read_data = i2c_smbus_read_byte_data(fd,PROG_STATUS_REG);
    if (read_data < 0)
    {
        std::cout << "Error: Failed to read data" << std::endl;
        perror("Error");
        return FAILURE;
    }

    if(read_data & 0x80)
        std::cout << "User section programming success" << std::endl;
    else {
        std::cout << "User section programming failed" << std::endl;
        perror("Error");
        return FAILURE;
    }

    return exit_status;
}

int find_next_usr_img_ptr(int *next_img_ptr)
{

    uint64_t user_img_ptr = 0;
    uint64_t mask = 1;
    uint16_t rdata = 0;
    int exit_status = SUCCESS;
    int i;

    rdata = i2c_smbus_read_word_data(fd,USER_IMG_PTR3);
    if (rdata < 0)
    {
        std::cout << "Error: Failed to read data" << std::endl;
        perror("Error");
        return FAILURE;
    }

    user_img_ptr = user_img_ptr | rdata;
    rdata = i2c_smbus_read_word_data(fd,USER_IMG_PTR2);
    if (rdata < 0)
    {
        std::cout << "Error: Failed to read data" << std::endl;
        perror("Error");
        return FAILURE;
    }
    user_img_ptr = user_img_ptr | ((uint64_t )rdata << BASE_16) ;
    rdata = i2c_smbus_read_word_data(fd,USER_IMG_PTR1);
    if (rdata < 0)
    {
        std::cout << "Error: Failed to read data" << std::endl;
        perror("Error");
        return FAILURE;
    }
    user_img_ptr = user_img_ptr | ((uint64_t )rdata << 32) ;

    for(i = 0 ; i < 48 ; i++)
    {
        if( (user_img_ptr & ( mask << i)) == 0)
        {
            break;
        }
    }
    *next_img_ptr = i;
    return exit_status;
}

int tda_vr_update(int argc, char *argv[])
{

    std::cout << "TDA VR update\n";

    int exit_status = 0;
    std::fstream file;
    int i2c_bus = atoi(argv[ARGV_3]);
    uint8_t i2c_addr = std::strtoul(argv[ARGV_4], NULL, BASE_16);
    const char *file_name = argv[ARGV_5];
    int num_of_image = 0;

    exit_status = vr_update_open_dev(i2c_bus, i2c_addr);
    if (exit_status != SUCCESS)
    {
        std::cout << "Error: Failed to open file descriptor" << std::endl;
        return FAILURE;
    }

    /*User section programming */
    exit_status = user_section_programming(file_name);

    vr_update_close_dev();
    return (exit_status);

}

int infineon_vr_update(int argc, char *argv[])
{
    const char *file_name = argv[ARGV_5];
    const char *file_extension = NULL;
    int exit_status = SUCCESS;

    file_extension = strrchr(file_name, '.');

    if(strncmp(file_extension,".xsf",LENGTHOFBLOCK) == 0)
        exit_status = tda_vr_update(argc,argv);
    else
        exit_status = xdpe_vr_update(argc,argv);

    return exit_status;
}
