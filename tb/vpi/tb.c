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

static tv_t  *tv_s = NULL;

static int tb_compiletf(char*user_data)
{
	#ifdef DEBUG
	vpi_printf("TB compile\n");
	#endif
	tv_s = tv_alloc();
    return 0;
}

// Drive PCS input values
static int tb_calltf(char*user_data)
{
	int 	lane;
	int 	ready;
	bool    has_data;
	
	vpiHandle sys;
	vpiHandle argv;
	
	sys = vpi_handle(vpiSysTfCall, 0);
	assert(sys);
	argv = vpi_iterate(vpiArgument, sys);
	assert(argv);
	#ifdef DEBUG
   	vpi_printf("TB call\n");
	#endif
	assert(tv_s);

	// ready
	s_vpi_value ready_val;
	vpiHandle ready_h;
	
	ready_h = vpi_scan(argv);
	assert(ready_h);
	ready_val.format = vpiIntVal;
	vpi_get_value(ready_h, &ready_val);
	ready = ready_val.value.integer;		
	
	// get lane n
	s_vpi_value lane_val;
	vpiHandle lane_h;
		
	lane_h = vpi_scan(argv);
	assert(lane_h);
	lane_val.format = vpiIntVal;
	vpi_get_value(lane_h, &lane_val);	
	lane = lane_val.value.integer;
	assert((lane < LANE_N) && ( lane > -1 )); 

	info("$tb ready %d called on lane %d\n", ready, lane);

	// create a new packet if none exist
	info("Getting next txd");
	
	if (ready) {
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
		tb_vpi_put_logic_1b_t(argv, ctrl->ctrl_v);
		tb_vpi_put_logic_1b_t(argv, ctrl->idle_v);
		// start 
		uint8_t s = 0;
		for(int l=START_W-1; l>-1 ;l--)
			s= (s<<1) | ctrl->start_v[l]; 
		tb_vpi_put_logic_uint8_t(argv, s);
		tb_vpi_put_logic_1b_t(argv, ctrl->term_v);
		tb_vpi_put_logic_uint8_t(argv, ctrl->term_keep);
		tb_vpi_put_logic_1b_t(argv, ctrl->err_v);

		// data
		tb_vpi_put_logic_uint64_t(argv, data[0] );
		// debug id
 		tb_vpi_put_logic_uint64_t(argv, debug_id);
		//vpi_free_handle(argv);
		free(data);
		free(ctrl);

	}
	return 0;
}
void tb_register()
{
      s_vpi_systf_data tf_data;

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype  = 0;
      tf_data.tfname    = "$tb";
      tf_data.calltf    = tb_calltf;
      tf_data.compiletf = tb_compiletf;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);
}


static int tb_exp_compiletf(char *path)
{
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
	uint64_t *pma = tb_pma_fifo_pop( tv_s->pma[lane], &debug_id, &ctrl);
	assert(ctrl == NULL); // crtl should be null
	assert(pma);
	
	// write pma
	info("fifo pop %ld data %016lx\n", debug_id, *pma);
	tb_vpi_put_logic_uint64_t_var_arr(argv, pma, 1);
		
	// write debug id 
	tb_vpi_put_logic_uint64_t(argv, debug_id);

	free(pma); 
	return 0;
}

void tb_exp_register()
{
	s_vpi_systf_data tf_end_data;
	
	tf_end_data.type      = vpiSysFunc;
	tf_end_data.sysfunctype  = vpiSysFuncInt;
	tf_end_data.tfname    = "$tb_exp";
	tf_end_data.calltf    = tb_exp_calltf;
	tf_end_data.compiletf = tb_exp_compiletf;
	tf_end_data.sizetf    = 0;
	tf_end_data.user_data = 0;
	vpi_register_systf(&tf_end_data);
}



// de-init routine
static int tb_end_compiletf(char *path)
{
    return 0;
}

static PLI_INT32 tb_end_calltf(char*user_data){
	if ( tv_s != NULL)tv_free(tv_s);	
	return 0;
}

void tb_end_register()
{
	s_vpi_systf_data tf_end_data;
	
	tf_end_data.type      = vpiSysFunc;
	tf_end_data.sysfunctype  = vpiSysFuncInt;
	tf_end_data.tfname    = "$tb_end";
	tf_end_data.calltf    = tb_end_calltf;
	tf_end_data.compiletf = tb_end_compiletf;
	tf_end_data.sizetf    = 0;
	tf_end_data.user_data = 0;
	vpi_register_systf(&tf_end_data);
}


void (*vlog_startup_routines[])() = {
    tb_end_register,
    tb_exp_register,
    tb_register,
    0
};


