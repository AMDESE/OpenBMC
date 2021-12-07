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

extern "C"
{
#include <linux/i2c.h>
#include <i2c/smbus.h>
#include <linux/i2c-dev.h>
}

static int fd = -1;    // File Descriptor
static int verbose = -1;    // Verbose Flag
static int rc;    // Return Code Flag

int vr_update_open_dev(int i2c_bus, uint8_t i2c_addr)
{
    char i2c_devname[FILEPATHSIZE];
    std::snprintf(i2c_devname, FILEPATHSIZE, "/dev/i2c-%d", i2c_bus);
    if (fd < 0) {
        fd = open(i2c_devname, O_RDWR);
        if (fd < 0) {
            std::cout << "Error: Failed to open i2c device" << std::endl;
            return (-1);
        }

        if (ioctl(fd, I2C_SLAVE, i2c_addr) < 0) {
            std::cout << "Error: Failed setting i2c dev addr" << std::endl;
            return (-1);
        }
    } else {
        std::cout << "Error: failed to open VR device" << std::endl;
        return (-1);
    }
    usleep(MINWAITTIME);
    return (0);
}

int vr_update_close_dev(void)
{
    if (fd >= 0) {
        close(fd);
    }
    fd = -1;
    return (0);
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
    if (rc != 0) {
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
    if (rc != 0) {
        std::cout << "Error: Failed to write data" << std::endl;
        perror("Error");
        return (1);
    }
    rc = i2c_smbus_write_byte_data(fd, BYTE_PREFIX, AVAIL_SPACE_BYTE);
    if (rc != 0) {
        std::cout << "Error: Failed to write data" << std::endl;
        perror("Error");
        return (1);
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
        return (1);
    }
    if (size < MINOTPSIZE)
    {
        std::cout << "Available space is less, program manually" << std::endl;
        return (1);
    }
    else
    {
        std::cout << "Proceeding with programming" << std::endl;
        return (0);
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
    ul = std::strtoul(s_dword.c_str(), NULL, 16);
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
    if(rc !=0)
    {
        perror("Error while writing block data to invalidate OTP");
        return (1);
    }
    if(verbose > 0)
    {
        std::cout << "Invalidate OTP Byte Write with cmd 0xfe" << std::endl;
        std::cout << std::hex << unsigned(INVAL_BYTE) << std::endl;
    }
    rc = i2c_smbus_write_byte_data(fd, BYTE_PREFIX, INVAL_BYTE);
    usleep(MINWAITTIME);
    if( rc != 0)
    {
        perror("Error while writing byte data to invalidate OTP");
        return (1);
    }
    return (0);
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
    if(rc != 0)
    {
        perror("Error while writing initial block data request to scratchpad");
        return (1);
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
        if(rc !=0)
        {
            perror("Error while writing block data request to scratchpad");
            return (1);
        }
    }
    return (0);
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
    if ( rc != 0)
    {
        perror("Error while uploading block data from scratchpad to OTP");
        return (1);
    }
    if (verbose > 0)
    {
        std::cout << "Upload Byte data to OTP with cmd 0xfe" << std::endl;
        std::cout << std::hex << unsigned(UPLOAD_BYTE) << std::endl;
    }
    rc = i2c_smbus_write_byte_data(fd, BYTE_PREFIX, UPLOAD_BYTE);
    usleep(MAXWAITTIME);
    if ( rc != 0)
    {
        perror("Error while executing byte write command for uploading data from scratchpad to OTP");
        return (1);
    }
    return (0);
}

int doCfgUpdate(const char *filename)
{
    int exit_status = 0;
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
        if(exit_status != 0) {
            std::cout << "Invalidate OTP Data has failed. Skipping other steps." << std::endl;
            return (1);
        }
        exit_status=writeDataToScratchpad(sections[i]);
        if(exit_status != 0) {
            std::cout << "Writing Data to Scratchpad has failed. Skipping other steps." << std::endl;
            return (1);
        }
        exit_status=uploadDataToOtp(sections[i][1]);
    }
    return(exit_status);
}

int doPatchUpdate(const char *filename)
{
    int exit_status = 0;
    return (exit_status);
}

int main(int argc, char* argv[])
{
    if(argc < MINARGS)
    {
        std::cout << "usage: vr-update [I2C_BUS] [I2C_ADDR] [FILE_NAME] [MODE: (CHOICES : [verbose, debug] default: none)]" << std::endl;
        return (1);
    }
    int exit_status = 0;
    std::fstream file;
    int i2c_bus = atoi(argv[1]);
    uint8_t i2c_addr = std::strtoul(argv[2], NULL, 16);
    const char *file_name = argv[3];
    std::string mode(argv[4]);
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
    if (exit_status != 0)
    {
        std::cout << "Error: Failed to open file descriptor" << std::endl;
        return (1);
    }
    std::string device_type = getDeviceType();
    exit_status = checkifSpaceAvailableOnOtp();
    if(exit_status != 0)
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