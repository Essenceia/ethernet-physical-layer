#ifndef PCS_TX_H
#define PCS_TX_H
#include "pcs_defs.h"

pcs_tx_s *pcs_tx_init();

// returns 0 if we accepted the new data
bool get_next_pma(pcs_tx_s *state, const ctrl_lite_s ctrl, uint64_t data, uint64_t *pma);

#endif//PCS_TX_H
