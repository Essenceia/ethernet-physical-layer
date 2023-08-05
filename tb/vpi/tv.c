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

tv_t * tv_alloc(){
	tv_t *tv;
	tv = (tv_t *) malloc( sizeof(tv_t));
	// init rand
	tb_rand_init(RAND_SEED);
	// init fifo
	tv->fifo = tb_pma_fifo_alloc();
	// init values
	tv->len = 0;
	tv->rd_idx = 0;
	tv->packet = NULL;
	tv->idle_cntdown = 0;
	tv->tx = pcs_tx_init();
	tv->debug_id = 0; 
	return tv; 
}

void tv_create_packet(tv_t *t ){
	uint64_t data;
	long int idle;
	long int len; 
	bool accept;	
	ctrl_lite_s ctrl;
	
	t->idle_cntdown = tb_rand_packet_idle_cntdown();
	// fill packet with real random data
	t->len = tb_rand_get_packet_len();
	t->rd_idx = 0;
	t->packet = (t->packet) ?
		realloc(t->packet, sizeof(uint8_t) * t->len) : 
		malloc(sizeof(uint8_t) * t->len);
	tb_rand_fill_packet(t->packet, t->len);

	// create expected result
	memset(&ctrl, 0, sizeof(ctrl_lite_s)); 
	idle = (long int) t->idle_cntdown;
	ctrl.ctrl_v = 1;
	ctrl.idle_v = 1;
	do{
		// idle frames
		uint64_t *pma = malloc(sizeof(uint64_t));
		accept = get_next_pma(t->tx, ctrl, 0, pma);
		if ( accept ) idle--;
		info("Idle %ld accept %d\n", idle, accept);
		// add to fifo 
		t->debug_id ++; 
		tb_pma_fifo_push(t->fifo, pma, t->debug_id);
	}while(idle);
	memset(&ctrl, 0, sizeof(ctrl_lite_s));	
	len = (long int) t->len; 
	// start
	ctrl.ctrl_v = 1;
	ctrl.start_v[0] = 1;
	data = 0;
	for(size_t i=1; i< TXD_W; i++){
		data =  data  |  (((uint64_t) t->packet[i-1])<< i*8 );  
	}
	do {
		uint64_t *pma = malloc(sizeof(uint64_t));
		accept = get_next_pma(t->tx, ctrl, data, pma);
		t->debug_id ++; 
		tb_pma_fifo_push(t->fifo, pma, t->debug_id);
	} while (!accept);

	len -= TXD_W-1;
	while( len >= (long int) (t->len % (TXD_W-1))){
		memset(&ctrl, 0, sizeof(ctrl_lite_s));	
		data = 0;
		for(size_t i=1; i< TXD_W; i++){
			data =  data  |  (((uint64_t) t->packet[i-1])<< i*8 );  
		}
		uint64_t *pma = malloc(sizeof(uint64_t));
		accept = get_next_pma(t->tx, ctrl, data, pma);
		t->debug_id ++; 
		tb_pma_fifo_push(t->fifo, pma, t->debug_id);
		if ( accept ){ 
			len -= TXD_W;
			info("len %ld\n", len);
		}
	}
	// terminate
	memset(&ctrl, 0, sizeof(ctrl_lite_s));	
	ctrl.ctrl_v = 1;
	ctrl.term_v = 1;
	LEN_TO_KEEP(len, ctrl.term_keep);
	data = 0;
	for(size_t i=1; i< TXD_W; i++){
		data =  data  |  (((uint64_t) t->packet[i-1])<< i*8 );  
	}

	do {
		uint64_t *pma = malloc(sizeof(uint64_t));
		accept = get_next_pma(t->tx,  ctrl, data, pma);
		t->debug_id ++; 
		tb_pma_fifo_push(t->fifo, pma, t->debug_id);
	} while (!accept);

	#ifdef DEBUG
	tb_pma_print_fifo(t->fifo);
	#endif	
}

void tv_get_next_txd(
	tv_t* t,
	ctrl_lite_s *ctrl, 
	uint8_t *tx
)
{
	assert(TXD_W < 9 );// not supported yet
	memset(ctrl, 0, sizeof(ctrl_lite_s));
	info("TXD :\nidle countdown %ld\nrd_idx/len %ld/%ld\n",
		t->idle_cntdown, t->rd_idx, t->len);
	if ( t->idle_cntdown ){
		t->idle_cntdown--;
		// write ctrl
		ctrl->ctrl_v = 1;
		ctrl->idle_v = 1;
	} else {
		size_t left;
		left = t->len - t->rd_idx;	
		if ( t->rd_idx == 0 ){
			// start : this the first packet
			ctrl->ctrl_v = 1;
			ctrl->start_v[0] = 1;
			for(size_t i=0; i < TXD_W-1; i++){
				tx[i+1] = t->packet[i];
			}
			t->rd_idx += TXD_W-1;
		}else if ( left < 8 ){
			// term : this is the last packert 
			ctrl->ctrl_v = 1;
			ctrl->term_v = 1;
			LEN_TO_KEEP(left, ctrl->term_keep);
			for(size_t i=0; i<left; i++){
				tx[i+1] = t->packet[i];	
			}
			t->rd_idx += TXD_W-1;	
	
		}else{
			// normal packet
			for(size_t i=0; i<TXD_W; i++){
				tx[i] = t->packet[i];
			}
			t->rd_idx += TXD_W;	
		}
	}
}


// check if we still have data to send
bool tv_txd_has_data(tv_t* t){
	return ( t->len > t->rd_idx ) || ( t->idle_cntdown > 0);
}

void tv_free(tv_t * t)
{
	tb_pma_fifo_free(t->fifo);
	free(t->tx);
	free(t->packet);
	free(t);
}
