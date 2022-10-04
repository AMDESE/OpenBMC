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

enum PCH_REQ_TYPE {
	PCH_REQ_TEMP,
	PCH_REQ_RTC,
	PCH_REQS,
};

struct oob_context {
	int dev_fd;
	char dev_path[256];
};
static struct oob_context oob_ctx[1];

static const char opt_short[] = "hd:tr";

static const struct option opt_long [] = {
	{ "help",		no_argument,		NULL,       'h' },
	{ "dev",		required_argument,	NULL,       'd' },
	{ "temperature",	no_argument,		NULL,       't' },
	{ "rtc",		no_argument,		NULL,       'r' },
	{ 0, 0, 0, 0 }
};

static void print_usage(int argc, char **argv)
{
	printf(
			"Usage: %s [options]\n"
			"eSPI OOB PCH Temperature/RTC test\n\n"
			"Options:\n"
			" -h | --help         Print this message\n"
			" -d | --dev          eSPI oob device node\n"
			" -t | --temperature  PCH Temperature request\n"
			" -r | --rtc          PCH RTC request\n"
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

/*
 * Intel 300 Series and Intel C240 Series Chipset Famliy Platform Controller Hub
 *
 *	eSPI Slave to PCH: Request for PCH Temperature
 *	+-----------------------------------------------+
 *	|  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |
 *	+-----------------------------------------------+
 *	|       eSPI cycle type: OOB message 21h        |
 *	+-----------------------------------------------+
 *	|         Tag[3:0]      |    Length[11:8]=0h    |
 *	+-----------------------------------------------+
 *	|                Length[7:0]=04h                |
 *	+-----------------------------------------------+
 *	| Dst Slv Addr[7:1]=01h (PCH OOB Handler) |  0  |
 *	+-----------------------------------------------+
 *	|         Command Code=01h (Get_PCH_TEMP)       |
 *	+-----------------------------------------------+
 *	|                 Byte Count=01h                |
 *	+-----------------------------------------------+
 *	| Src Slv Addr[7:0]=0Fh (eSPI slave 0/EC) |  1  |
 *	+-----------------------------------------------+
 *
 *
 *	PCH to eSPI Slave: Response with PCH Temperature
 *	+-----------------------------------------------+
 *	|  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |
 *	+-----------------------------------------------+
 *	|       eSPI cycle type: OOB message 21h        |
 *	+-----------------------------------------------+
 *	|         Tag[3:0]      |    Length[11:8]=0h    |
 *	+-----------------------------------------------+
 *	|                Length[7:0]=05h                |
 *	+-----------------------------------------------+
 *	| Dst Slv Addr[7:0]=0Eh (eSPI slave 0/EC) |  0  |
 *	+-----------------------------------------------+
 *	|         Command Code=01h (Get_PCH_TEMP)       |
 *	+-----------------------------------------------+
 *	|                 Byte Count=02h                |
 *	+-----------------------------------------------+
 *	| Src Slv Addr[7:1]=01h (PCH OOB Handler) |  1  |
 *	+-----------------------------------------------+
 *	|             PCH Temperature Data[7:0]         |
 *	+-----------------------------------------------+
 */
static int oob_req_pch_temp(int fd, struct espi_oob_msg *oob_pkt)
{
	int rc;
	struct aspeed_espi_ioc ioc;
	uint32_t cyc, tag, len;

	ioc.pkt = (uint8_t *)oob_pkt;

	oob_pkt->cyc = ESPI_OOB_MSG;
	oob_pkt->tag = 0x0;
	oob_pkt->len_h = 0x0;
	oob_pkt->len_l = 0x4;

	oob_pkt->data[0] = 0x2;
	oob_pkt->data[1] = 0x1;
	oob_pkt->data[2] = 0x1;
	oob_pkt->data[3] = 0xf;

	ioc.pkt_len = ((oob_pkt->len_h << 8) | oob_pkt->len_l) + sizeof(*oob_pkt);
	rc = ioctl(fd, ASPEED_ESPI_OOB_PUT_TX, &ioc);
	if (rc) {
		printf("ASPEED_ESPI_OOB_PUT_TX ioctl failed, rc=%d\n", rc);
		return rc;
	}

	cyc = oob_pkt->cyc;
	tag = oob_pkt->tag;
	len = (oob_pkt->len_h << 8) | (oob_pkt->len_l & 0xff);
	printf("==== Transmit TX Packet ====\n");
	printf("cyc=0x%02x, tag=0x%02x, len=0x%04x\n", cyc, tag, len);
	print_hexdump(oob_pkt->data, (len)? len : ESPI_PLD_LEN_MAX);

	ioc.pkt_len = ESPI_PKT_LEN_MAX;
	rc = ioctl(fd, ASPEED_ESPI_OOB_GET_RX, &ioc);
	if (rc) {
		printf("ASPEED_ESPI_OOB_GET_RX ioctl failed, rc=%d\n", rc);
		return rc;
	}

	cyc = oob_pkt->cyc;
	tag = oob_pkt->tag;
	len = (oob_pkt->len_h << 8) | (oob_pkt->len_l & 0xff);
	printf("==== Receive RX Packet ====\n");
	printf("cyc=0x%02x, tag=0x%02x, len=0x%04x\n", cyc, tag, len);
	print_hexdump(oob_pkt->data, (len)? len : ESPI_PLD_LEN_MAX);

	return 0;
}

/*
 * Intel 300 Series and Intel C240 Series Chipset Famliy Platform Controller Hub
 *
 *	eSPI Slave to PCH: Request for RTC Time
 *	+-----------------------------------------------+
 *	|  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |
 *	+-----------------------------------------------+
 *	|       eSPI cycle type: OOB message 21h        |
 *	+-----------------------------------------------+
 *	|         Tag[3:0]      |    Length[11:8]=0h    |
 *	+-----------------------------------------------+
 *	|                Length[7:0]=04h                |
 *	+-----------------------------------------------+
 *	| Dst Slv Addr[7:1]=01h (PCH OOB Handler) |  0  |
 *	+-----------------------------------------------+
 *	|         Command Code=02h (Get_PCH_RTC_Time)   |
 *	+-----------------------------------------------+
 *	|                 Byte Count=01h                |
 *	+-----------------------------------------------+
 *	| Src Slv Addr[7:0]=0Fh (eSPI slave 0/EC) |  1  |
 *	+-----------------------------------------------+
 *
 *
 *	PCH to eSPI Slave: Response with PCH RTC Time
 *	+-----------------------------------------------+
 *	|  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |
 *	+-----------------------------------------------+
 *	|       eSPI cycle type: OOB message 21h        |
 *	+-----------------------------------------------+
 *	|         Tag[3:0]      |    Length[11:8]=0h    |
 *	+-----------------------------------------------+
 *	|                Length[7:0]=0Ch                |
 *	+-----------------------------------------------+
 *	| Dst Slv Addr[7:0]=0Eh (eSPI slave 0/EC) |  0  |
 *	+-----------------------------------------------+
 *	|         Command Code=02h (Get_PCH_RTC_Time)   |
 *	+-----------------------------------------------+
 *	|                 Byte Count=09h                |
 *	+-----------------------------------------------+
 *	| Src Slv Addr[7:1]=01h (PCH OOB Handler) |  1  |
 *	+-----------------------------------------------+
 *	|          Reserved           | DM  | HF  | DS  |
 *	+-----------------------------------------------+
 *	|             PCH RTC Time: Seconds             |
 *	+-----------------------------------------------+
 *	|             PCH RTC Time: Minutes             |
 *	+-----------------------------------------------+
 *	|             PCH RTC Time: Hours               |
 *	+-----------------------------------------------+
 *	|             PCH RTC Time: Day of Week         |
 *	+-----------------------------------------------+
 *	|             PCH RTC Time: Day of Month        |
 *	+-----------------------------------------------+
 *	|             PCH RTC Time: Month               |
 *	+-----------------------------------------------+
 *	|             PCH RTC Time: Year                |
 *	+-----------------------------------------------+
 */
static int oob_req_pch_rtc(int fd, struct espi_oob_msg *oob_pkt)
{
	int rc;
	struct aspeed_espi_ioc ioc;
	uint32_t cyc, tag, len;

	ioc.pkt = (uint8_t *)oob_pkt;

	oob_pkt->cyc = ESPI_OOB_MSG;
	oob_pkt->tag = 0x0;
	oob_pkt->len_h = 0x0;
	oob_pkt->len_l = 0x4;

	oob_pkt->data[0] = 0x2;
	oob_pkt->data[1] = 0x2;
	oob_pkt->data[2] = 0x1;
	oob_pkt->data[3] = 0xf;

	ioc.pkt_len = ((oob_pkt->len_h << 8) | oob_pkt->len_l) + sizeof(*oob_pkt);
	rc = ioctl(fd, ASPEED_ESPI_OOB_PUT_TX, &ioc);
	if (rc) {
		printf("ASPEED_ESPI_OOB_PUT_TX ioctl failed, rc=%d\n", rc);
		return rc;
	}

	cyc = oob_pkt->cyc;
	tag = oob_pkt->tag;
	len = (oob_pkt->len_h << 8) | (oob_pkt->len_l & 0xff);
	printf("==== Transmit TX Packet ====\n");
	printf("cyc=0x%02x, tag=0x%02x, len=0x%04x\n", cyc, tag, len);
	print_hexdump(oob_pkt->data, (len)? len : ESPI_PLD_LEN_MAX);

	ioc.pkt_len = ESPI_PKT_LEN_MAX;
	rc = ioctl(fd, ASPEED_ESPI_OOB_GET_RX, &ioc);
	if (rc) {
		printf("ASPEED_ESPI_OOB_GET_RX ioctl failed, rc=%d\n", rc);
		return rc;
	}

	cyc = oob_pkt->cyc;
	tag = oob_pkt->tag;
	len = (oob_pkt->len_h << 8) | (oob_pkt->len_l & 0xff);
	printf("==== Receive RX Packet ====\n");
	printf("cyc=0x%02x, tag=0x%02x, len=0x%04x\n", cyc, tag, len);
	print_hexdump(oob_pkt->data, (len)? len : ESPI_PLD_LEN_MAX);

	return 0;
}

int main(int argc, char *argv[])
{
	int rc;
	char opt;
	uint32_t pch_req = PCH_REQS;
	struct espi_oob_msg *oob_pkt;

	while ((opt=getopt_long(argc, argv, opt_short, opt_long, NULL)) != (char)-1) {
		switch(opt) {
		case 'h':
			print_usage(argc, argv);
			return 0;
		case 'd':
			strcpy(oob_ctx->dev_path, optarg);
			break;
		case 't':
			pch_req = PCH_REQ_TEMP;
			break;
		case 'r':
			pch_req = PCH_REQ_RTC;
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

	switch (pch_req) {
	case PCH_REQ_TEMP:
		rc = oob_req_pch_temp(oob_ctx->dev_fd, oob_pkt);
		break;
	case PCH_REQ_RTC:
		rc = oob_req_pch_rtc(oob_ctx->dev_fd, oob_pkt);
		break;
	default:
		printf("Unknown PCH request type: %u\n", pch_req);
		rc = -1;
		break;
	}

	free(oob_pkt);
	close(oob_ctx->dev_fd);

	return rc;
}
