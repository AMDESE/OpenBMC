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

enum mafs_operation {
	MAFS_OP_READ = 1,
	MAFS_OP_WRITE,
	MAFS_OP_ERASE,
};

struct mafs_context {
	int dev_fd;
	int img_fd;
	char dev_path[256];
	char img_path[256];
	uint32_t addr;
	uint32_t len;
	uint32_t op;
};
static struct mafs_context mafs_ctx[1];

static const char opt_short[] = "hd:f:rwea:l:";

static const struct option opt_long [] = {
	{ "help",	no_argument,		NULL,       'h' },
	{ "dev",	required_argument,	NULL,       'd' },
	{ "file",	required_argument,	NULL,       'f' },
	{ "read",	no_argument,		NULL,       'r' },
	{ "write",	no_argument,		NULL,       'w' },
	{ "erase",	no_argument,		NULL,       'e' },
	{ "addr",	required_argument,	NULL,       'a' },
	{ "length",	required_argument,	NULL,       'l' },
	{ 0, 0, 0, 0 }
};

static void print_usage(int argc, char **argv)
{
	printf(
			"Usage: %s [options]\n"
			"eSPI MAFS flash channel client\n\n"
			"Options:\n"
			" -h | --help       Print this message\n"
			" -d | --dev        eSPI flash device node\n"
			" -f | --file       input/output image file\n"
			" -r | --read       MAFS read\n"
			" -w | --write      MAFS write\n"
			" -e | --erase      MAFS erase\n"
			" -a | --addr       MAFS read/write addr\n"
			" -l | --length	    MAFS read/write length\n"
			"",
			argv[0]);
}

static int espi_mafs_read(uint32_t addr, uint32_t len)
{
	int rc;
	uint32_t len_pt;
	struct aspeed_espi_ioc ioc;
	struct espi_flash_rwe *rwe_pkt;
	struct espi_flash_cmplt *cmplt_pkt;

	mafs_ctx->img_fd = open(mafs_ctx->img_path, O_WRONLY | O_CREAT, 0644);
	if (mafs_ctx->img_fd == -1) {
		printf("cannot open image file\n");
		return -1;
	}

	rwe_pkt = (struct espi_flash_rwe *)malloc(ESPI_PKT_LEN_MAX);
	if (!rwe_pkt) {
		printf("cannot allocate flash read/write/erase packet\n");
		return -1;
	}

	cmplt_pkt = (struct espi_flash_cmplt *)malloc(ESPI_PKT_LEN_MAX);
	if (!rwe_pkt) {
		printf("cannot allocate flash completion packet\n");
		return -1;
	}

	while (len) {
		len_pt = (len > ESPI_PLD_LEN_MIN)? ESPI_PLD_LEN_MIN : len;

		rwe_pkt->cyc = ESPI_FLASH_READ;
		rwe_pkt->tag = 0;
		rwe_pkt->len_h = len_pt >> 8;
		rwe_pkt->len_l = len_pt & 0xff;
		rwe_pkt->addr_be = bswap_32(addr);

		ioc.pkt_len = sizeof(*rwe_pkt);
		ioc.pkt = (uint8_t *)rwe_pkt;

		rc = ioctl(mafs_ctx->dev_fd, ASPEED_ESPI_FLASH_PUT_TX, &ioc);
		if (rc) {
			printf("ASPEED_ESPI_FLASH_PUT_TX ioctl failed, rc=%d\n", rc);
			return rc;
		}

		ioc.pkt_len = ESPI_PKT_LEN_MAX;
		ioc.pkt = (uint8_t *)cmplt_pkt;

		rc = ioctl(mafs_ctx->dev_fd, ASPEED_ESPI_FLASH_GET_RX, &ioc);
		if (rc) {
			printf("ASPEED_ESPI_FLASH_GET_RX ioctl failed, rc=%d\n", rc);
			return rc;
		}

		if (cmplt_pkt->cyc != ESPI_FLASH_SUC_CMPLT_D_ONLY) {
			printf("unexpected completion packet from MAFS, cyc=%02x, expected=%02x\n",
					cmplt_pkt->cyc, ESPI_FLASH_SUC_CMPLT_D_ONLY);
			return -1;
		}

		if (write(mafs_ctx->img_fd, cmplt_pkt->data, len_pt) != len_pt) {
			printf("cannot write to image file\n");
			return -1;
		}

		len -= len_pt;
		addr += len_pt;
	}

	return 0;
}

