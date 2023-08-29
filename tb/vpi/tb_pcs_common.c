/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#include "tv.h"
#include "defs.h"
#include "tb_pcs_common.h"
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include "tb_utils.h"

#define FLATTEN_1b(ctrl, elem) \
	elem = 0;\
	for(int i=0; i<LANE_N; i++){\
		elem |= ( (*ctrl[i]).elem << i ); \
	} 

#define FLATTEN_START_Wb(ctrl, elem) \
	elem = 0;\
	for(int i=0; i<LANE_N; i++){\
		for(int w=0; w<START_W; w++){\
			elem |= ( (*ctrl[i]).elem[w] << (i*START_W+w) ); \
		}\
	} 


/* If we add more lanes we may need to update the type
 * used to store the keep array, add an assert to remind
 * myself of this. */
#define FLATTEN_8b(ctrl, elem) \
	elem = 0;\
	assert(sizeof(elem) >= LANE_N);\
	for(int i=0; i<LANE_N; i++){\
		info("lane %d 8b %02x\n",i,(*ctrl[i]).elem);\
		elem |= ( (*ctrl[i]).elem << (i*8) ); \
	}\
 	info("flat %08x\n",elem);


void tb_pcs_get_tx_lane(
	tv_t *tv_s,
	int lane,
	ctrl_lite_s **ctrl,
	block_s **data,
	uint64_t *debug_id
){
	bool has_data;

	// get ctrl and data to drive tx pcs
	do{
		has_data = tv_get_next_txd(tv_s, ctrl, data, debug_id, lane);
		if (!has_data) tv_create_packet(tv_s, lane);
	}while(!has_data);
	assert(ctrl);
	assert(data);
	assert(debug_id);
	info("tb xgmii data %016lx\n", (*data)->data);
}

void tb_pcs_set_data(
	ctrl_lite_s *ctrl[LANE_N],
	block_s *data[LANE_N],
	uint64_t debug_id[LANE_N],
	vpiHandle h_ready_o,
	vpiHandle h_ctrl_v_i,
	vpiHandle h_idle_v_i,
	vpiHandle h_start_v_i,
	vpiHandle h_term_v_i,
	vpiHandle h_term_keep_i,
	vpiHandle h_err_v_i,
	vpiHandle h_data_i,
	vpiHandle h_debug_id_i
){
	/* write ctrl */
	uint8_t ctrl_v;
	uint8_t idle_v;
	uint8_t start_v;
	uint8_t term_v;
	uint32_t term_keep;
	uint8_t err_v;
	/* flatten data */
	FLATTEN_1b(ctrl,ctrl_v);
	FLATTEN_1b(ctrl,idle_v);
	FLATTEN_START_Wb(ctrl,start_v);
	FLATTEN_1b(ctrl,term_v);
	FLATTEN_8b(ctrl,term_keep);
	FLATTEN_1b(ctrl,err_v);

	info("term keep %08x\n",term_keep);
	/* write */
	tb_vpi_put_logic_uint8_t(h_ctrl_v_i, ctrl_v);
	tb_vpi_put_logic_uint8_t(h_idle_v_i, idle_v);
	tb_vpi_put_logic_uint8_t(h_start_v_i, start_v);
	tb_vpi_put_logic_uint8_t(h_term_v_i, term_v);
	tb_vpi_put_logic_uint32_t(h_term_keep_i, term_keep);
	tb_vpi_put_logic_uint8_t(h_err_v_i, err_v);

	/* data */
	uint64_t data_flat[LANE_N];
	for(int l=0; l<LANE_N;l++){
		data_flat[l] = data[l]->data;
	}	
	tb_vpi_put_logic_uint64_t_var_arr(h_data_i, data_flat, LANE_N);
	tb_vpi_put_logic_uint64_t_var_arr(h_debug_id_i, debug_id, LANE_N);

	#ifdef DEBUG
	info("Tx pcs data {");
	for(int i=LANE_N-1; i>-1; i--){
		info(" %lx,",data_flat[i]);
	}
	info("}\n");
	#endif
}


