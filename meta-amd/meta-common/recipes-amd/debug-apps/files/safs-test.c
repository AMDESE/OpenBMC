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
#include <mtd/mtd-user.h>
#include <byteswap.h>

#include "aspeed-espi.h"

struct safs_context {
	int dev_fd;
	int mtd_fd;
	char dev_path[256];
	char mtd_path[256];
	mtd_info_t mtd_info;
};
static struct safs_context safs_ctx[1];

static const char opt_short[] = "hd:m:";

static const struct option opt_long [] = {
	{ "help",	no_argument,		NULL,       'h' },
	{ "dev",	required_argument,	NULL,       'd' },
	{ "mtd",	required_argument,	NULL,       'm' },
	{ 0, 0, 0, 0 }
};

static void print_usage(int argc, char **argv)
{
	printf(
			"Usage: %s [options]\n"
			"eSPI SAFS flash channel server\n\n"
			"Options:\n"
			" -h | --help       Print this message\n"
			" -d | --dev        eSPI flash device node\n"
			" -m | --mtd        MTD device node\n"
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

static ssize_t flash_read(uint32_t addr, uint32_t len, uint8_t *buf)
{
	lseek(safs_ctx->mtd_fd, addr, SEEK_SET);
	return read(safs_ctx->mtd_fd, buf, len);
}

static ssize_t flash_write(uint32_t addr, uint32_t len, uint8_t *buf)
{
	lseek(safs_ctx->mtd_fd, addr, SEEK_SET);
	return write(safs_ctx->mtd_fd, buf, len);
}

static int flash_erase(uint32_t addr, uint32_t len)
{
	int i, rc;
	erase_info_t ei;

	for (i = 0; i < len; i += safs_ctx->mtd_info.erasesize) {

		ei.start = addr + i;
		ei.length = safs_ctx->mtd_info.erasesize;

		ioctl(safs_ctx->mtd_fd, MEMUNLOCK, &ei);

		rc = ioctl(safs_ctx->mtd_fd, MEMERASE, &ei);
		if (rc) {
			printf("MEMERASE ioctl with addr=0x%08x, rc=%d\n", ei.start, rc);
			return -1;
		}
	}

	return 0;
}

static int espi_safs_read(uint8_t tag, uint32_t addr, uint32_t len)
{
	int rc = 0, idx = 0;
	uint8_t buf[ESPI_PLD_LEN_MAX];
	struct aspeed_espi_ioc ioc;
	struct espi_flash_cmplt *cmplt_pkt;

	cmplt_pkt = (struct espi_flash_cmplt *)malloc(ESPI_PKT_LEN_MAX);
	if (!cmplt_pkt) {
		printf("cannot allocate completion packet\n");
		return -1;
	}

	len = flash_read(addr,
			(len)? len : ESPI_PLD_LEN_MAX,
			buf);

	rc = (int)len;
	if (rc < 0) {
		printf("cannot read flash, rc=%d\n", rc);

		cmplt_pkt->cyc = ESPI_FLASH_UNSUC_CMPLT;
		cmplt_pkt->tag = tag;
		cmplt_pkt->len_h = 0;
		cmplt_pkt->len_l = 0;

		ioc.pkt_len = sizeof(*cmplt_pkt);
		ioc.pkt = (uint8_t*)cmplt_pkt;

		rc = ioctl(safs_ctx->dev_fd, ASPEED_ESPI_FLASH_PUT_TX, &ioc);
		if (rc)
			printf("ASPEED_ESPI_FLASH_PUT_TX ioctl failed with rc=%d\n", rc);

		goto free_n_out;
	}

	if (len <= ESPI_PLD_LEN_MIN) {
		cmplt_pkt->cyc = ESPI_FLASH_SUC_CMPLT_D_ONLY;
		cmplt_pkt->tag = tag;
		cmplt_pkt->len_h = len >> 8;
		cmplt_pkt->len_l = len & 0xff;
		memcpy(cmplt_pkt->data, buf + idx, len);

		ioc.pkt_len = len + sizeof(*cmplt_pkt);
		ioc.pkt = (uint8_t*)cmplt_pkt;

		rc = ioctl(safs_ctx->dev_fd, ASPEED_ESPI_FLASH_PUT_TX, &ioc);
		if (rc) {
			printf("ASPEED_ESPI_FLASH_PUT_TX ioctl failed with rc=%d\n", rc);
			goto free_n_out;
		}
	}
	else {
		/* first data */
		cmplt_pkt->cyc = ESPI_FLASH_SUC_CMPLT_D_FIRST;
		cmplt_pkt->tag = tag;
		cmplt_pkt->len_h = ESPI_PLD_LEN_MIN >> 8;
		cmplt_pkt->len_l = ESPI_PLD_LEN_MIN & 0xff;
		memcpy(cmplt_pkt->data, buf + idx, ESPI_PLD_LEN_MIN);

		ioc.pkt_len = ESPI_PLD_LEN_MIN + sizeof(*cmplt_pkt);
		ioc.pkt = (uint8_t *)cmplt_pkt;

		rc = ioctl(safs_ctx->dev_fd, ASPEED_ESPI_FLASH_PUT_TX, &ioc);
		if (rc) {
			printf("ASPEED_ESPI_FLASH_PUT_TX ioctl failed with rc=%d\n", rc);
			goto free_n_out;
		}

		len -= ESPI_PLD_LEN_MIN;
		idx += ESPI_PLD_LEN_MIN;

		/* middle data */
		while (len > ESPI_PLD_LEN_MIN) {
			cmplt_pkt->cyc = ESPI_FLASH_SUC_CMPLT_D_MIDDLE;
			cmplt_pkt->tag = tag;
			cmplt_pkt->len_h = ESPI_PLD_LEN_MIN >> 8;
			cmplt_pkt->len_l = ESPI_PLD_LEN_MIN & 0xff;
			memcpy(cmplt_pkt->data, buf + idx, ESPI_PLD_LEN_MIN);

			ioc.pkt_len = ESPI_PLD_LEN_MIN + sizeof(*cmplt_pkt);
			ioc.pkt = (uint8_t *)cmplt_pkt;

			rc = ioctl(safs_ctx->dev_fd, ASPEED_ESPI_FLASH_PUT_TX, &ioc);
			if (rc) {
				printf("ASPEED_ESPI_FLASH_PUT_TX ioctl failed with rc=%d\n", rc);
				goto free_n_out;
			}

			len -= ESPI_PLD_LEN_MIN;
			idx += ESPI_PLD_LEN_MIN;
		}

		/* last data */
		cmplt_pkt->cyc = ESPI_FLASH_SUC_CMPLT_D_LAST;
		cmplt_pkt->tag = tag;
		cmplt_pkt->len_h = len >> 8;
		cmplt_pkt->len_l = len & 0xff;
		memcpy(cmplt_pkt->data, buf + idx, len);

		ioc.pkt_len = len + sizeof(*cmplt_pkt);
		ioc.pkt = (uint8_t *)cmplt_pkt;

		rc = ioctl(safs_ctx->dev_fd, ASPEED_ESPI_FLASH_PUT_TX, &ioc);
		if (rc) {
			printf("ASPEED_ESPI_FLASH_PUT_TX ioctl failed with rc=%d\n", rc);
			goto free_n_out;
		}
	}

free_n_out:
	free(cmplt_pkt);

	return 0;
}

static int espi_safs_write(uint8_t tag, uint32_t addr, uint32_t len, uint8_t *buf)
{
	int rc = 0;
	struct aspeed_espi_ioc ioc;
	struct espi_flash_cmplt cmplt_pkt;

	rc = flash_write(addr, (len)? len : ESPI_PLD_LEN_MAX, buf);
	if (rc < 0)
		printf("cannot write flash, rc=%d\n", rc);

	cmplt_pkt.cyc = (rc < 0)? ESPI_FLASH_UNSUC_CMPLT : ESPI_FLASH_SUC_CMPLT;
	cmplt_pkt.tag = tag;
	cmplt_pkt.len_h = 0;
	cmplt_pkt.len_l = 0;

	ioc.pkt_len = sizeof(cmplt_pkt);
	ioc.pkt = (uint8_t *)&cmplt_pkt;

	rc = ioctl(safs_ctx->dev_fd, ASPEED_ESPI_FLASH_PUT_TX, &ioc);
	if (rc) {
		printf("ASPEED_ESPI_FLASH_PUT_TX ioctl failed, rc=%d\n", rc);
		return rc;
	}

	return rc;
}

static int espi_safs_erase(uint8_t tag, uint32_t addr, uint32_t len)
{
	int rc = 0;
	struct aspeed_espi_ioc ioc;
	struct espi_flash_cmplt cmplt_pkt;

	rc = flash_erase(addr, (len)? len : ESPI_PLD_LEN_MAX);

	cmplt_pkt.cyc = (rc)? ESPI_FLASH_UNSUC_CMPLT : ESPI_FLASH_SUC_CMPLT;
	cmplt_pkt.tag = tag;
	cmplt_pkt.len_h = 0;
	cmplt_pkt.len_l = 0;

	ioc.pkt_len = sizeof(cmplt_pkt);
	ioc.pkt = (uint8_t *)&cmplt_pkt;

	rc = ioctl(safs_ctx->dev_fd, ASPEED_ESPI_FLASH_PUT_TX, &ioc);
	if (rc) {
		printf("ASPEED_ESPI_FLASH_PUT_TX ioctl failed, rc=%d\n", rc);
		return rc;
	}

	return rc;
}

int main(int argc, char *argv[])
{
	int rc;
	char opt;
	uint32_t cyc, tag, len, addr;
	struct aspeed_espi_ioc ioc;
	struct espi_flash_rwe *rwe_pkt;

	while ((opt=getopt_long(argc, argv, opt_short, opt_long, NULL)) != (char)-1) {
		switch(opt) {
		case 'h':
			print_usage(argc, argv);
			return 0;
		case 'd':
			strcpy(safs_ctx->dev_path, optarg);
			break;
		case 'm':
			strcpy(safs_ctx->mtd_path, optarg);
			break;
		default:
			print_usage(argc, argv);
			return -1;
		}
	}

	rwe_pkt = (struct espi_flash_rwe *)malloc(ESPI_PKT_LEN_MAX);
	if (!rwe_pkt) {
		printf("cannot allocate flash R/W/E packet\n");
		return -1;
	}

	safs_ctx->dev_fd = open(safs_ctx->dev_path, O_RDWR);
	if (safs_ctx->dev_fd == -1) {
		printf("cannot open eSPI flash device\n");
		return -1;
	}

	safs_ctx->mtd_fd = open(safs_ctx->mtd_path, O_RDWR);
	if (safs_ctx->mtd_fd == -1) {
		printf("cannot open MTD device\n");
		return -1;
	}

	rc = ioctl(safs_ctx->mtd_fd, MEMGETINFO, &safs_ctx->mtd_info);
	if (rc) {
		printf("MEMGETINFO ioctl failed, rc=%d\n", rc);
		return rc;
	}

	printf("MTD type: 0x%x, size: 0x%x, erase_size: 0x%x\n",
			safs_ctx->mtd_info.type,
			safs_ctx->mtd_info.size,
			safs_ctx->mtd_info.erasesize);

	ioc.pkt_len = ESPI_PKT_LEN_MAX;
	ioc.pkt = (uint8_t *)rwe_pkt;

	while (1) {
		rc = ioctl(safs_ctx->dev_fd, ASPEED_ESPI_FLASH_GET_RX, &ioc);
		if (rc) {
			printf("ASPEED_ESPI_FLASH_GET_RX ioctl failed, rc=%d\n", rc);
			break;
		}

		cyc = rwe_pkt->cyc;
		tag = rwe_pkt->tag;
		len = (rwe_pkt->len_h << 8) | (rwe_pkt->len_l & 0xff);
		addr = bswap_32(rwe_pkt->addr_be);

		printf("==== Receive RX Packet ====\n");
		printf("cyc=0x%02x, tag=0x%02x, len=0x%04x, addr=0x%08x\n",
				cyc, tag, len, addr);
		if (cyc == ESPI_FLASH_WRITE)
			print_hexdump(rwe_pkt->data, len);

		switch (cyc) {
		case ESPI_FLASH_READ:
			rc = espi_safs_read(tag, addr, len);
			printf("[%s] eSPI SAFS read addr=0x%08x, len=0x%04x, rc=%d\n",
					(rc)? "FAIL" : "SUCC", addr, len, rc);
			break;
		case ESPI_FLASH_WRITE:
			rc = espi_safs_write(tag, addr, len, rwe_pkt->data);
			printf("[%s] eSPI SAFS write addr=0x%08x, len=0x%04x, rc=%d\n",
					(rc)? "FAIL" : "SUCC", addr, len, rc);
			break;
		case ESPI_FLASH_ERASE:
			rc = espi_safs_erase(tag, addr, len);
			printf("[%s] eSPI SAFS erase addr=0x%08x, len=0x%04x, rc=%d\n",
					(rc)? "FAIL" : "SUCC", addr, len, rc);
			break;
		default:
			printf("unexpected packet\n");
			break;
		}
	}

	close(safs_ctx->dev_fd);
	close(safs_ctx->mtd_fd);

	return rc;
}
