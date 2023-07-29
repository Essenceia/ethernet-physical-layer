/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#ifndef TEST_H
#define TEST_H
#include "tv.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "defs.h"

int main(){
	tv_t *t;
	bool accept;
	uint8_t *data;
	ctrl_lite_s ctrl;

	memset( &ctrl, 0, sizeof(ctrl_lite_s ));

	ctrl.ctrl_v = true;
	ctrl.idle_v = true;
	data = 0;

	t = tv_alloc();
	
	data = (uint8_t*) malloc(sizeof(uint8_t) * TXD_W);
	for(int i=0; i < 2; i++){
		if (!tv_txd_has_data(t))	tv_create_packet(t);
		info("Reading data\n");
		tv_get_next_txd(t, &ctrl, data ); 
	}	
	
	printf("raw data 0x%016lX\n\n", (size_t) data);
	free(data);

	tv_free(t);	
	return 0;
}
#endif // TEST_H
