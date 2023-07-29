#include "pcs_tx.h"
#include "64b66b.h"
#include "pcs_enc.h"
#include "pcs_gearbox.h"
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
	for( int i=0; i < LANE_N; i++) s->scrambler_state[i] = UINT64_MAX;
	return s; 
}

bool get_next_64b(pcs_tx_s *state, size_t lane, ctrl_lite_s ctrl, uint64_t data, uint64_t *pma)
{
	uint8_t err = 0;
	bool gb_full;
	bool gb_full_next;
	gb_full = gearbox_full(state->gearbox_state[lane]);
	
	if ( !gb_full ){
	// enc
	err = enc_block(ctrl, data, &(state->block_enc[lane]));
	info("ENC : head x%01x, data x%016lx\n", state->block_enc[lane].head,state->block_enc[lane].data); 
	if ( err != 0 ){
		fprintf(stderr, "Error in encoding\n");
		assert(0); // die with coredump
	}
	//scramble
	state->block_scram[lane].data = scramble(&state->scrambler_state[lane], state->block_enc[lane].data, 64);
	state->block_scram[lane].head = state->block_enc[lane].head;
	info("scr data x%016lx\n", state->block_scram[lane].data);
	}
	// gearbox 
	gb_full_next = gearbox(&state->gearbox_state[lane], state->block_scram[lane], pma);
	if ( gb_full && ( gb_full_next == gb_full )){
		fprintf(stderr, "Error, full state next should not match current state q %d next %d\n",
			gb_full, gb_full_next);
		assert(0);
		
	}

	return !gb_full;	
}

