/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#include "tb_pcs.h"
#include "../tb_pcs_common.h"
#include "../tv.h"
#include <assert.h>
#include <string.h>
#include <stdlib.h>

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

	// handlers : the order matters
	vpiHandle h_ready_o = vpi_scan(argv);
	vpiHandle h_ctrl_v_i= vpi_scan(argv);
	vpiHandle h_idle_v_i= vpi_scan(argv);
	vpiHandle h_start_v_i= vpi_scan(argv);
	vpiHandle h_term_v_i= vpi_scan(argv);
	vpiHandle h_term_keep_i= vpi_scan(argv);
	vpiHandle h_err_i= vpi_scan(argv);
	vpiHandle h_data_i= vpi_scan(argv);
	vpiHandle h_debug_id_i= vpi_scan(argv);


	tb_pcs_tx(tv_s, 
		h_ready_o, 
		h_ctrl_v_i, 
		h_idle_v_i,
		h_start_v_i, 
		h_term_v_i, 
		h_term_keep_i,
		h_err_i, 
		h_data_i,
		h_debug_id_i);	
	
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
		
	vpiHandle h_pma_o = vpi_scan(argv);
	vpiHandle h_debug_id_o = vpi_scan(argv);	

	// assert
	assert(h_pma_o);
	assert(h_debug_id_o);	

	tb_pcs_tx_exp(tv_s, h_pma_o, h_debug_id_o);

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

