/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 
#ifndef PCS_ENC_H
#define PCS_ENC_H
#include "pcs_defs.h"
/* PCS encoder functions */

/* Encode block control signals into the data and define sync header's value */
uint8_t enc_block( ctrl_lite_s ctrl, uint64_t data, block_s *block_enc );  
uint8_t dec_block( uint8_t *ctrl, uint64_t *data, block_s block_dec ); 

#endif // PCS_ENC_H
 
