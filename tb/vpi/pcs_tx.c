#include "pcs_tx.h"

pcs_tx_s  *pcs_tx_init(){
	pcs_tx_s * s;
	// alloc	
	s = (pcs_tx_s*) malloc( sizeof( pcs_tx_s));
	// init
	for( int i=0; i < LANE_N; i++) s->scrambler_state[i] = UINT64_MAX; 
}

uint8_t get_next_64b(pcs_tx_s *state, size_t lane, ctrl_lite_s ctrl, uint64_t data, uint64_t *pma)
{
	uint8_t err = 0;
	bool gb_full;
	bool gb_full_next;
	gb_full = gearbox_full(state->gearbox_state[lane]);
	if ( !gb_full ){
	// enc
	err = enc_block(ctrl, data, &state->block_enc[lane]);
	if ( err != 0 ){
		fprintf(stderr, "Error in encoding\n");
		assert(0); // die with coredump
	}
	//scramble
	state->block_scram[lane]->data = scramble(&state->scrambler_state[lane], state->block_enc[lane]->data, 64);
	state->block_scram[lane]->head = state->block_enc[lane]->head;
	}
	// gearbox 
	gb_full_next = gearbox(&state->gearbox_state[lane], stata->block_scram[lane], pma);
	assert( gb_full_next != gb_full );

	return gb_full;	
}

