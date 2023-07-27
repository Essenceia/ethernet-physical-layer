#include "pcs_gearbox.h"

uint8_t gearbox( gearbox_s * state, block_s block, uint64_t *pma ){
	if ( state->len >= 64 ){
		// buffer is full : purge
		state->buff = state->buff >> 64; 
		*pma = ( uint64_t ) state->buff & 0xFFFFFFFF;
		state->len = 0;		
	}else{
		// buffer is not full : add
		state->buff << 64; // make way for new data
		state->buff = ( state->buff & 0xFFFFFFFF00000000 ) | ( ~0xFFFFFFFF00000000 & (uint128_t)block->data );
		state->buff << 2; // make way for head
		state->buff = ( state->buff & 0xFFFFFFFFFFFFFFFC ) | ( ~0xFFFFFFFFFFFFFFFC & (uint128_t)block->head );
		*pma = ( uint64_t ) state->buff & 0xFFFFFFFF;
		state->buff = state->buff >> 64; 
		state->len += 2;
		if ( state->len >= 64 ) return 1;
	}
	return 0; 
} 

