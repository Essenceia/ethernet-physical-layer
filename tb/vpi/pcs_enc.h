#ifndef PCS_ENC_H
#define PCS_ENC_H
#include "pcs_defs.h"
/* PCS encoder functions */

/* Encode block control signals into the data and define sync header's value */
uint8_t enc_block( ctrl_lite_s ctrl, uint64_t data, block_s *block_enc );  
uint8_t dec_block( uint8_t *ctrl, uint64_t *data, block_s block_dec ); 

#endif // PCS_ENC_H
 
