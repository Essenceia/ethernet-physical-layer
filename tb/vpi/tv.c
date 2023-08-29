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
		tv->block[l]  = tb_data_fifo_ctor();
		tv->data[l] = tb_data_fifo_ctor();
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
size_t add_to_fifo(
	tv_t *t, 
	const bool accept, 
	size_t idx, 
	block_s *data, 
	ctrl_lite_s *ctrl, 
	block_s *block
){
	size_t lane_idx = IDX_TO_LANE(idx++);
	t->debug_id ++;
	info("\n\ndata ptr %016lx, lane %ld\n",
		 (int64_t) data, lane_idx); 
	if(accept) {
		tb_data_fifo_push(
			t->data[lane_idx],
			data, 
			ctrl, 
			t->debug_id);
	}
	tb_data_fifo_push(
		t->block[lane_idx], 
		block, 
		NULL, 
		t->debug_id);
	return idx;
}

void tv_create_packet(tv_t *t, const int start_lane ){
	long int idle;
	ctrl_lite_s *ctrl;
	size_t idx;
	uint8_t *tmp_data;
	size_t  data_idx = 0;
	bool accept;

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
		block_s *data = malloc(sizeof(block_s));
		block_s *exp = malloc(sizeof(block_s));
		data->data = 0;	
		
		accept = get_next_exp(t->tx, *ctrl, data, exp);
		if (accept) idle--;
		info("Idle %ld accept %d\n", idle,accept);
		// add to fifo
		idx = add_to_fifo(t, accept, idx, data, ctrl, exp ); 
	}while(idle);
	// start
	{	
		ctrl = malloc(sizeof(ctrl_lite_s));
		memset(ctrl, 0, sizeof(ctrl_lite_s));
		ctrl->ctrl_v = 1;
		ctrl->start_v[0] = 1;
		block_s *data = malloc(sizeof(ctrl_lite_s));
		data->data = 0;
		for(size_t i=1; i< TXD_W; i++, data_idx++){
			data->data |=  (uint64_t) tmp_data[data_idx] << i*8 ;
		}  
		do {
			block_s *exp = malloc(sizeof(block_s));
			accept = get_next_exp(t->tx, *ctrl, data, exp);
			idx = add_to_fifo(t, accept, idx, data, ctrl, exp); 
		} while (!accept);
	}

	while(  t->len - data_idx > (TXD_W-1)){
		ctrl = malloc(sizeof(ctrl_lite_s));
		memset(ctrl, 0, sizeof(ctrl_lite_s));
		block_s *data = malloc(sizeof(block_s));
		data->data = 0;
		for(size_t i=0; i< TXD_W; i++){
			data->data =  data->data  |  (((uint64_t) tmp_data[data_idx+i])<< i*8 );  
		}
		block_s *exp = malloc(sizeof(block_s));
		accept = get_next_exp(t->tx, *ctrl, data, exp);
		idx = add_to_fifo(t, accept, idx, data, ctrl, exp);
		if (accept){ 
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
		block_s *data = malloc(sizeof(block_s));
		data->data = 0;
		for(size_t i=1; i< TXD_W && data_idx < t->len; i++, data_idx++){
			data->data =  data->data  |  (((uint64_t) tmp_data[data_idx])<< i*8 );  
		}
	
		do {
			block_s *exp = malloc(sizeof(block_s));
			accept = get_next_exp(t->tx,  *ctrl, data, exp);
			idx = add_to_fifo(t, accept, idx, data, ctrl, exp);
		} while (!accept);
	}
	#ifdef DEBUG
	info("FIFO\ndata \n");
	for(size_t l=0; l<LANE_N; l++)
		tb_data_print_fifo(t->data[l]);
	info("exp \n");
	for(size_t l=0; l<LANE_N; l++)
		tb_data_print_fifo(t->block[l]);
	#endif
	free(tmp_data);	
}

bool tv_get_next_txd(
	tv_t *t,
	ctrl_lite_s **ctrlp, 
	block_s **datap,
	uint64_t *debug_idp,
	const int lane
)
{
	assert(TXD_W < 9 );// not supported yet
	block_s *data = *datap = tb_data_fifo_pop(t->data[lane], debug_idp, ctrlp);	
	if (data != NULL){
		info("data : %016lx debug_id %016lx\n", data->data, *debug_idp);
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
		tb_data_fifo_dtor(t->data[i]);
		tb_data_fifo_dtor(t->block[i]);
	}
	free(t->tx);
	//free(t->packet);
	free(t);
}
