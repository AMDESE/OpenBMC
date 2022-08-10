/*
 * Copyright 2020 Aspeed Technology Inc.
 */
#ifndef _UAPI_LINUX_ASPEED_ESPI_H
#define _UAPI_LINUX_ASPEED_ESPI_H

#ifdef __KERNEL__
#include <linux/ioctl.h>
#include <linux/types.h>
#else
#include <sys/ioctl.h>
#include <stdint.h>
#endif

/*
 * eSPI cycle type encoding
 *
 * Section 5.1 Cycle Types and Packet Format,
 * Intel eSPI Interface Base Specification, Rev 1.0, Jan. 2016.
 */
#define ESPI_PERIF_MEMRD32		0x00
#define ESPI_PERIF_MEMRD64		0x02
#define ESPI_PERIF_MEMWR32		0x01
#define ESPI_PERIF_MEMWR64		0x03
#define ESPI_PERIF_MSG			0x10
#define ESPI_PERIF_MSG_D		0x11
#define ESPI_PERIF_SUC_CMPLT		0x06
#define ESPI_PERIF_SUC_CMPLT_D_MIDDLE	0x09
#define ESPI_PERIF_SUC_CMPLT_D_FIRST	0x0b
#define ESPI_PERIF_SUC_CMPLT_D_LAST	0x0d
#define ESPI_PERIF_SUC_CMPLT_D_ONLY	0x0f
#define ESPI_PERIF_UNSUC_CMPLT		0x0c
#define ESPI_OOB_MSG			0x21
#define ESPI_FLASH_READ			0x00
#define ESPI_FLASH_WRITE		0x01
#define ESPI_FLASH_ERASE		0x02
#define ESPI_FLASH_SUC_CMPLT		0x06
#define ESPI_FLASH_SUC_CMPLT_D_MIDDLE	0x09
#define ESPI_FLASH_SUC_CMPLT_D_FIRST	0x0b
#define ESPI_FLASH_SUC_CMPLT_D_LAST	0x0d
#define ESPI_FLASH_SUC_CMPLT_D_ONLY	0x0f
#define ESPI_FLASH_UNSUC_CMPLT		0x0c

/*
 * eSPI packet format structure
 *
 * Section 5.1 Cycle Types and Packet Format,
 * Intel eSPI Interface Base Specification, Rev 1.0, Jan. 2016.
 */
struct espi_comm_hdr {
	uint8_t cyc;
	uint8_t len_h : 4;
	uint8_t tag : 4;
	uint8_t len_l;
};

struct espi_perif_mem32 {
	uint8_t cyc;
	uint8_t len_h : 4;
	uint8_t tag : 4;
	uint8_t len_l;
	uint32_t addr_be;
	uint8_t data[];
} __attribute__((packed));

struct espi_perif_mem64 {
	uint8_t cyc;
	uint8_t len_h : 4;
	uint8_t tag : 4;
	uint8_t len_l;
	uint32_t addr_be;
	uint8_t data[];
} __attribute__((packed));

struct espi_perif_msg {
	uint8_t cyc;
	uint8_t len_h : 4;
	uint8_t tag : 4;
	uint8_t len_l;
	uint8_t msg_code;
	uint8_t msg_byte[4];
	uint8_t data[];
} __attribute__((packed));

struct espi_perif_cmplt {
	uint8_t cyc;
	uint8_t len_h : 4;
	uint8_t tag : 4;
	uint8_t len_l;
	uint8_t data[];
} __attribute__((packed));

struct espi_oob_msg {
	uint8_t cyc;
	uint8_t len_h : 4;
	uint8_t tag : 4;
	uint8_t len_l;
	uint8_t data[];
};

struct espi_flash_rwe {
	uint8_t cyc;
	uint8_t len_h : 4;
	uint8_t tag : 4;
	uint8_t len_l;
	uint32_t addr_be;
	uint8_t data[];
} __attribute__((packed));

struct espi_flash_cmplt {
	uint8_t cyc;
	uint8_t len_h : 4;
	uint8_t tag : 4;
	uint8_t len_l;
	uint8_t data[];
} __attribute__((packed));

struct aspeed_espi_ioc {
	uint32_t pkt_len;
	uint8_t *pkt;
};

/*
 * we choose the longest header and the max payload size
 * based on the Intel specification to define the maximum
 * eSPI packet length
 */
#define ESPI_PLD_LEN_MIN	(1UL << 6)
#define ESPI_PLD_LEN_MAX	(1UL << 12)
#define ESPI_PKT_LEN_MAX	(sizeof(struct espi_perif_msg) + ESPI_PLD_LEN_MAX)

#define __ASPEED_ESPI_IOCTL_MAGIC	0xb8

/* peripheral channel (ch0) */
#define ASPEED_ESPI_PERIF_PC_GET_RX	_IOR(__ASPEED_ESPI_IOCTL_MAGIC, \
					     0x00, struct aspeed_espi_ioc)
#define ASPEED_ESPI_PERIF_PC_PUT_TX	_IOW(__ASPEED_ESPI_IOCTL_MAGIC, \
					     0x01, struct aspeed_espi_ioc)
#define ASPEED_ESPI_PERIF_NP_PUT_TX	_IOW(__ASPEED_ESPI_IOCTL_MAGIC, \
					     0x02, struct aspeed_espi_ioc)
/* peripheral channel (ch1) */
#define ASPEED_ESPI_VW_GET_GPIO_VAL	_IOR(__ASPEED_ESPI_IOCTL_MAGIC, \
					     0x10, uint8_t)
#define ASPEED_ESPI_VW_PUT_GPIO_VAL	_IOW(__ASPEED_ESPI_IOCTL_MAGIC, \
					     0x11, uint8_t)
/* out-of-band channle (ch2) */
#define ASPEED_ESPI_OOB_GET_RX		_IOR(__ASPEED_ESPI_IOCTL_MAGIC, \
					     0x20, struct aspeed_espi_ioc)
#define ASPEED_ESPI_OOB_PUT_TX		_IOW(__ASPEED_ESPI_IOCTL_MAGIC, \
					     0x21, struct aspeed_espi_ioc)
/* flash channel (ch3) */
#define ASPEED_ESPI_FLASH_GET_RX	_IOR(__ASPEED_ESPI_IOCTL_MAGIC, \
					     0x30, struct aspeed_espi_ioc)
#define ASPEED_ESPI_FLASH_PUT_TX	_IOW(__ASPEED_ESPI_IOCTL_MAGIC, \
					     0x31, struct aspeed_espi_ioc)

#endif
