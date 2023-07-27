#ifndef PCS_TX_H
#define PCS_TX_H

pcs_tx_s *pcs_tx_init();

// returns 0 if we accepted the new data
uint8_t get_next_64b(pcs_tx_s *state, size_t lane, ctrl_lite ctrl, uint64_t data, uint64_t *pma);

#endif//PCS_TX_H
