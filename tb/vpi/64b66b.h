#ifndef _64B66B_H
#define _64B66B_H
#include "pcs_defs.h"

uint64_t scramble(uint64_t *state, uint64_t data, size_t len);
uint64_t descramble(uint64_t *state, uint64_t data, size_t len);
#endif //_64B66B_H
