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
#include <byteswap.h>

#include "aspeed-espi.h"

struct vw_context {
	int dev_fd;
	char dev_path[256];
	uint32_t gpio_val;
	bool is_write;
};
static struct vw_context vw_ctx[1];

static const char opt_short[] = "hd:rw:";

static const struct option opt_long [] = {
	{ "help",		no_argument,		NULL,       'h' },
	{ "dev",		required_argument,	NULL,       'd' },
	{ "read",		no_argument,		NULL,       'r' },
	{ "write",		required_argument,	NULL,       'w' },
	{ 0, 0, 0, 0 }
};

static void print_usage(int argc, char **argv)
{
	printf(
			"Usage: %s [options]\n"
			"eSPI VW channel test\n\n"
			"Options:\n"
			" -h | --help       Print this message\n"
			" -d | --dev        eSPI oob device node\n"
			" -r | --read       read VW GPIO value\n"
			" -w | --write      write VW GPIO value\n"
			"",
			argv[0]);
}

int main(int argc, char *argv[])
{
	int rc;
	char opt;

	while ((opt=getopt_long(argc, argv, opt_short, opt_long, NULL)) != (char)-1) {
		switch(opt) {
		case 'h':
			print_usage(argc, argv);
			return 0;
		case 'd':
			strcpy(vw_ctx->dev_path, optarg);
			break;
		case 'r':
			vw_ctx->is_write = false;
			break;
		case 'w':
			vw_ctx->is_write = true;
			vw_ctx->gpio_val = strtoul(optarg, NULL, 0);
			break;
		default:
			print_usage(argc, argv);
			return -1;
		}
	}

	vw_ctx->dev_fd = open(vw_ctx->dev_path, O_RDWR);
	if (vw_ctx->dev_fd == -1) {
		printf("cannot open eSPI VW device\n");
		return -1;
	}

	if (vw_ctx->is_write)
		rc = ioctl(vw_ctx->dev_fd, ASPEED_ESPI_VW_PUT_GPIO_VAL, &vw_ctx->gpio_val);
	else
		rc = ioctl(vw_ctx->dev_fd, ASPEED_ESPI_VW_GET_GPIO_VAL, &vw_ctx->gpio_val);

	if (rc)
		printf("%s ioctl failed, rc=%d\n",
				(vw_ctx->is_write)? "ASPEED_ESPI_VW_PUT_GPIO_VAL" : "ASPEED_ESPI_VW_GET_GPIO_VAL",
				rc);

	printf("VW GPIO value=0x%08x\n", vw_ctx->gpio_val);

	close(vw_ctx->dev_fd);

	return 0;
}
