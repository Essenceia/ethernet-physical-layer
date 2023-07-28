/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#ifndef TEST_H
#define TEST_H
#include "pcs_tx.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>


int main(){
	pcs_tx_s *tx;
	bool accept;
	uint64_t data;
	uint64_t pma;
	ctrl_lite_s ctrl;
	tx = pcs_tx_init();

	memset( &ctrl, 0, sizeof(ctrl_lite_s ));

	ctrl.ctrl_v = true;
	ctrl.idle_v = true;
	data = 0;
	accept = get_next_64b(tx, 0,ctrl, data, &pma );
	
	printf("raw data x%016lX\npma data x%016lX\n", data, pma);
	
	return 0;
}
#endif // TEST_H
