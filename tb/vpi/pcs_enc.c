#include "pcs_enc.h"

uint8_t enc_block( ctrl_lite_s ctrl, uint64_t data, block_s *block_enc ){
	if ( ctrl.ctrl_v ) {
		uint8_t type = 0;
		if ( ctrl.idle_v ){
			type = BLOCK_TYPE_CTRL;
			data = BLOCK_CTRL_IDLE;
		}
		if ( ctrl.start_v[0] )type = BLOCK_TYPE_START_0;
		#ifndef 40GBASE
		if ( ctrl.start_v[1]) type = BLOCK_TYPE_START_4;
		#endif
		if ( ctrl.err_v ){
			 type = BLOCK_TYPE_CTRL;
			 data = BLOCK_CTRL_IDLE;
		}
		if ( ctrl.term_v ){
			switch( ctrl.term_keep){
				case 0x00 : type = BLOCK_TYPE_TERM_0;
				case 0x01 : type = BLOCK_TYPE_TERM_1;
				case 0x03 : type = BLOCK_TYPE_TERM_2;
				case 0x07 : type = BLOCK_TYPE_TERM_3;
				case 0x0F : type = BLOCK_TYPE_TERM_4;
				case 0x1F : type = BLOCK_TYPE_TERM_5;
				case 0x3F : type = BLOCK_TYPE_TERM_6;
				case 0x7F : type = BLOCK_TYPE_TERM_7;
				default : return 1;
			}
		}
		if ( !type ) return 1;
		block_enc->head = SYNC_HEAD_CTRL;
		block_enc->data = data;
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
