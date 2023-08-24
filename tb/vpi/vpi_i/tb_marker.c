/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

/* Iverilog specific vpi wrapping */

#include "tb_marker.h"
#include "../tb_marker_common.h"
#include <assert.h>
#include "../defs.h"

static int tb_marker_compiletf(char*user_data)
{
    return 0;
}

// Drive PCS marker aligment input values
static int tb_marker_calltf(char*user_data)
{
	// get vpi argument handler
	vpiHandle sys;
	vpiHandle argv;

	sys = vpi_handle(vpiSysTfCall, 0);
	assert(sys);
	argv = vpi_iterate(vpiArgument, sys);
	assert(argv);

	// scan argv for parameters in the order they
	// appear in the function call 
	vpiHandle h_head_i;
	vpiHandle h_data_i;
	vpiHandle h_marker_v;
	vpiHandle h_head_o;
	vpiHandle h_data_o;

	h_head_i = vpi_scan(argv);
	h_data_i = vpi_scan(argv);
	h_marker_v = vpi_scan(argv);
	h_head_o = vpi_scan(argv);
	h_data_o = vpi_scan(argv);

	// call common vpi section
	tb_marker(h_head_i,h_data_i,h_marker_v, 
	h_head_o,h_data_o);
	
	return 0;
}

/* Async call through verilator vpi isn't possible, only
 * for iverilog as of writting */ 
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


