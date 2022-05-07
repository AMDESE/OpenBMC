#ifndef COMMON_H
#define COMMON_H

#define FILEPATHSIZE          256
#define ARGV_0    0
#define ARGV_1    1
#define ARGV_2    2
#define ARGV_3    3
#define ARGV_4    4
#define ARGV_5    5
#define ARGV_6    6

#define BASE_16               (16)
#define BYTE_COUNT_2          (2)
#define BYTE_COUNT_4          (4)
#define BYTE_COUNT_5          (5)

#define SHIFT_24              (24)
#define SHIFT_16              (16)
#define SHIFT_8               (8)
#define SHIFT_6               (6)
#define SHIFT_4               (4)

int infineon_vr_update(int argc, char *argv[]);
int renesas_vr_update(int argc, char *argv[]);
int crc_check_verification(int argc, char* argv[],int crc_value);

#endif
