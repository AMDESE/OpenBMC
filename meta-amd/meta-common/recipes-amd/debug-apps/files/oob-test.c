/*
 * Copyright 2020 Aspeed Technology Inc.
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <getopt.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <byteswap.h>

#include "aspeed-espi.h"

struct oob_context {
	int dev_fd;
	char dev_path[256];
};
static struct oob_context oob_ctx[1];

static const char opt_short[] = "hd:";

static const struct option opt_long [] = {
	{ "help",		no_argument,		NULL,       'h' },
	{ "dev",		required_argument,	NULL,       'd' },
	{ 0, 0, 0, 0 }
};

static void print_usage(int argc, char **argv)
{
	printf(
			"Usage: %s [options]\n"
			"eSPI OOB channel loopback test\n\n"
			"Options:\n"
			" -h | --help       Print this message\n"
			" -d | --dev        eSPI oob device node\n"
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
	int rc;
	char opt;
	uint32_t cyc, tag, len;
	struct aspeed_espi_ioc ioc;
	struct espi_oob_msg *oob_pkt;

	while ((opt=getopt_long(argc, argv, opt_short, opt_long, NULL)) != (char)-1) {
		switch(opt) {
		case 'h':
			print_usage(argc, argv);
			return 0;
		case 'd':
			strcpy(oob_ctx->dev_path, optarg);
			break;
		default:
			print_usage(argc, argv);
			return -1;
		}
	}

	oob_pkt = (struct espi_oob_msg *)malloc(ESPI_PKT_LEN_MAX);
	if (!oob_pkt) {
		printf("cannot allocate OOB packet\n");
		return -1;
	}

	oob_ctx->dev_fd = open(oob_ctx->dev_path, O_RDWR);
	if (oob_ctx->dev_fd == -1) {
		printf("cannot open eSPI OOB devie\n");
		return -1;
	}

	while (1) {
		ioc.pkt_len = ESPI_PKT_LEN_MAX;
		ioc.pkt = (uint8_t *)oob_pkt;

		rc = ioctl(oob_ctx->dev_fd, ASPEED_ESPI_OOB_GET_RX, &ioc);
		if (rc) {
			printf("ASPEED_ESPI_OOB_GET_RX ioctl failed, rc=%d\n", rc);
			break;
		}

		cyc = oob_pkt->cyc;
		tag = oob_pkt->tag;
		len = (oob_pkt->len_h << 8) | (oob_pkt->len_l & 0xff);

		printf("==== Receive RX Packet ====\n");
		printf("cyc=0x%02x, tag=0x%02x, len=0x%04x\n", cyc, tag, len);
		print_hexdump(oob_pkt->data, (len)? len : ESPI_PLD_LEN_MAX);

		ioc.pkt_len = len + sizeof(*oob_pkt);
		ioc.pkt = (uint8_t *)oob_pkt;

		rc = ioctl(oob_ctx->dev_fd, ASPEED_ESPI_OOB_PUT_TX, &ioc);
		if (rc) {
			printf("ASPEED_ESPI_OOB_PUT_TX ioctl failed, rc=%d\n", rc);
			break;
		}
	}

	free(oob_pkt);

	close(oob_ctx->dev_fd);

	return rc;
}
