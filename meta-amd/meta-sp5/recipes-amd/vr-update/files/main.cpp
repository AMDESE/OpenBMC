#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <iostream>
#include <string.h>
#include "renesas-vr-update.h"
#include "infineon-vr-update.h"
#include "common.h"

int main(int argc, char **argv)
{
    char *board = NULL;
    int crc_value;
    int index;
    int c, crc = 0;
    int ret = 0;

    opterr = 0;

    while ((c = getopt(argc, argv, "b:c:")) != -1)
    switch (c) {
    case 'c':
        crc = 1;
        crc_value = strtoul(optarg, NULL, 16);
        break;
    case 'b':
        board = optarg;
        break;
    case '?':
        printf("unknown option: %c\n", optopt);
        return FAILURE;
    default:
        abort();
        return FAILURE;
    }

    if (crc == 1) {
        std::cout << "Read CRC verification value " << std::endl;
        crc_check_verification(argc, argv, crc_value);
        return 0;
    }
    if (strncmp(board, RENESAS_VR , strlen(RENESAS_VR)) == 0) {

        ret = renesas_vr_update(argc, argv);

    } else if (strncmp(board, INFINEON_VR, strlen(INFINEON_VR)) == 0) {

        ret = infineon_vr_update(argc, argv);

    } else {
        std::cout << "Invalid manufacturer name provided " << board << std::endl;
        ret = FAILURE;
    }

    return ret;
}
