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


#define FLATTEN_8b(ctrl, elem) \
	elem = 0;\
	info("sizeof(elem) %ld\n",sizeof(elem));\
	//assert(sizeof(elem) >= LANE_N*8);\
	for(int i=0; i<LANE_N; i++){\
		elem |= ( (*ctrl[i]).elem << (i*8) ); \
	} 


void tb_pcs_get_tx_lane(
	tv_t *tv_s,
	int lane,
	ctrl_lite_s **ctrl,
	uint64_t **data,
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
	info("tv data %016lx\n", **data);
}

void tb_pcs_set_data(
	ctrl_lite_s *ctrl[LANE_N],
	uint64_t *data[LANE_N],
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
	uint32_t ctrl_v;
	uint32_t idle_v;
	uint32_t start_v;
	uint32_t term_v;
	uint32_t term_keep;
	uint32_t err_v;
	/* flatten data */
	FLATTEN_1b(ctrl,ctrl_v);
	FLATTEN_1b(ctrl,idle_v);
	FLATTEN_START_Wb(ctrl,start_v);
	FLATTEN_1b(ctrl,term_v);
	FLATTEN_8b(ctrl,term_keep);
	FLATTEN_1b(ctrl,err_v);
	/* write */
	tb_vpi_put_logic_uint32_t(h_ctrl_v_i, ctrl_v);
	tb_vpi_put_logic_uint32_t(h_idle_v_i, idle_v);
	tb_vpi_put_logic_uint32_t(h_start_v_i, start_v);
	tb_vpi_put_logic_uint32_t(h_term_v_i, term_v);
	tb_vpi_put_logic_uint32_t(h_term_keep_i, term_keep);
	tb_vpi_put_logic_uint32_t(h_err_v_i, err_v);

	/* data */
	uint64_t data_flat[LANE_N];
	for(int l=0; l<LANE_N;l++){
		data_flat[l] = *data[l];
	}	
	tb_vpi_put_logic_uint64_t_var_arr(h_data_i, data_flat, LANE_N);
	tb_vpi_put_logic_uint64_t_var_arr(h_debug_id_i, debug_id, LANE_N);

	#ifdef DEBUG
	info("Tx pcs data {");
	for(int i=0; i<LANE_N; i++){
		info(" %lx,",**data[i]);
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

	// create a new packet if none exist
	info("Getting next txd");


	if(ready){
		ctrl_lite_s *ctrl[LANE_N];
		uint64_t *data[LANE_N];
		uint64_t debug_id[LANE_N];

		for(int l=0; l<LANE_N; l++){

			tb_pcs_get_tx_lane( tv_s,l,
				&ctrl[l], &data[l], &debug_id[l]);
		}
		// write data
		tb_pcs_set_data(ctrl, data, debug_id,
			h_ready_o, h_ctrl_v_i, h_idle_v_i,
			h_start_v_i, h_term_v_i, h_term_keep_i,
			h_err_v_i, h_data_i, h_debug_id_i);
		for(int l=0; l<LANE_N; l++){
			free(ctrl[l]);
			free(data[l]);
		}
	}

}


void tb_pcs_exp_get_lane(
	tv_t *tv_s,
	int lane,
	uint64_t *pma,
	uint64_t *debug_id
){
	assert((lane < LANE_N) && ( lane > -1 )); 
	ctrl_lite_s *ctrl;
	// if the end of the fifo collides with a cycle the pcs
	// doesn't accept a new data we much call creat packet
	do{
		pma = tb_pma_fifo_pop( tv_s->pma[lane], debug_id, &ctrl);
		if(pma==NULL) tv_create_packet(tv_s, lane);
	}while(pma == NULL);
	assert(ctrl == NULL); // there is no crtl on pma
	
}

void tb_pcs_exp_set_data(
	uint64_t pma[LANE_N],
	uint64_t debug_id[LANE_N],
	vpiHandle h_pma_o,
	vpiHandle h_debug_id_o		
){
	// pma
	tb_vpi_put_logic_uint64_t_var_arr(h_pma_o, pma, LANE_N);
	// debug id
	tb_vpi_put_logic_uint64_t_var_arr(h_debug_id_o, debug_id, LANE_N);
}

/* Produce the expected output of the PCS and write it
 * to signals passed as parameter  */
void tb_pcs_tx_exp(
	tv_t *tv_s,
	vpiHandle h_pma_o,
	vpiHandle h_debug_id_o
){
	assert(h_pma_o);
	assert(h_debug_id_o);
	
	// pop fifo
	uint64_t pma[LANE_N];
	uint64_t debug_id[LANE_N];

	for(int l=0; l < LANE_N; l++){
		tb_pcs_exp_get_lane(tv_s, l, &pma[l], &debug_id[l]);
	}
	tb_pcs_exp_set_data(pma, debug_id, h_pma_o, h_debug_id_o);
}

