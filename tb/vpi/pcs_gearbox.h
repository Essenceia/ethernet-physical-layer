#ifndef PCS_GEARBOX_H
#define PCS_GEARBOX_H
#include "pcs_defs.h"

/* PCS gearbox functions */

/* Produce the next 4x16b pma data, return 1 when gearbox is full */
uint8_t gearbox( gearbox_s * state, block_s* block, uint64_t *pma );  

#endif // PCS_GEARBOX_H
 
