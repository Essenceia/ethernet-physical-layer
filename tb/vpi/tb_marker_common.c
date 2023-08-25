/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#include "tb_marker_common.h"
#include "pcs_defs.h"
#include "pcs_marker.h"
#include "tb_rand.h"
#include <assert.h>
#include "defs.h"
#include "tb_utils.h"

#ifndef LANE_N
#define LANE_N 4
#endif

static marker_s state;

uint8_t format_head(block_s b[LANE_N]){
	uint8_t h=0;
	for(int i=0; i<LANE_N; i++){
		h |= b[i].head  << 2*i;
		//info("%d h %x head %x\n",i,h, b[i].head);
	}
	return h;
}
void format_data(block_s b[LANE_N], uint64_t *d){
	for(int i=0; i<LANE_N; i++){
		d[i] = b[i].data;
		//info("lane %d d %x data %x\n",i,d[i], b[i].data);
	}
}

/* main function, called by both iverilog and verialtor vpi */
int tb_marker(
	vpiHandle h_head_i,
	vpiHandle h_data_i,
	vpiHandle h_marker_v_o, 
	vpiHandle h_head_o,
	vpiHandle h_data_o
){
	// check all handlers are valid
	assert(h_head_i);
	assert(h_data_i);
	assert(h_marker_v_o); 
	assert(h_head_o);
	assert(h_data_o); 

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
		info("\n%ld [%ld] data_i { %lx, %x }\n",state.gap, i, in[i].data, in[i].head);
		marker_v |= alignement_marker( &state, i,in[i], &out[i]);
		info("marker_v %x data_o { %lx, %x }\n",marker_v, out[i].data, out[i].head);
	}
	//head
	uint8_t head_i = format_head(in);
	uint8_t head_o = format_head(out);
	// data
	uint64_t data_i[LANE_N];	
	uint64_t data_o[LANE_N];
	format_data(in, (uint64_t*) &data_i);	
	format_data(out,(uint64_t*) &data_o);	

	// in
	info("HEAD %x\n", head_o);
	tb_vpi_put_logic_uint8_t(h_head_i, head_i);
	tb_vpi_put_logic_uint64_t_var_arr(h_data_i, data_i, LANE_N);
	// out
	tb_vpi_put_logic_uint8_t(h_marker_v_o, marker_v);
	tb_vpi_put_logic_uint8_t(h_head_o, head_o);
	tb_vpi_put_logic_uint64_t_var_arr(h_data_o, data_o, LANE_N);	
	
	return 0;
};

