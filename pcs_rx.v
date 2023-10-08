/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

/* PCS RX top level module */
module pcs_rx #(
	parameter IS_10G = 0,
	parameter HEAD_W = 2,
	parameter DATA_W = 64,
	parameter KEEP_W = DATA_W/8,
	parameter LANE_N = 4,
	parameter BLOCK_W = HEAD_W+DATA_W,
	parameter LANE0_CNT_N = !IS_10G ? 1 : 2,
	parameter MAX_SKEW_BIT_N = 1856
)(
	input clk,
	input nreset,

	/* SerDes */
    input  [LANE_N-1:0]        serdes_lock_v_i,
    input  [LANE_N*DATA_W-1:0] serdes_data_i,
	
	/* lite MAC interface 
	 * need to add wrapper to interface with x(l)gmii*/
	output [LANE_N-1:0]              valid_o,
	output [LANE_N-1:0]              ctrl_v_o,
	output [LANE_N-1:0]              idle_v_o,
	output [LANE_N*LANE0_CNT_N-1:0]  start_v_o,
	output [LANE_N-1:0]              term_v_o,
	output [LANE_N-1:0]              err_v_o,
	output [LANE_N-1:0]              ord_v_o,
	output [LANE_N*DATA_W-1:0]       data_o, 
	output [LANE_N*KEEP_W-1:0]       keep_o

);
localparam SCRAM_W = LANE_N*DATA_W; 

/* serdes */
logic [LANE_N-1:0] serdes_signal_v;

/* gearbox */
logic [LANE_N-1:0] gb_data_v;
logic [HEAD_W-1:0] gb_head[LANE_N-1:0];
logic [DATA_W-1:0] gb_data[LANE_N-1:0];
logic [LANE_N-1:0] gb_slip_v;/* bit slip */

// block sync
logic [LANE_N-1:0] bs_lock_v;

// alignement marker lock
logic [LANE_N-1:0]  am_lane_id[LANE_N-1:0]; // lane onehot identified
// logic [LANE_N-1:0]  am_slip_v;
logic [LANE_N-1:0]  am_lock_v;
logic [LANE_N-1:0]  am_lite_v;
logic [LANE_N-1:0]  am_lite_lock_v;

// lane reorder, `nord` = not ordered
logic [LANE_N*LANE_N-1:0]  nord_lane_id;
logic [LANE_N*BLOCK_W-1:0] nord_block;
logic [LANE_N*BLOCK_W-1:0] ord_block;

// deskew
logic                      deskew_am_v;
logic [LANE_N*BLOCK_W-1:0] deskew_block;

// alignement marker removal
logic amr_block_v;

// descrambler
logic               scram_v;
logic [SCRAM_W-1:0] scram_data;
logic [SCRAM_W-1:0] descram_data;

// decoder
logic [HEAD_W-1:0] dec_head[LANE_N-1:0];
logic [DATA_W-1:0] dec_data[LANE_N-1:0];

// full lane lock
logic full_lock_v;

genvar l;
generate
for(l=0; l<LANE_N; l++)begin : gen_lane_common_loop

/* SerDes
 * signal valid when locked */
assign serdes_signal_v[l] = ~serdes_lock_v_i[l];

/* gearbox */
gearbox_rx #(
	.HEAD_W(HEAD_W),
	.DATA_W(DATA_W)
)m_gearbox_rx(
	.clk(clk),
	.nreset(nreset),
	.lock_v_i(serdes_lock_v_i[l]),
	.data_i(serdes_data_i[l*DATA_W+DATA_W-1:l*DATA_W]),
	.slip_v_i(gb_slip_v[l]),
	.valid_o(gb_data_v[l]), // backpressure, buffer is full, need a cycle to clear 
	.head_o(gb_head[l]),
	.data_o(gb_data[l])
);

/* block sync */
block_sync_rx #(.HEAD_W(HEAD_W))
m_bs_rx(
	.clk(clk),
	.nreset(nreset),
	.signal_v_i(serdes_signal_v[l]),
	.valid_i(gb_data_v[l]),
	.head_i(gb_head[l]),
	.slip_v_o(gb_slip_v[l]),
	.lock_v_o(bs_lock_v[l])
);

end // gen_lane_common_loop

if ( !IS_10G ) begin: gen_40g

