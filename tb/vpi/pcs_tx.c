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

bool get_next_pma(pcs_tx_s *state, ctrl_lite_s ctrl, uint64_t data, uint64_t *pma)
{
	uint8_t err = 0;
	bool gb_full = true;
	bool gb_full_next = true;
	bool marker_v; 
	bool accept;
	#ifdef _40GBASE
	const size_t l = state->lane_idx;
	#else
	const size_t l = 0;
	#endif	
	gb_full &= gearbox_full(state->gearbox_state[l]);

	marker_v = is_alignement_marker(state->marker_state);
	
	accept = !( gb_full || marker_v );
	info("[%ld] accpet %d full %d marker %d\n",l, accept, gb_full, marker_v);

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
		#ifdef _40GBASE
		// alignment marker
		alignement_marker(&state->marker_state, state->lane_idx, state->block_scram, state->block_mark ); 
		info("Marker in x%016lx out x%016lx\n", state->block_scram.data,state->block_mark[l].data);
		#endif
	}
	// gearbox 
	#ifdef _40GBASE
	if(!gb_full) state->lane_idx = (state->lane_idx+1) % LANE_N;
	gb_full_next &= gearbox(&state->gearbox_state[l], state->block_mark[l], pma);
	info("Gearbox in x%016lx out x%016lx\n", state->block_mark[l].data, pma[l]);
	#else
	gb_full_next = gearbox(&state->gearbox_state[l], state->block_scram[l], pma);
	#endif
	if ( gb_full && ( gb_full_next == gb_full )){
		fprintf(stderr, "Error, full state next should not match current state q %d next %d\n",
			gb_full, gb_full_next);
		assert(0);
		
	}

	return accept;	
}

