/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#include "pcs_defs.h"
#include "pcs_marker.h"
#include "tb_rand.h"
#include <vpi_user.h>
#include <assert.h>
#include "defs.h"
#define LANE_N 4
#ifndef SEED
#define SEED 10
#endif
static marker_s state;

uint8_t format_head(block_s b[LANE_N]){
	uint8_t h=0;
	for(int i=0; i<LANE_N; i++){
		h |= b[i].head  << 2*i;
		info("%d h %x head %x\n",i,h, b[i].head);
	}
	return h;
}
void format_data(block_s b[LANE_N], uint64_t *d){
	for(int i=0; i<LANE_N; i++){
		d[i] = b[i].data;
	}
}

static int tb_marker_compiletf(char*user_data)
{
	tb_rand_init(SEED);	
    return 0;
}

// Drive PCS marker aligment input values
static int tb_marker_calltf(char*user_data)
{
	vpiHandle sys;
	vpiHandle argv;
	
	sys = vpi_handle(vpiSysTfCall, 0);
	assert(sys);
	argv = vpi_iterate(vpiArgument, sys);
	assert(argv);

	// create rand packet
	block_s in[LANE_N];
	for(uint8_t i=0; i<LANE_N; i++){
		in[i].data = tb_rand_uint64_t();
		in[i].head = ( tb_rand_uint8_t() % 2 )? 0x1 : 0x2;

	}
	// sent through marker model
	bool marker_v = false;
	block_s out[LANE_N];
	for(size_t i=0; i<LANE_N; i++){
		marker_v |= alignement_marker( &state, i,in[i], &out[i]);
		info("%ld [%ld] data_i { %lx, %x } ",state.gap, i, in[i].data, in[i].head);
	}
	//head
	uint8_t head_i = format_head(in);
	uint8_t head_o = format_head(out);
	// data
	uint64_t data_i[LANE_N];	
	uint64_t data_o[LANE_N];
	format_data(in, &data_i);	
	format_data(out, &data_o);	

	// in
	info("HEAD %x\n", head_o);
	tb_vpi_put_logic_uint8_t(argv, head_i);
	tb_vpi_put_logic_uint64_t_var_arr(argv, data_i, LANE_N);
	// out
	tb_vpi_put_logic_uint8_t(argv, marker_v);
	tb_vpi_put_logic_uint8_t(argv, head_o);
	tb_vpi_put_logic_uint64_t_var_arr(argv, data_o, LANE_N);	
	
	return 0;
}
void tb_marker_register()
{
      s_vpi_systf_data tf_data;

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype  = 0;
      tf_data.tfname    = "$tb_marker";
      tf_data.calltf    = tb_marker_calltf;
      tf_data.compiletf = tb_marker_compiletf;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);
}

void (*vlog_startup_routines[])() = {
    tb_marker_register,
    0
};


