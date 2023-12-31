/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#ifndef TB_MARKER_COMMON_H
#define TB_MARKER_COMMON_H

#ifdef VERILATOR
#include "verilated_vpi.h" 
#else
#include  <vpi_user.h>
#endif

/* Generate the next turples of { data, head } and 
 * the associated expected output { data, head } alongside
 * the flag to indicate if the marker is written within this
 * cycle */
int tb_marker(
	vpiHandle h_head_i,
	vpiHandle h_data_i,
	vpiHandle h_marker_v, 
	vpiHandle h_head_o,
	vpiHandle h_data_o
);
#endif //TB_MARKER_COMMON_H
