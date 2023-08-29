#include "pcs_tx.h"
#include "64b66b.h"
#include "pcs_enc.h"
#include "pcs_gearbox.h"

#ifdef _40GBASE
#include "pcs_marker.h"
#endif

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "defs.h"
pcs_tx_s  *pcs_tx_init(){
	pcs_tx_s * s;
	// alloc	
	s = (pcs_tx_s*) malloc( sizeof( pcs_tx_s));
	// init
	memset( s, 0, sizeof( pcs_tx_s));
	s->scrambler_state = UINT64_MAX;
	return s; 
}

bool get_next_exp(pcs_tx_s *state, const ctrl_lite_s ctrl, block_s* b_data, block_s *block)
{
	uint8_t err = 0;
	bool gb_full_next = true;
	bool accept;
	#ifdef _40GBASE
	const size_t l = state->lane_idx;
	#else
	const size_t l = 0;
	#endif	
	uint64_t data = b_data->data;

	#ifdef _40GBASE
	accept = !is_alignement_marker(state->marker_state);
	#else
	accept = true;
	#endif
	
	
	info("[%ld] accept %d marker %d\n",l, accept, !accept);
	info("raw data %016lx\n", data);	
	// if gearbox is full next block will not be accpted anyways
	// so there is no need to compute the expected result	
	if ( accept ){
		// enc
			err = enc_block(ctrl, data, &(state->block_enc));
			info("ENC : head x%01x, data x%016lx\n", state->block_enc.head,state->block_enc.data); 
			if ( err != 0 ){
				fprintf(stderr, "Error in encoding\n");
				assert(0); // die with coredump
			}
			//scramble
			//skip scrambler on gearbox pause
			state->block_scram.data = scramble(&state->scrambler_state, state->block_enc.data, 64);
			state->block_scram.head = state->block_enc.head;
			info("Scramm in x%016lx out x%016lx\n", state->block_enc.data, state->block_scram.data);
	}
	#ifdef _40GBASE
	// alignment marker
	alignement_marker(&state->marker_state, state->lane_idx, state->block_scram, &state->block_mark[l] ); 
	info("Marker in x%016lx out x%016lx\n", state->block_scram.data,state->block_mark[l].data);

	// set output block data
	block->data = state->block_mark[l].data;
	block->head = state->block_mark[l].head;
	info("exp, mark { %016lx, %01x }\n", block->data, 0x3 & block->head );
	state->lane_idx = (state->lane_idx+1) % LANE_N;
	
	#else
	
	block->data = state->block_scram.data;
	block->head = state->block_scram.head;
	info("exp, scram { %016lx, %01x }\n", block->data, 0x3 & block->head );
	
	#endif // _40GBASE
	
	
	return accept;	
}

