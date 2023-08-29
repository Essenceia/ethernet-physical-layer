/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "tv.h"
#include "tb_rand.h"
#include "defs.h"

tv_t  *tv_alloc(){
	tv_t *tv;
	info("tv alloc");
	tv = (tv_t *) malloc( sizeof(tv_t));
	// init fifo
	for( size_t l = 0; l < LANE_N; l ++ ){
		tv->pma[l]  = tb_pma_fifo_ctor();
		tv->data[l] = tb_pma_fifo_ctor();
	}
	// init values
	tv->len = 0;
	//tv->rd_idx = 0;
	//tv->packet = NULL;
	tv->idle_cntdown = 0;
	tv->debug_id = 0;
	tv->tx = pcs_tx_init();
	return tv; 
}
size_t add_to_fifo(tv_t *t, const ready_s ready, size_t idx, uint64_t *data, ctrl_lite_s *ctrl, uint64_t *pma){
	size_t lane_idx = IDX_TO_LANE(idx++);
	t->debug_id ++;
	info("\n\ndata ptr %016lx, lane %ld\n", (int64_t) data, lane_idx); 
	if(!ready.gb_full)tb_pma_fifo_push(t->data[lane_idx], data, ctrl, t->debug_id);
	tb_pma_fifo_push(t->pma[lane_idx], pma, NULL, t->debug_id);
	return idx;
}

void tv_create_packet(tv_t *t, const int start_lane ){
	long int idle;
	ready_s ready;	
	ctrl_lite_s *ctrl;
	size_t idx;
	uint8_t *tmp_data;
	size_t  data_idx = 0;

	info("create packet\n");

	t->idle_cntdown = tb_rand_packet_idle_cntdown();

	idx = (size_t) start_lane;	
	// fill packet with real random data
	t->len = tb_rand_get_packet_len();
	tmp_data = (uint8_t*) malloc(sizeof(uint8_t)*t->len);
	tb_rand_fill_packet(tmp_data, t->len);

	// create expected result
	memset(&ctrl, 0, sizeof(ctrl_lite_s)); 
	idle = (long int) t->idle_cntdown;

	do{
		// idle frames
		ctrl = malloc( sizeof(ctrl_lite_s));
		memset(ctrl, 0, sizeof(ctrl_lite_s));
		ctrl->ctrl_v = 1;
		ctrl->idle_v = 1;
		uint64_t *data = malloc(sizeof(uint64_t));
		uint64_t *pma = malloc(sizeof(uint64_t));
		data[0] = 0;	
		
		ready = get_next_pma(t->tx, *ctrl, *data, pma);
		if ( is_accept(ready) ) idle--;
		info("Idle %ld accept %d\n", idle, is_accept(ready));
		// add to fifo
		idx = add_to_fifo(t, ready, idx, data, ctrl, pma ); 
	}while(idle);
	// start
	{	
		ctrl = malloc(sizeof(ctrl_lite_s));
		memset(ctrl, 0, sizeof(ctrl_lite_s));
		ctrl->ctrl_v = 1;
		ctrl->start_v[0] = 1;
		uint64_t *data = malloc(sizeof(uint64_t));
		*data = 0;
		for(size_t i=1; i< TXD_W; i++, data_idx++){
			*data |=  (uint64_t) tmp_data[data_idx] << i*8 ;
		}  
		do {
			uint64_t *pma = malloc(sizeof(uint64_t));
			ready = get_next_pma(t->tx, *ctrl, *data, pma);
			idx = add_to_fifo(t, ready, idx, data, ctrl, pma); 
		} while (!is_accept(ready));
	}

	while(  t->len - data_idx > (TXD_W-1)){
		ctrl = malloc(sizeof(ctrl_lite_s));
		memset(ctrl, 0, sizeof(ctrl_lite_s));
		uint64_t *data = malloc(sizeof(uint64_t));
		*data = 0;
		for(size_t i=0; i< TXD_W; i++){
			*data =  *data  |  (((uint64_t) tmp_data[data_idx+i])<< i*8 );  
		}
		uint64_t *pma = malloc(sizeof(uint64_t));
		ready = get_next_pma(t->tx, *ctrl, *data, pma);
		idx = add_to_fifo(t, ready, idx, data, ctrl, pma);
		if ( is_accept(ready)){ 
			data_idx += TXD_W;
			info("idx %ld\n", idx);
		}else{
			info("data rejected idx %ld\n", idx);
		}
	}
	// terminate
	{
		ctrl = malloc(sizeof(ctrl_lite_s));
		memset(ctrl, 0, sizeof(ctrl_lite_s));	
		ctrl->ctrl_v = 1;
		ctrl->term_v = 1;
		LEN_TO_KEEP((t->len-data_idx), ctrl->term_keep);
		uint64_t *data = malloc(sizeof(uint64_t));
		*data = 0;
		for(size_t i=1; i< TXD_W && data_idx < t->len; i++, data_idx++){
			*data =  *data  |  (((uint64_t) tmp_data[data_idx])<< i*8 );  
		}
	
		do {
			uint64_t *pma = malloc(sizeof(uint64_t));
			ready = get_next_pma(t->tx,  *ctrl,*data, pma);
			idx = add_to_fifo(t, ready, idx, data, ctrl, pma);
		} while (!is_accept(ready));
	}
	#ifdef DEBUG
	info("FIFO\ndata \n");
	for(size_t l=0; l<LANE_N; l++)
		tb_pma_print_fifo(t->data[l]);
	info("pma \n");
	for(size_t l=0; l<LANE_N; l++)
		tb_pma_print_fifo(t->pma[l]);
	#endif
	free(tmp_data);	
}

bool tv_get_next_txd(
	tv_t *t,
	ctrl_lite_s **ctrlp, 
	uint64_t **datap,
	uint64_t *debug_idp,
	const int lane
)
{
	assert(TXD_W < 9 );// not supported yet
	uint64_t *data = *datap = tb_pma_fifo_pop(t->data[lane], debug_idp, ctrlp);	
	if (data != NULL){
		info("data : %016lx debug_id %016lx\n", *data, *debug_idp);
		return true;
	} else{
		return false;	
	}
}


// check if we still have data to send
/*bool tv_txd_has_data(tv_t *t, const int lane){
	return ;
}*/

void tv_free(tv_t  *t)
{
	for(int i=0; i< LANE_N; i++){
		tb_pma_fifo_dtor(t->data[i]);
		tb_pma_fifo_dtor(t->pma[i]);
	}
	free(t->tx);
	//free(t->packet);
	free(t);
}
