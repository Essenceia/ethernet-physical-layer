/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

/* PCS RX top level module */
module pcs_rx #(
	parameter IS_10G = 0,
	parameter IS_TB = 1,
	parameter HEAD_W = 2,
	parameter DATA_W = 64,
	parameter KEEP_W = DATA_W/8,
	parameter LANE_N = IS_10G ? 1 : 4,
	parameter BLOCK_W = HEAD_W+DATA_W,
	parameter LANE0_CNT_N = !IS_10G ? 1 : 2,
	parameter MAX_SKEW_BIT_N = 1856
)(
	input pcs_clk,
	input [LANE_N-1:0] rx_par_clk,
	input nreset,

	/* SerDes */
    input  [LANE_N-1:0]        serdes_lock_v_i,
    input  [LANE_N*DATA_W-1:0] serdes_data_i,

	/* signal ok, used only in 10G */
	/* verilator lint_off UNDRIVEN */
	output                           signal_v_o, 
	/* verilator lint_on UNDRIVEN */

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
reg   [LANE_N-1:0] gb_nreset_meta_q;
reg   [LANE_N-1:0] gb_nreset_q;
/* block sync */
logic [LANE_N-1:0] bs_lock_v;

// descrambler
logic               descram_v;
logic [SCRAM_W-1:0] scram_data;
logic [SCRAM_W-1:0] descram_data;

// decoder
/* verilator lint_off UNUSEDSIGNAL */
logic dec_v;// TODO 
/* verilator lint_on UNUSEDSIGNAL */

logic [HEAD_W-1:0] dec_head[LANE_N-1:0];
logic [DATA_W-1:0] dec_data[LANE_N-1:0];

genvar l;
generate
for(l=0; l<LANE_N; l++)begin : gen_gearbox_block_sync_loop
		/* SerDes
	 * signal valid when locked */
	assign serdes_signal_v[l] = ~serdes_lock_v_i[l];
	
	/* gearbox */
	/* cdc for synchronous reset */
	always @(posedge rx_par_clk[l])begin
		gb_nreset_meta_q[l] <= nreset;
		gb_nreset_q[l]      <= gb_nreset_meta_q[l];
	end

	gearbox_rx #(
		.HEAD_W(HEAD_W),
		.DATA_W(DATA_W)
	)m_gearbox_rx(
		.clk(rx_par_clk[l]),
		.nreset(gb_nreset_q[l]),
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
		.clk(rx_par_clk[l]),
		.nreset(nreset),
		.signal_v_i(serdes_signal_v[l]),
		.valid_i(gb_data_v[l]),
		.head_i(gb_head[l]),
		.slip_v_o(gb_slip_v[l]),
		.lock_v_o(bs_lock_v[l])
	);
end // gen_lane_common_loop

if ( !IS_10G ) begin: gen_40g

/* CDC
 * wr : from block sync/gearbox 
 * rd : to alignement marker lock / lane deskew
 * data valid */
logic              cdc_valid; //all lanes rd side of the cdc have valid data
logic [LANE_N-1:0] rd_cdc_valid;
logic [LANE_N-1:0] wr_cdc_valid;
logic [BLOCK_W-1:0] rd_cdc_data[LANE_N-1:0];
logic [BLOCK_W-1:0] wr_cdc_data[LANE_N-1:0];

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

// full lane lock
logic full_lock_v;

