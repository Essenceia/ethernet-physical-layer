/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#include "tb.h"
#include <assert.h>
#include <string.h>
#include <stdlib.h>

static tv_t * tv_s = NULL;


static int tb_compiletf(char*user_data)
{
	#ifdef DEBUG
	vpi_printf("TB compile\n");
	#endif
    return 0;
}

// Drive PCS input values
static int tb_calltf(char*user_data)
{
	#ifdef DEBUG
   	vpi_printf("TB call\n");
	#endif
	assert(tv_s);

	//vpi_free_handle(argv);
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


// init routine

static int tb_init_compiletf(char* path)
{
	tv_s = NULL;
	#ifdef DEBUG
	vpi_printf("TB_INIT compile\n");
	#endif
    return 0;
}

// A calltf VPI application routine shall be called each time the associated 
// user-defined system task/function is executed within the Verilog HDL 
// source code. 
static PLI_INT32 tb_init_calltf(char*user_data)
{
	// init routine
	
	#ifdef DEBUG
	vpi_printf("TB init call : end\n");
	#endif
	//vpi_free_handle(argv);
	return 0;
}


void tb_init_register()
{
	s_vpi_systf_data tf_init_data;
	
	tf_init_data.type      = vpiSysFunc;
	tf_init_data.sysfunctype  = vpiSysFuncInt;
	tf_init_data.tfname    = "$tb_init";
	tf_init_data.calltf    = tb_init_calltf;
	tf_init_data.compiletf = tb_init_compiletf;
	tf_init_data.sizetf    = 0;
	tf_init_data.user_data = 0;
	vpi_register_systf(&tf_init_data);
}

static int tb_itch_compiletf(char* path)
{
    return 0;
}

static PLI_INT32 tb_pma_calltf(char*user_data){
	// pop fifo pma value	
	//vpi_free_handle(argv);
	return 0;
}

void tb_pma_register()
{
	s_vpi_systf_data tf_pma_data;
	
	tf_pma_data.type      = vpiSysFunc;
	tf_pma_data.sysfunctype  = vpiSysFuncInt;
	tf_pma_data.tfname    = "$tb_pma";
	tf_pma_data.calltf    = tb_pma_calltf;
	tf_pma_data.compiletf = tb_pma_compiletf;
	tf_pma_data.sizetf    = 0;
	tf_pma_data.user_data = 0;
	vpi_register_systf(&tf_pma_data);
}
static int tb_end_compiletf(char* path)
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
    tb_init_register,
    tb_end_register,
    tb_register,
	tb_itch_register,
    0
};


