/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#ifndef PCS_TX_H
#define PCS_TX_H
#include "pcs_defs.h"

pcs_tx_s *pcs_tx_init();

// returns 0 if we accepted the new data
bool get_next_exp(pcs_tx_s *state, const ctrl_lite_s ctrl, block_s *data, block_s *exp);

#endif//PCS_TX_H
