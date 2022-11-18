#
# Copyright 2020 Aspeed Technology Inc.
#
ifdef INST
ifeq ("$(origin INST)", "command line")
INSTALL_DIR := $(INST)
endif
endif

CFLAGS += -Wall -lpthread
CC      = $(CROSS_COMPILE)gcc

all: perif-test vw-test oob-test oob-pch-test safs-test mafs-test

perif-test: perif-test.o
	$(CC) $(CFLAGS) perif-test.o -o $@

vw-test: vw-test.o
	$(CC) $(CFLAGS) vw-test.o -o $@

oob-test: oob-test.o
	$(CC) $(CFLAGS) oob-test.o -o $@

oob-pch-test: oob-pch-test.o
	$(CC) $(CFLAGS) oob-pch-test.o -o $@

safs-test: safs-test.o
	$(CC) $(CFLAGS) safs-test.o -o $@

mafs-test: mafs-test.o
	$(CC) $(CFLAGS) mafs-test.o -o $@

.c.o:
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f perif-test vw-test oob-test oob-pch-test safs-test mafs-test *.o

install:
	cp perif-test vw-test oob-test oob-pch-test safs-test mafs-test $(INSTALL_DIR)