// Drive PCS input values
void tb_pcs_tx(
	tv_t *tv_s,	
	vpiHandle h_ready_o,
	vpiHandle h_ctrl_v_i,
	vpiHandle h_idle_v_i,
	vpiHandle h_start_v_i,
	vpiHandle h_term_v_i,
	vpiHandle h_term_keep_i,
	vpiHandle h_err_v_i,
	vpiHandle h_data_i,
	vpiHandle h_debug_id_i
)
{
	int 	ready;

	// aserts	
	assert(h_ready_o);
	assert(h_ctrl_v_i);
	assert(h_idle_v_i);
	assert(h_start_v_i);
	assert(h_term_v_i);
	assert(h_term_keep_i);
	assert(h_err_v_i);
	assert(h_data_i);
	assert(h_debug_id_i);
	
	// get value of ready
	s_vpi_value ready_val;
	
	ready_val.format = vpiIntVal;
	vpi_get_value(h_ready_o, &ready_val);
	ready = ready_val.value.integer;		
	info("$tb ready %d\n", ready);

	if(ready){
		info("tb tx getting next data\n");
		ctrl_lite_s *ctrl[LANE_N];
		block_s *data[LANE_N];
		uint64_t debug_id[LANE_N];

		for(int l=0; l<LANE_N; l++){

			tb_pcs_get_tx_lane( tv_s,l,
				&ctrl[l], &data[l], &debug_id[l]);
		}
		// write data
		tb_pcs_set_data(ctrl, 
			data, 
			debug_id,
			h_ready_o, 
			h_ctrl_v_i, 
			h_idle_v_i,
			h_start_v_i, 
			h_term_v_i, 
			h_term_keep_i,
			h_err_v_i, 
			h_data_i, 
			h_debug_id_i);
		for(int l=0; l<LANE_N; l++){
			free(ctrl[l]);
			free(data[l]);
		}
	}

}


void tb_pcs_get_exp_lane(
	tv_t *tv_s,
	int lane,
	block_s **block,
	uint64_t *debug_id
){
	assert((lane < LANE_N) && ( lane > -1 )); 
	ctrl_lite_s *ctrl;
	// if the end of the fifo collides with a cycle the pcs
	// doesn't accept a new data we much call creat packet
	do{
		*block = tb_data_fifo_pop( tv_s->block[lane], debug_id, &ctrl);
		if(*block==NULL) tv_create_packet(tv_s, lane);
	}while(*block == NULL);
	assert(ctrl==NULL);
	info("tb gb data { %016lx, %01x }\n",(*block)->data, (*block)->head);	
}

void tb_pcs_set_exp_data(
	block_s *block[LANE_N],
	uint64_t debug_id[LANE_N],
	vpiHandle h_block_o,
	vpiHandle h_debug_id_o		
){
	// block data of 66 bits is flattened into an array of uint 64
	size_t len = (LANE_N*66+63)/64;
	size_t idx = 0;
	uint64_t *block_flat = malloc(sizeof(uint64_t)*len);
	memset(block_flat, 0, sizeof(uint64_t)*len );
	for(size_t l=0; l<LANE_N; l++){
		assert(block[l]);
		// head
		info("head to flatten %01x\n", block[l]->head);
		for(size_t i=0; i < 2; i++){
			uint64_t h = 1u & (block[l]->head >> i);
			size_t shift = (idx+i)%64;
			size_t flat_idx = (i+idx)/64;
			//info("h %x i %ld flat idx %ld shift %ld\n", h, i, flat_idx, shift); 
			block_flat[flat_idx] |= h << shift; 
		}
		idx += 2;
		// data 
		info("data to flatten %016lx\n", block[l]->data);
		for(size_t i=0; i < 64; i++){
			uint64_t d =((uint64_t)0x1) & (block[l]->data >> i);
			size_t shift = (idx+i)%64;
			size_t flat_idx = (i+idx)/64;
			//info("d %x flat idx %ld shift %ld\n", d, flat_idx, shift); 
			block_flat[flat_idx] |= d << shift; 
		}
		idx += 64;
	}
	#ifdef DEBUG
	info("tb gb block flat : {");
	for(int i=len-1; i>-1; i--){
		info(" %016lx", block_flat[i]);
	}
	info("\n");
	#endif

	tb_vpi_put_logic_uint64_t_var_arr(h_block_o, block_flat, len);
	// debug id
	tb_vpi_put_logic_uint64_t_var_arr(h_debug_id_o, debug_id, LANE_N);
}

/* Produce the expected output of the PCS and write it
 * to signals passed as parameter  */
void tb_pcs_tx_exp(
	tv_t *tv_s,
	vpiHandle h_block_o,
	vpiHandle h_debug_id_o
){
	assert(h_block_o);
	assert(h_debug_id_o);
	
	// pop fifo
	block_s *block[LANE_N];
	uint64_t debug_id[LANE_N];

	for(int l=0; l < LANE_N; l++){
		tb_pcs_get_exp_lane(tv_s, l, &block[l], &debug_id[l]);
		assert(block[l]);
	}
	tb_pcs_set_exp_data(block, debug_id, h_block_o, h_debug_id_o);
	for(int l=0; l< LANE_N; l++){
		free(block[l]);
	}
}