static int espi_mafs_write(uint32_t addr, uint32_t len)
{
	int rc;
	uint32_t len_pt;
	struct aspeed_espi_ioc ioc;
	struct espi_flash_rwe *rwe_pkt;
	struct espi_flash_cmplt *cmplt_pkt;

	mafs_ctx->img_fd = open(mafs_ctx->img_path, O_RDONLY);
	if (mafs_ctx->img_fd == -1) {
		printf("cannot open image file\n");
		return -1;
	}

	rwe_pkt = (struct espi_flash_rwe *)malloc(ESPI_PKT_LEN_MAX);
	if (!rwe_pkt) {
		printf("cannot allocate flash read/write/erase packet\n");
		return -1;
	}

	cmplt_pkt = (struct espi_flash_cmplt *)malloc(ESPI_PKT_LEN_MAX);
	if (!cmplt_pkt) {
		printf("cannot allocate flash completion packet\n");
		return -1;
	}

	while (len) {
		len_pt = (len > ESPI_PLD_LEN_MIN)? ESPI_PLD_LEN_MIN : len;

		if (read(mafs_ctx->img_fd, rwe_pkt->data, len_pt) != len_pt) {
			printf("cannot read from image file\n");
			return -1;
		}

		rwe_pkt->cyc = ESPI_FLASH_WRITE;
		rwe_pkt->tag = 0;
		rwe_pkt->len_h = len_pt >> 8;
		rwe_pkt->len_l = len_pt & 0xff;
		rwe_pkt->addr_be = bswap_32(addr);

		ioc.pkt_len = len_pt + sizeof(*rwe_pkt);
		ioc.pkt = (uint8_t *)rwe_pkt;

		rc = ioctl(mafs_ctx->dev_fd, ASPEED_ESPI_FLASH_PUT_TX, &ioc);
		if (rc) {
			printf("ASPEED_ESPI_FLASH_PUT_TX ioctl failed, rc=%d\n", rc);
			return rc;
		}

		ioc.pkt_len = ESPI_PKT_LEN_MAX;
		ioc.pkt = (uint8_t *)cmplt_pkt;

		rc = ioctl(mafs_ctx->dev_fd, ASPEED_ESPI_FLASH_GET_RX, &ioc);
		if (rc) {
			printf("ASPEED_ESPI_FLASH_GET_RX ioctl failed, rc=%d\n", rc);
			return rc;
		}

		if (cmplt_pkt->cyc != ESPI_FLASH_SUC_CMPLT) {
			printf("unexpected completion packet from MAFS, cyc=%02x, expected=%02x\n",
					cmplt_pkt->cyc, ESPI_FLASH_SUC_CMPLT);
			return -1;
		}

		len -= len_pt;
		addr += len_pt;
	}

	return 0;
}

