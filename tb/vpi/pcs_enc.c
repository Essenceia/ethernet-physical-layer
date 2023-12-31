/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#include "pcs_enc.h"
#include "defs.h"
#include <assert.h>
#include <stdio.h>
uint8_t enc_block( ctrl_lite_s ctrl, uint64_t data, block_s *block_enc ){
	info("ENC : ctrl_v %x start_v[0] %x idle_v %x term_v %x term_keep %08x\n", 
		ctrl.ctrl_v, 
		ctrl.start_v[0], 
		ctrl.idle_v,
		ctrl.term_v,
		ctrl.term_keep);
	if ( ctrl.ctrl_v ) {
		uint8_t type = 0;
		if ( ctrl.idle_v ){
			type = BLOCK_TYPE_CTRL;
			data = BLOCK_CTRL_IDLE;
		}
		if ( ctrl.start_v[0] )type = BLOCK_TYPE_START_0;
		#ifndef _40GBASE
		if ( ctrl.start_v[1]) type = BLOCK_TYPE_START_4;
		#endif
		if ( ctrl.err_v ){
			 type = BLOCK_TYPE_CTRL;
			 data = BLOCK_CTRL_IDLE;
		}
		if ( ctrl.term_v ){
			info("term %x keep %x\n", ctrl.term_v, ctrl.term_keep);
			switch( ctrl.term_keep){
				case 0x00 : type = BLOCK_TYPE_TERM_0;
							break;
				case 0x01 : type = BLOCK_TYPE_TERM_1;
							break;
				case 0x03 : type = BLOCK_TYPE_TERM_2;
							break;
				case 0x07 : type = BLOCK_TYPE_TERM_3;
							break;
				case 0x0F : type = BLOCK_TYPE_TERM_4;
							break;
				case 0x1F : type = BLOCK_TYPE_TERM_5;
							break;
				case 0x3F : type = BLOCK_TYPE_TERM_6;
							break;
				case 0x7F : type = BLOCK_TYPE_TERM_7;
							break;
				default :   fprintf(stderr, "ENC: Unknown keep when setting term type, got %x\n", ctrl.term_keep);
							assert(0);
						  	return 1;
			}
		}
		if ( !type ) {
			fprintf(stderr, "ENC : Unidentified ctrl type\n"); 
			assert(0);
			return 1;
		}
		block_enc->head = SYNC_HEAD_CTRL;
		block_enc->data = ( data & ~0xffULL) | ( type & 0xffULL);
	}else{
		block_enc->head = SYNC_HEAD_DATA;
		block_enc->data = data;
	}
	return 0;
};

uint8_t dec_block( uint8_t *ctrl, uint64_t *data, block_s block_dec ){
	// TODO
	return 1; 
}
