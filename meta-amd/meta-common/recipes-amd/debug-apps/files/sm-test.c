/*
 * Copyright 2023 AMD
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <getopt.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <byteswap.h>
#include <stdio.h>

#include "aspeed-espi.h"

#define BMC_DEV ("/dev/bmc-device")
#define MEMBAR_BUFFER_LENGTH   1000
#define SM_OFFSET_SIZE         1024
#define PRINT_COL              16
#define PRINT_ROW              50

void  *base_addr = NULL;

static const char opt_short[] = "hd:";

static const struct option opt_long [] = {
	{ "help",		no_argument,		NULL,       'h' },
	{ "read",		required_argument,	NULL,       'r' },
	{ "write",		required_argument,	NULL,       'w' },
	{ 0, 0, 0, 0 }
};

static void print_usage(int argc, char **argv)
{
	printf(
		"Usage: %s [options]\n"
		"BMC_DEV Shared Memory test\n\n"
		"Options:\n"
		" -h | --help            Print this message\n"
		" -r | --read <offset>   read  Shared Memory from (offset * 1024)\n"
		" -w | --write           write Shared Memory Offset\n"
		"",
		argv[0]);
}

void MapSharedMem()
{
	size_t sdev = (MEMBAR_BUFFER_LENGTH * MEMBAR_BUFFER_LENGTH);
	int mfd;

	base_addr = NULL;
	mfd = open(BMC_DEV, O_RDWR | O_SYNC);
	base_addr = mmap(0, sdev, PROT_READ|PROT_WRITE, MAP_SHARED, mfd, 0);
	if (base_addr == NULL)
		printf("BMC_DEV Shared Memory map failed  \n");
	else
		printf("BMC_DEV Shared Memory Base = %p \n", base_addr);

	close(mfd);
	return;
}

void readSharedMem(uint32_t index)
{
	uint32_t offset;
	char     *buf;
	int      i, j;

	offset = SM_OFFSET_SIZE * index;
	printf("Read Shared Memory from Offset = %d \n", offset);

	buf = (char *)(base_addr+offset);
        for (i=0; i < PRINT_ROW; i++)
	{
		for (j=0; j < PRINT_COL; j++)
		{
			if ((buf[i*PRINT_COL+j] < 127) &&
			    (buf[i*PRINT_COL+j] > 20))
				printf("%c[%02x] ", buf[i*PRINT_COL+j], buf[i*PRINT_COL+j]);
			else
				printf(".[%02x] ", buf[i*PRINT_COL+j]);
		}
		printf(" \n");
	}
}

void writeSharedMem(uint32_t index)
{
	uint32_t offset;
	char     *buf;
	int      i, j;

	offset = SM_OFFSET_SIZE * index;
	printf("Write 0x55 in Shared Memory Offset = %d \n", offset);

	buf = (char *)(base_addr+offset);
	for (i=0; i < 1; i++)
	{
		for (j=0; j < PRINT_COL; j++)
		{
			buf[i*PRINT_COL+j] = 0x55;
		}
	}
}

int main(int argc, char *argv[])
{
	bool WR;
	char opt;
	uint32_t offset;

	while ((opt=getopt_long(argc, argv, opt_short, opt_long, NULL)) != (char)-1) {
		switch(opt) {
		case 'h':
			print_usage(argc, argv);
			return 0;
		case 'r':
			offset = strtoul(optarg, NULL, 0);
			if (offset > MEMBAR_BUFFER_LENGTH)
			{
				printf(" Offset (%d) must be less than %d \n", offset, MEMBAR_BUFFER_LENGTH);
				break;
			}
			MapSharedMem();
			if (base_addr != NULL)
				readSharedMem(offset);
			WR = false;
			break;
		case 'w':
			offset = strtoul(optarg, NULL, 0);
			if (offset > MEMBAR_BUFFER_LENGTH)
			{
				printf(" Offset (%d) must be less than %d \n", offset, MEMBAR_BUFFER_LENGTH);
				break;
			}
			MapSharedMem();
			if (base_addr != NULL)
				writeSharedMem(offset);
			WR = true;
			break;
		default:
			print_usage(argc, argv);
			return -1;
		}
	}

	return 0;
}