static int espi_mafs_erase(uint32_t addr, uint32_t len)
{
	int rc;
	uint32_t len_pt;
	struct aspeed_espi_ioc ioc;
	struct espi_flash_rwe *rwe_pkt;
	struct espi_flash_cmplt *cmplt_pkt;

	rwe_pkt = (struct espi_flash_rwe *)malloc(ESPI_PKT_LEN_MAX);
	if (!rwe_pkt) {
		printf("cannot allocate flash read/write/erase packet\n");
		return -1;
	}

	cmplt_pkt = (struct espi_flash_cmplt *)malloc(ESPI_PKT_LEN_MAX);
	if (!cmplt_pkt) {
		printf("cannot allocate flash completion packet\n");
		return -1;
	}

	while (len) {
		len_pt = (len > ESPI_PLD_LEN_MAX)? 0 : len;

		rwe_pkt->cyc = ESPI_FLASH_ERASE;
		rwe_pkt->tag = 0;
		rwe_pkt->len_h = len_pt >> 8;
		rwe_pkt->len_l = len_pt & 0xff;
		rwe_pkt->addr_be = bswap_32(addr);

		ioc.pkt_len = sizeof(*rwe_pkt);
		ioc.pkt = (uint8_t *)rwe_pkt;

		rc = ioctl(mafs_ctx->dev_fd, ASPEED_ESPI_FLASH_PUT_TX, &ioc);
		if (rc) {
			printf("ASPEED_ESPI_FLASH_PUT_TX ioctl failed, rc=%d\n", rc);
			return rc;
		}

		ioc.pkt_len = ESPI_PKT_LEN_MAX;
		ioc.pkt = (uint8_t *)cmplt_pkt;

		rc = ioctl(mafs_ctx->dev_fd, ASPEED_ESPI_FLASH_GET_RX, &ioc);
		if (rc) {
			printf("ASPEED_ESPI_FLASH_GET_RX ioctl failed, rc=%d\n", rc);
			return rc;
		}

		if (cmplt_pkt->cyc != ESPI_FLASH_SUC_CMPLT) {
			printf("unexpected completion packet from MAFS, cyc=%02x, expected=%02x\n",
					cmplt_pkt->cyc, ESPI_FLASH_SUC_CMPLT);
			return -1;
		}

		len -= (len_pt)? len_pt : ESPI_PLD_LEN_MAX;
		addr += (len_pt)? len_pt : ESPI_PLD_LEN_MAX;
	}

	return 0;
}

int main(int argc, char *argv[])
{
	int rc = 0;
	char opt;

	while ((opt=getopt_long(argc, argv, opt_short, opt_long, NULL)) != (char)-1) {
		switch(opt) {
		case 'h':
			print_usage(argc, argv);
			return 0;
		case 'd':
			strcpy(mafs_ctx->dev_path, optarg);
			break;
		case 'f':
			strcpy(mafs_ctx->img_path, optarg);
			break;
		case 'r':
			mafs_ctx->op = MAFS_OP_READ;
			break;
		case 'w':
			mafs_ctx->op = MAFS_OP_WRITE;
			break;
		case 'e':
			mafs_ctx->op = MAFS_OP_ERASE;
			break;
		case 'a':
			mafs_ctx->addr = strtoul(optarg, NULL, 0);
			break;
		case 'l':
			mafs_ctx->len = strtoul(optarg, NULL, 0);
			break;
		default:
			print_usage(argc, argv);
			return -1;
		}
	}

	if (!mafs_ctx->len)
		return 0;

	mafs_ctx->dev_fd = open(mafs_ctx->dev_path, O_RDWR);
	if (mafs_ctx->dev_fd == -1) {
		printf("cannot open eSPI flash device\n");
		return -1;
	}

	switch (mafs_ctx->op) {
	case MAFS_OP_READ:
		rc = espi_mafs_read(mafs_ctx->addr, mafs_ctx->len);
		break;
	case MAFS_OP_WRITE:
		rc = espi_mafs_write(mafs_ctx->addr, mafs_ctx->len);
		break;
	case MAFS_OP_ERASE:
		rc = espi_mafs_erase(mafs_ctx->addr, mafs_ctx->len);
		break;
	default:
		printf("unknown eSPI MAFS operation=%u\n", mafs_ctx->op);
		return -1;
	}

	close(mafs_ctx->dev_fd);
	close(mafs_ctx->img_fd);

	return rc;
}
