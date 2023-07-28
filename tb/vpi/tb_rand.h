#ifndef TB_RAND_H
#define TB_RAND_H

#include <stdlib.h>
#include "tb_config.h"

static uint26_t lfsr; 
static inline void tb_rand_init(unsigned seed){
	lfsr = seed;
}

static intline void tb_rand_get_lfsr(){
	return lfsr;
};
static inline uint16_t tb_rand_get_packet_len(){
	lfsr = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)) & 1u;
	uint16_t rand_cnt = (uint16_t) ( lfsr % (PACKET_LEN_MAX-PACKET_LEN_MIN)) + PACKET_LEN_MIN;
	return rand_cnt;
}
#endif//TB_RAND_H
