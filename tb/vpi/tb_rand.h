#ifndef TB_RAND_H
#define TB_RAND_H

#include <stdlib.h>
#include "tb_config.h"

#define LFSR(x) ((x >> 0) ^ (x >> 2) ^ (x >> 3) ^ (x >> 5)) & 1u 

static uint16_t lfsr; 
static inline void tb_rand_init(uint16_t seed){
	lfsr = seed;
}

static inline uint16_t tb_rand_get_lfsr(){
	return lfsr;
};

static inline uint16_t tb_rand_get_packet_len(){
	lfsr = LFSR(lfsr);
	uint16_t rand_cnt = (uint16_t) ( lfsr % (PACKET_LEN_MAX-PACKET_LEN_MIN)) + PACKET_LEN_MIN;
	return rand_cnt;
}


static inline uint16_t tb_rand_packet_idle_cntdown(){
	lfsr = LFSR(lfsr);
	return ( lfsr % (PACKET_IDLE_CNT_MAX-PACKET_IDLE_CNT_MIN )) + PACKET_IDLE_CNT_MIN;
}


static inline void tb_rand_fill_packet(uint8_t* p, size_t len){
	for(size_t i=0; i < len; i++){
		lfsr = LFSR(lfsr);
		p[i] = (uint8_t) lfsr;
	}
}
#endif//TB_RAND_H
