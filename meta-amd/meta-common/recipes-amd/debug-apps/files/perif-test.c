/*
 * Copyright 2020 Aspeed Technology Inc.
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

#include "aspeed-espi.h"

struct perif_context {
	int dev_fd;
	char dev_path[256];
	void *map;
	uint32_t map_sz;
};
static struct perif_context perif_ctx[1];

static const char opt_short[] = "hd:s:";

static const struct option opt_long [] = {
	{ "help",		no_argument,		NULL,       'h' },
	{ "dev",		required_argument,	NULL,       'd' },
	{ "size",		required_argument,	NULL,       's' },
	{ 0, 0, 0, 0 }
};

static void print_usage(int argc, char **argv)
{
	printf(
			"Usage: %s [options]\n"
			"eSPI peripheral channel memory cycle test\n\n"
			"Options:\n"
			" -h | --help       Print this message\n"
			" -d | --dev        eSPI peripheral device node\n"
			" -s | --size       memory cycle region size\n"
			"",
			argv[0]);
}

static void print_hexdump(uint8_t *buf, uint32_t len)
{
	int i;

	for (i = 0; i < len; ++i) {
		if (i && (i % 16 == 0))
			printf("\n");
		printf("%02x ", buf[i]);
	}
	printf("\n");
}

int main(int argc, char *argv[])
{
	char opt;
	uint32_t off, len, val;

	while ((opt=getopt_long(argc, argv, opt_short, opt_long, NULL)) != (char)-1) {
		switch(opt) {
		case 'h':
			print_usage(argc, argv);
			return 0;
		case 'd':
			strcpy(perif_ctx->dev_path, optarg);
			break;
		case 's':
			perif_ctx->map_sz = strtoul(optarg, NULL, 0);
			break;
		default:
			print_usage(argc, argv);
			return -1;
		}
	}

	perif_ctx->dev_fd = open(perif_ctx->dev_path, O_RDWR);
	if (perif_ctx->dev_fd == -1) {
		printf("cannot open eSPI perifpheral device\n");
		return -1;
	}

	perif_ctx->map_sz += (getpagesize() - 1);
	perif_ctx->map_sz /= getpagesize();
	perif_ctx->map_sz *= getpagesize();

	perif_ctx->map = mmap(NULL, perif_ctx->map_sz,
			PROT_READ | PROT_WRITE, MAP_SHARED, perif_ctx->dev_fd, 0);
	if (perif_ctx->map == MAP_FAILED) {
		printf("cannot map memory cycle region\n");
		return -1;
	}

	printf("==== Memory Cycle Region Test ====\n"
		"d <addr> <len>     --- dump memory bytes\n"
		"w <addr> <val>     --- write 32-bit value\n"
		"q                  --- exit\n");

	while (1) {
		printf("> ");
		scanf("%c", &opt);

		if (opt == 'q')
			break;

		if (opt == 'd') {
			scanf("%x %x", &off, &len);
			if (off > perif_ctx->map_sz) {
				printf("invalid offset=0x%x", off);
				goto loop_end;
			}
			print_hexdump(perif_ctx->map + off, len);
			goto loop_end;
		}

		if (opt == 'w') {
			scanf("%x %x", &off, &val);
			if (off > perif_ctx->map_sz) {
				printf("invalid offset=0x%x\n", off);
				goto loop_end;
			}
			*((volatile uint32_t *)(perif_ctx->map + off)) = val;
			goto loop_end;
		}

		printf("unknown command=%02x\n", opt);

loop_end:
		// get rid of the stupid '\n'
		scanf("%c", &opt);
	}

	munmap(perif_ctx->map, perif_ctx->map_sz);

	close(perif_ctx->dev_fd);

	return 0;
}