/* Phase aligner */
/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNDRIVEN */
logic pa_valid;/* data valid */
logic [LANE_N*BLOCK_W-1:0] pa_block;
// TODO

/* CDC */
logic cdc_valid;/* data valid */
logic [LANE_N*BLOCK_W-1:0] cdc_block;
// TODO

/* verilator lint_on UNUSEDSIGNAL */
/* verilator lint_on UNDRIVEN */

for(l=0; l<LANE_N; l++)begin : gen_40g_lane_loop

/* gearbox -> phase align marker */
assign pa_block[l*BLOCK_W+:BLOCK_W] = { gb_data[l], 
				                        gb_head[l] };
/* alignement marker lock */
am_lock_rx #(
	.BLOCK_W(BLOCK_W),
	.LANE_N(LANE_N))
m_am_lock_rx(
	.clk(clk),
	.nreset(nreset),
	.valid_i(cdc_valid),
	.block_i(cdc_block[l*BLOCK_W+:BLOCK_W]),
	.lock_v_o(am_lock_v[l]),
	.lite_am_v_o(am_lite_v[l]),
	.lite_lock_v_o(am_lite_lock_v[l]),
	.lane_o(am_lane_id[l])
);

// lane reordering
assign nord_lane_id[l*LANE_N+LANE_N-1:l*LANE_N] = am_lane_id[l];
assign nord_block = cdc_block;

end // gen_am_lock_loop

lane_reorder_rx #(
	.LANE_N(LANE_N),
	.BLOCK_W(BLOCK_W)
)
m_lane_reorder_rx(
	.lane_i(nord_lane_id),
	.block_i(nord_block),
	.block_o(ord_block)
);

// lane deskew
deskew_rx #(
	.LANE_N(LANE_N),
	.BLOCK_W(BLOCK_W),
	.MAX_SKEW_BIT_N(MAX_SKEW_BIT_N)) 
m_deskew_rx(
	.clk(clk),
	.nreset(nreset),
	.am_lite_v_i(am_lite_v),
	.am_lite_lock_v_i(am_lite_lock_v), 
//	.am_lite_lock_lost_v_i(am_slip_v),
	.data_i(ord_block),
	.am_v_o(deskew_am_v),
	.data_o(deskew_block)
);
end // gen_40g

endgenerate

// full lock includes both sync and, if present am lock
assign full_lock_v = &am_lock_v & &bs_lock_v;
// alignement marker removal
// mask validity of block on alignement marker
assign amr_block_v = ~deskew_am_v; 

// descramble
assign scram_v = amr_block_v;
generate
	for(l=0; l<LANE_N; l++) begin : scram_data_loop
		// remove head, get only data
		assign scram_data[l*DATA_W+DATA_W-1:l*DATA_W] = deskew_block[l*BLOCK_W+BLOCK_W-1:l*BLOCK_W+HEAD_W];
	end
endgenerate
_64b66b_rx #(
	.LEN(SCRAM_W))
m_descrambler_rx(
	.clk(clk),
	.nreset(nreset),
	.valid_i(scram_v),
	.scram_i(scram_data),
	.data_o(descram_data)
);

// decode
generate
for(l=0; l<LANE_N; l++) begin : dec_lane_loop

assign dec_head[l] = deskew_block[l*BLOCK_W+HEAD_W-1:l*BLOCK_W];
assign dec_data[l] = descram_data[l*DATA_W+DATA_W-1:l*DATA_W];

dec_lite_rx #(
	.IS_40G(!IS_10G),
	.HEAD_W(HEAD_W),
	.DATA_W(DATA_W),
	.KEEP_W(KEEP_W))
m_dec_lite_rx(
	.head_i(dec_head[l]),
	.data_i(dec_data[l]),
	.ctrl_v_o(ctrl_v_o[l]),
	.idle_v_o(idle_v_o[l]),
	.start_v_o(start_v_o[l*LANE0_CNT_N+LANE0_CNT_N-1:l*LANE0_CNT_N]),
	.term_v_o(term_v_o[l]),
	.err_v_o(err_v_o[l]),
	.ord_v_o(ord_v_o[l]),
	.data_o(data_o[l*DATA_W+DATA_W-1:l*DATA_W]), 
	.keep_o(keep_o[l*KEEP_W+KEEP_W-1:l*KEEP_W])
);

assign valid_o[l] = amr_block_v & full_lock_v;
end
endgenerate

endmodule
