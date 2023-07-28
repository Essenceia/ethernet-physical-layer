#ifndef TV_H
#define TV_H

#include <stdio.h>
#include "pcs_tx.h"
#include "tb_fifo.h"

typedef struct{
	// tx channel
	pcs_tx_s *tx;
	// fifo
	tv_pma_fifo_t *fifo; 
	// next packet to send
	size_t   len;
	size_t   rd_idx;
	uint8_t *packet;
	// idle count down
	size_t  idle_cntdown;
	// debug id
	uint64_t debug_id;
}tv_t;

tv_t * tv_alloc();

void tv_create_packet(tv_t * t);

void tv_get_next_txd(tv_t* t, ctrl_lite_s *ctrl, uint8_t *tx);

bool tv_txd_has_data(tv_t* t);

void tv_free(tv_t * t);

#endif // TV_H
