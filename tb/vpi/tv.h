#ifndef TV_H
#define TV_H

#include <stdio.h>
#include "pcs_tx.h"
#include "tb_fifo.h"

#define IDX_TO_LANE(x) ( x % LANE_N )
typedef struct{
	// tx channel
	pcs_tx_s *tx;
	// fifo
	tv_pma_fifo_t *pma[LANE_N]; 
	tv_pma_fifo_t *data[LANE_N];
	// next packet to send
	size_t   len;
	//size_t   rd_idx;
	//size_t   lane_idx;
	size_t  debug_id;
	// idle count down
	size_t  idle_cntdown;
}tv_t;

tv_t * tv_alloc();

void tv_create_packet(tv_t * t, const int start_lane);

bool tv_get_next_txd(
	tv_t* t, 
	ctrl_lite_s **ctrl, 
	uint64_t **data,
	uint64_t *debug_id, 
	const int lane);

//bool tv_txd_has_data(tv_t* t);

void tv_free(tv_t * t);

#endif // TV_H
