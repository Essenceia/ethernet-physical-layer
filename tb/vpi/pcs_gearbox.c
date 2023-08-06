#include "pcs_gearbox.h"
#include "defs.h"
#include <string.h>
uint8_t gearbox( gearbox_s * state, block_s block, uint64_t *pma ){
	if ( state->len >= 64 ){
		// buffer is full : purge
		info("Gearbox purge, len %ld\n", state->len);
		memcpy( pma, &state->buff[0], sizeof(uint64_t));
		state->len = 0;	
		state->buff[0] = 0;	
		state->buff[1] = 0;	
	}else{
		// buffer is not full : add
		info("gb start : [x%x]{%016lx, %016lx} len %ld\n", block.head, state->buff[1], state->buff[0], state->len);
		info("data %lx\n", block.data);
		uint64_t flop = state->buff[0];
		state->buff[0] = block.data;
		state->buff[0]<<= 2;
		state->buff[0] |= block.head & 0x3;
		state->buff[0]<<=state->len;
		state->buff[0] |= flop;
		state->buff[1] = block.data >> ( 64 - ( state->len + 2));
		info("{ buff[1] buff[0] } = { %lx, %lx} \n", state->buff[1], state->buff[0]);
		memcpy( pma, &state->buff[0], sizeof(uint64_t));
		state->buff[0] = state->buff[1]; 
		state->len += 2;
		if ( state->len >= 64 ) return 1;
	}
	return 0; 
} 

