/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#include "tv.h"
#include "defs.h"
#include "tb.h"
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include "tb_utils.h"

// Drive PCS input values
int tb_pcs_tx(
	tv_t *tv_s,
	int lane, 

	vpiHandle h_ready_o,
	vpiHandle h_ctrl_v_i,
	vpiHandle h_idle_v_i,
	vpiHandle h_start_v_i,
	vpiHandle h_term_v_i,
	vpiHandle h_term_keep_i,
	vpiHandle h_err_i,
	vpiHandle h_data_i,
	vpiHandle h_debug_id_i
)
{
	int 	ready;

	// aserts	
	assert((lane < LANE_N) && ( lane > -1 )); 
	assert(h_ready_o);
	assert(h_ctrl_v_i);
	assert(h_idle_v_i);
	assert(h_start_v_i);
	assert(h_term_v_i);
	assert(h_term_keep_i);
	assert(h_err_i);
	assert(h_data_i);
	assrt(h_debug_id_i);
	
	// get value of ready
	s_vpi_value ready_val;
	
	ready_val.format = vpiIntVal;
	vpi_get_value(h_ready_o, &ready_val);
	ready = ready_val.value.integer;		
	info("$tb ready %d called on lane %d\n", ready, lane);

	// create a new packet if none exist
	info("Getting next txd");
	
	if (ready) {
		bool has_data;
		uint64_t *data;
		uint64_t debug_id;
		ctrl_lite_s *ctrl;

		// get ctrl and data to drive tx pcs
		do{
			has_data = tv_get_next_txd(tv_s, &ctrl, &data, &debug_id, lane);
			if (!has_data) tv_create_packet(tv_s, lane);
		}while(!has_data);
		info("tv data %016lx\n", *data);
		
		// write signals through vpi interface
		// ctrl
		tb_vpi_put_logic_1b_t(h_ctrl_v_i, ctrl->ctrl_v);
		tb_vpi_put_logic_1b_t(h_idle_v_i, ctrl->idle_v);
		// start 
		uint8_t s = 0;
		for(int l=START_W-1; l>-1 ;l--)
			s= (s<<1) | ctrl->start_v[l]; 
		tb_vpi_put_logic_uint8_t(h_start_v_i, s);
		tb_vpi_put_logic_1b_t(h_term_v_i, ctrl->term_v);
		tb_vpi_put_logic_uint8_t(h_term_keep_i, ctrl->term_keep);
		tb_vpi_put_logic_1b_t(h_err_i, ctrl->err_v);

		// data
		tb_vpi_put_logic_uint64_t(h_data_i, data[0] );
		// debug id
 		tb_vpi_put_logic_uint64_t(h_debug_id_i, debug_id);
		//vpi_free_handle(argv);
		free(data);
		free(ctrl);

	}
	return 0;
}


/* Produce the expected output of the PCS and write it
 * to signals passed as parameter  */
static PLI_INT32 tb_exp_calltf(
	char *user_data
)
{
	vpiHandle sys = vpi_handle(vpiSysTfCall, 0);
	assert(sys);
	vpiHandle argv = vpi_iterate(vpiArgument, sys);
	assert(argv);
		
	// get lane n
	vpiHandle lane_h = vpi_scan(argv);
	assert(lane_h);
	s_vpi_value lane_val;
	lane_val.format = vpiIntVal;
	vpi_get_value(lane_h, &lane_val);	
	int lane = lane_val.value.integer;
	assert((lane < LANE_N) && ( lane > -1 )); 
	
	// pop fifo
	ctrl_lite_s *ctrl;
	uint64_t debug_id;
	uint64_t *pma;
	// if the end of the fifo collides with a cycle the pcs
	// doesn't accept a new data we much call creat packet
	do{
		pma = tb_pma_fifo_pop( tv_s->pma[lane], &debug_id, &ctrl);
		if(pma==NULL) tv_create_packet(tv_s, lane);
	}while(pma == NULL);
	assert(ctrl == NULL); // there is no crtl on pma
	
	// write pma
	info("fifo lane %d pop %ld data %016lx\n", lane, debug_id, *pma);
	tb_vpi_put_logic_uint64_t_var_arr(argv, pma, 1);
		
	// write debug id 
	tb_vpi_put_logic_uint64_t(argv, debug_id);

	free(pma); 
	return 0;
}

