#include "tb_rand.h"

#include <stdlib.h>
#include "tb_config.h"
#include "defs.h"
#include <stdbool.h>

static bool lfsr_init = false;
static uint16_t lfsr; 

#define LFSR_INIT if(lfsr_init == false)tb_rand_init(SEED)

void tb_rand_init(uint16_t seed){
	lfsr = seed;
	lfsr_init = true;
	info("tb_rand_init lfsr %x %p\n", lfsr, &lfsr);
}

uint16_t tb_rand_get_lfsr(){
	return lfsr;
};

uint16_t tb_rand_get_packet_len(){
	LFSR_INIT;
	lfsr = LFSR(lfsr);
	uint16_t rand_cnt = (uint16_t) ( lfsr % (PACKET_LEN_MAX-PACKET_LEN_MIN)) + PACKET_LEN_MIN;
	return rand_cnt;
}


uint16_t tb_rand_packet_idle_cntdown(){
	LFSR_INIT;
	lfsr = LFSR(lfsr);
	return ( lfsr % (PACKET_IDLE_CNT_MAX-PACKET_IDLE_CNT_MIN )) + PACKET_IDLE_CNT_MIN;
}

uint64_t tb_rand_uint64_t(){
	uint64_t r = 0;
	LFSR_INIT;
	info("tb_rand_uint64_t start lfsr %x at %p init %x\n", lfsr, &lfsr, lfsr_init);
	for( int i=0; i<4; i++){
		lfsr = LFSR(lfsr);
		info("tb_rand_uint64_t lfsr %x\n", lfsr);
		r |= (uint64_t)lfsr << 16*i;
	}
	info("tb_rand_uint64_t %x\n", r);
	return r;
}
uint8_t tb_rand_uint8_t(){
	LFSR_INIT;
	lfsr = LFSR(lfsr);
	return (uint8_t) lfsr;
}
void tb_rand_fill_packet(uint8_t * p, size_t len){
	LFSR_INIT;
	for(size_t i=0; i < len; i++){
		lfsr = LFSR(lfsr);
		p[i] = (uint8_t) lfsr;
	}
}

