#include "pcs_gearbox.h"

uint8_t gearbox( gearbox_s * state, block_s block, uint64_t *pma ){
	if ( state->len >= 64 ){
		// buffer is full : purge
		*pma = state->buff[0];
		state->len = 0;		
	}else{
		// buffer is not full : add
		state->buff[1] = state->buff[0]; // make way for new data
		state->buff[0] = block.data;
		state->buff[1] = (state->buff[1] << 2 ) | (((state->buff[0] & 0xc000000000000000) >> 62 ) & 0x3);
		state->buff[0] = (state->buff[0] << 2 ) | block.head;
		*pma = ( uint64_t ) state->buff[0];
		state->buff[0] = state->buff[1]; 
		state->len += 2;
		if ( state->len >= 64 ) return 1;
	}
	return 0; 
} 

