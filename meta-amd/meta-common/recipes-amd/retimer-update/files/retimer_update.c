/*
 * Copyright 2020 Astera Labs, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"). You may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at:
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * or in the "license" file accompanying this file. Thsi file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

/*
 * @file eeprom_test.c
 * @brief Example application to write EEPROM image through Aries.
 * This application does the following:
 *      - Write EEPROM image through Aries Retimer
 *          - If write fails with negative error code, run ARP (Address
 *            Resolution Protocol) and try write again
 *          - If write fails again, return error code
 *          - If write succeeds, continue to next step
 *      - Verify contents of EEPROM with expected image
 */

#include "include/aries_api.h"
#include "examples/include/aspeed.h"
#include "examples/include/eeprom.h"
#include "examples/include/parse_ihx_file.h"
#include "examples/include/misc.h"

#include <unistd.h>

int main(int argc, char* argv[])
{
    // -------------------------------------------------------------------------
    // SETUP
    // -------------------------------------------------------------------------
    // This portion of the example shows how to set up data structures for
    // accessing and configuring Aries retimers
    AriesDeviceType* ariesDevice;
    AriesI2CDriverType* i2cDriver;
    AriesErrorType rc;
    int ariesHandle;
    int i2cBus;
    int ariesSlave;

    // Desired Retimer SMBus (7-bit) address in case ARP needs to be run.
    // Note: Make sure this will not conflict with other device slave addresses.
    uint8_t ariesArpAddr7bit = 0x24;

    // Sanity Check
    if(argc <= 2) 
    {
        printf("Too few arguements.\n");
        return -1;
    }
    i2cBus = atoi(argv[1]);
    ariesSlave = strtol(argv[2], NULL, 16);

    // Set up BMC connection to Aries
    ariesHandle = openI2CConnection(i2cBus, ariesSlave);
    i2cDriver = (AriesI2CDriverType*) malloc(sizeof(AriesI2CDriverType));
    i2cDriver->handle = ariesHandle;
    i2cDriver->slaveAddr = ariesSlave;
    i2cDriver->pecEnable = ARIES_I2C_PEC_DISABLE;
    i2cDriver->i2cFormat = ARIES_I2C_FORMAT_ASTERA;
    // Flag to indicate lock has not been initialized. Call ariesInitDevice()
    // later to initiatlize.
    i2cDriver->lockInit = 0;

    // Set up device parameters
    ariesDevice = (AriesDeviceType*) malloc(sizeof(AriesDeviceType));
    ariesDevice->i2cDriver = i2cDriver;
    ariesDevice->i2cBus = i2cBus;
    ariesDevice->partNumber = ARIES_PTX16;

    // -------------------------------------------------------------------------
    // INITIALIZATION
    // -------------------------------------------------------------------------
    // Check Connection and Init device
    // If the connection is not good, the checkConnectionHealth() API will
    // enable ARP and update the i2cDriver with the new address.
    rc = checkConnectionHealth(ariesDevice, ariesArpAddr7bit);
    if (rc != ARIES_SUCCESS)
    {
        ASTERA_FATAL("Connection check failed");
        return -1;
    }

    // ariesInitDevice() checks for the Main Micro heartbeat before reading the
    // FW version. Incase the heartbeat is not up, it sets the firmware version
    // to 0.0.0. It does not set any other device parameters
    rc = ariesInitDevice(ariesDevice);
    if (rc != ARIES_SUCCESS)
    {
        ASTERA_ERROR("Init device failed");
        return -1;
    }

    // Set I2C Master frequency to 400 Khz
    /*ASTERA_INFO("Updating I2C Master frequency to 400 Khz");*/
    /*rc = ariesI2CMasterSetFrequency(i2cDriver, 370000);*/
    /*CHECK_SUCCESS(rc);*/

    // Load FW file (passed in as an argument to this function)
    // Convert .ihx file to byte array
    // EEPROM size is 2Mbits = 262144 bytes
    int numBytes = 262144;
    uint8_t image[numBytes];
    if (argc >= 4)
    {
        if (0 == strcmp("version",argv[3]))
        {
            // Print SDK version
            ASTERA_INFO("SDK Version: %s", ariesGetSDKVersion());

            // Print FW version
            ASTERA_INFO("FW Version: %d.%d.%d", ariesDevice->fwVersion.major,
                 ariesDevice->fwVersion.minor, ariesDevice->fwVersion.build);
            return 0;
        }
        if (0 == strcmp("get-jn-temp", argv[3]))
        {
            /*Read Temperature*/
            rc = ariesGetJunctionTemp(ariesDevice);
            CHECK_SUCCESS(rc);
            ASTERA_INFO("Temp Seen: %.2f C", ariesDevice->maxTempC);
            return 0;
        }
        // Load ihx file
        // Source code in examples/source/parse_ihx_file.c
        loadIhxFile(argv[3], image);
    }
    else
    {
        ASTERA_ERROR("Missing arg. Must pass FW .ihx file");
        return -1;
    }

    // -------------------------------------------------------------------------
    // PROGRAMMING
    // -------------------------------------------------------------------------
    // legacyMode is the slow programming mode
    // This is set if you have an old FW verison (< 1.0.48), or have ARP
    // enabled, which means you are trying to recover from a corrupted image
    // Optionally, it can be manually enabled by sending a 1 as the 2nd argument
    bool legacyMode = false;
    if (ariesDevice->arpEnable)
    {
        legacyMode = true;
    }
    if (argc >= 5)
    {
        if (argv[4][0] == '1')
        {
            legacyMode = true;
        }
    }

    // Program EEPROM image
    rc = ariesWriteEEPROMImage(ariesDevice, image, numBytes, legacyMode);
    if (rc != ARIES_SUCCESS)
    {
        ASTERA_ERROR("Failed to program the EEPROM. RC = %d", rc);
    }
#if CORRUPT_AND_FLASH // Debug scenario to corrupt manually
    // Corrupt a byte
    // If the user sends in a 1 or 2 as the 3rd argument we will corrupt the
    // image in EEPROM with either a single or multiple byte corruption
    if (argc >= 6)
    {
        if (argv[5][0] == '1')
        {
            uint8_t corruptByte[1];
            corruptByte[0] = 0xC0;
            rc = ariesWriteEEPROMByte(i2cDriver, 37, corruptByte);
            CHECK_SUCCESS(rc);
        }
        else if (argv[3][0] == '2')
        {
            uint8_t corruptByte[1];
            corruptByte[0] = 0xC0;
            rc = ariesWriteEEPROMByte(i2cDriver, 37, corruptByte);
            CHECK_SUCCESS(rc);
            corruptByte[0] = 0xFF;
            rc = ariesWriteEEPROMByte(i2cDriver, 38, corruptByte);
            CHECK_SUCCESS(rc);
            corruptByte[0] = 0xEE;
            rc = ariesWriteEEPROMByte(i2cDriver, 39, corruptByte);
            CHECK_SUCCESS(rc);
            corruptByte[0] = 0xDE;
            rc = ariesWriteEEPROMByte(i2cDriver, 0x20001, corruptByte);
            CHECK_SUCCESS(rc);
            corruptByte[0] = 0xAD;
            rc = ariesWriteEEPROMByte(i2cDriver, 0x20002, corruptByte);
            CHECK_SUCCESS(rc);
        }
    }
#endif
    // Verify EEPROM programming by reading eeprom and computing a checksum
    rc = ariesVerifyEEPROMImageViaChecksum(ariesDevice, image, numBytes);
    if (rc != ARIES_SUCCESS)
    {
        ASTERA_ERROR("Failed to verify the EEPROM using checksum. RC = %d", rc);
    }

    // Verify EEPROM programming by reading eeprom and comparing data with
    // expected image. Incase there is a failure, the API will attempt a
    // rewrite once
    rc = ariesVerifyEEPROMImage(ariesDevice, image, numBytes, legacyMode);
    if (rc != ARIES_SUCCESS)
    {
        ASTERA_ERROR("Failed to read and verify the EEPROM. RC = %d", rc);
    }

    // Reboot device to check if FW version was applied
    // Assert HW reset
    ASTERA_INFO("Performing PCIE HW reset ...");
    rc = ariesSetPcieHwReset(i2cDriver, 1);
    // Wait 10 ms before de-asserting
    usleep(10000);
    // De-assert HW reset
    rc = ariesSetPcieHwReset(i2cDriver, 0);

    // It takes 1.8 sec for retimer to reload firmware. Hence set
    // wait to 5 secs before reading the FW version again
    usleep(5000000);

    rc = ariesInitDevice(ariesDevice);
    if (rc != ARIES_SUCCESS)
    {
        ASTERA_ERROR("Init device failed");
        return -1;
    }

    // Print new FW version
    ASTERA_INFO("Updated FW Version is %d.%d.%d", ariesDevice->fwVersion.major,
        ariesDevice->fwVersion.minor, ariesDevice->fwVersion.build);

    // Close all open connections
    closeI2CConnection(ariesHandle);

    return 0;
}
