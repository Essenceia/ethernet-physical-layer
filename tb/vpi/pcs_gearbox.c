#include "pcs_gearbox.h"
#include "defs.h"
uint8_t gearbox( gearbox_s * state, block_s block, uint64_t *pma ){
	if ( state->len >= 64 ){
		// buffer is full : purge
		info("Gearbox purge, len %ld\n", state->len);
		memcpy( pma, &state->buff[0], sizeof(uint64_t));
		state->len = 0;		
	}else{
		// buffer is not full : add
		info("gb start : [1,0]{%016lx, %016lx}\n", state->buff[1], state->buff[0]);
		state->buff[1] = state->buff[0]; // make way for new data
		state->buff[0] = block.data;
		state->buff[1] = (state->buff[1] << 2 ) | (((state->buff[0] & 0xc000000000000000) >> 62 ) & 0x3);
		state->buff[0] = (state->buff[0] << 2 ) | block.head;
		memcpy( pma, &state->buff[0], sizeof(uint64_t));
		state->buff[0] = state->buff[1]; 
		state->len += 2;
		if ( state->len >= 64 ) return 1;
	}
	return 0; 
} 

