/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#ifndef PCS_GEARBOX_H
#define PCS_GEARBOX_H
#include "pcs_defs.h"

/* PCS gearbox functions */

/* Produce the next 4x16b pma data, return 1 when gearbox is full */
uint8_t gearbox( gearbox_s * state, block_s block, uint64_t *pma );  

static inline bool gearbox_full(gearbox_s state){
	return state.len == 64;
};
#endif // PCS_GEARBOX_H
 
