#ifndef TB_PCS_COMMON
#define TB_PCS_COMMON

#ifdef VERILATOR
#include "verilated_vpi.h" 
#else
#include  <vpi_user.h>
#endif

#include "tv.h"

/* Get values of lane */
void tb_pcs_get_tx_lane(
	tv_t *tv_s,
	int lane,
	ctrl_lite_s *ctrl,
	uint64_t *data,
	uint64_t *debug_id
);
/* write data to design */
void tb_pcs_set_data(
	ctrl_lite_s ctrl[LANE_N],
	uint64_t data[LANE_N],
	uint64_t debug_id[LANE_N],
	vpiHandle h_ready_o,
	vpiHandle h_ctrl_v_i,
	vpiHandle h_idle_v_i,
	vpiHandle h_start_v_i,
	vpiHandle h_term_v_i,
	vpiHandle h_term_keep_i,
	vpiHandle h_err_i,
	vpiHandle h_data_i,
	vpiHandle h_debug_id_i
);

void tb_pcs_tx(
	tv_t *tv_s,
	vpiHandle h_ready_o,
	vpiHandle h_ctrl_v_i,
	vpiHandle h_idle_v_i,
	vpiHandle h_start_v_i,
	vpiHandle h_term_v_i,
	vpiHandle h_term_keep_i,
	vpiHandle h_err_i,
	vpiHandle h_data_i,
	vpiHandle h_debug_id_i
);

void tb_pcs_get_exp_lane(
	tv_t *tv_s,
	uint64_t *pma,
	uint64_t* debug_id
);

void tb_pcs_exp_set_data(
	uint64_t pma[LANE_N],
	uint64_t debug_id[LANE_N],
	vpiHandle h_pma_o,
	vpiHandle h_debug_id_o		
);

void tb_pcs_tx_exp(
	tv_t *tv_s,
	vpiHandle h_pma_o,
	vpiHandle h_debug_id_o
);

#endif //TB_PCS_COMMON