for(l=0; l<LANE_N; l++)begin : gen_40g_lane_loop

	assign wr_cdc_valid[l] = gb_data_v[l] & bs_lock_v[l];
	assign wr_cdc_data[l]  = {gb_data[l], gb_head[l]};
	 
	if (!IS_TB) begin: gen_cdc_fifo 
		/* CDC 
		 * Per lane to pass between the per lane
		 * rx clk and the multilane common pcs clk.
		 * Step down frequency from 161.13MHz to 156.25MHz */
		cdc_fifo m_cdc_fifo_rx (
			.wrclk(rx_par_clk[l]),   
			.rdclk(pcs_clk), 
			/* wr */
			.wrreq(wr_cdc_valid[l]),   
			.data(wr_cdc_data[l]),    
			/* rd */  
			.q(rd_cdc_data[l]),       
			.rdreq(1'b1),   
			.rdempty(rd_cdc_valid[l])  
		);
	end else begin : gen_no_cdc
		assign rd_cdc_valid[l] = wr_cdc_valid[l];
		assign rd_cdc_data[l] = wr_cdc_data[l];
	end // !IS_TB
	
	/* gearbox -> phase align marker */
	/* alignement marker lock */
	am_lock_rx #(
		.BLOCK_W(BLOCK_W),
		.LANE_N(LANE_N))
	m_am_lock_rx(
		.clk(pcs_clk),
		.nreset(nreset),
		.valid_i(rd_cdc_valid[l]),
		.block_i(rd_cdc_data[l]),
		.lock_v_o(am_lock_v[l]),
		.lite_am_v_o(am_lite_v[l]),
		.lite_lock_v_o(am_lite_lock_v[l]),
		.lane_o(am_lane_id[l])
	);
	
	// lane reordering
	assign nord_lane_id[l*LANE_N+LANE_N-1:l*LANE_N] = am_lane_id[l];
	assign nord_block[l*BLOCK_W+:BLOCK_W] = rd_cdc_data[l];

end // gen_40g_lane_loop

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
	.clk(pcs_clk),
	.nreset(nreset),
	.am_lite_v_i(am_lite_v),
	.am_lite_lock_v_i(am_lite_lock_v), 
//	.am_lite_lock_lost_v_i(am_slip_v),
	.data_i(ord_block),
	.am_v_o(deskew_am_v),
	.data_o(deskew_block)
);

// full lock includes both sync and, if present am lock
assign full_lock_v = &am_lock_v & &bs_lock_v;
// alignement marker removal
// mask validity of block on alignement marker
assign amr_block_v = ~deskew_am_v; 

assign cdc_valid = |rd_cdc_valid;
/* cdc, reorderer -> descrambler */
assign descram_v = cdc_valid;
/* deskew, descrambler -> decoder */
assign dec_v = cdc_valid; 

for(l=0; l<LANE_N; l++) begin : gen_scram_data_loop
	// remove head, get only data
	assign scram_data[l*DATA_W+DATA_W-1:l*DATA_W] = deskew_block[l*BLOCK_W+BLOCK_W-1:l*BLOCK_W+HEAD_W];
	
	assign dec_head[l] = deskew_block[l*BLOCK_W+HEAD_W-1:l*BLOCK_W];
	assign dec_data[l] = descram_data[l*DATA_W+DATA_W-1:l*DATA_W];

	/* duplicate same valid for all lanes */
	assign valid_o[l] = amr_block_v & full_lock_v;
end // gen_scram_data_loop
	
end else begin : gen_10g
/* 10GBASE-R configuration */

/* gearbox -> descrambler */
assign descram_v = gb_data_v; 

/* gearbox, descrambler -> decoder */
assign dec_v = gb_data_v;

for(l=0; l<LANE_N; l++) begin : gen_scram_data_loop
	// remove head, get only data
	assign scram_data[l*DATA_W+DATA_W-1:l*DATA_W] = gb_data[l];
	
	assign dec_head[l] = gb_head[l];
	assign dec_data[l] = descram_data[l*DATA_W+DATA_W-1:l*DATA_W];
end

/* output
 * signal ok, data valid */
assign signal_v_o = bs_lock_v; 
assign valid_o = gb_data_v;

end // gen_40g

endgenerate


_64b66b_rx #(
	.LEN(SCRAM_W))
m_descrambler_rx(
	.clk(pcs_clk),
	.nreset(nreset),
	.valid_i(descram_v),
	.scram_i(scram_data),
	.data_o(descram_data)
);

// decode
generate
for(l=0; l<LANE_N; l++) begin : dec_lane_loop

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

end
endgenerate

endmodule
