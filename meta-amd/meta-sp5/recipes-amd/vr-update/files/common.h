#ifndef COMMON_H
#define COMMON_H

#define FILEPATHSIZE          256

int infineon_vr_update(int argc, char *argv[]);
int renesas_vr_update(int argc, char *argv[]);
int crc_check_verification(int argc, char* argv[],int crc_value);

#endif
