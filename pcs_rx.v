/* PCS RX top level module */
module pcs_rx #(
	parameter IS_40G = 1,
	parameter HEAD_W = 2,
	parameter DATA_W = 64,
	parameter KEEP_W = DATA_W/8,
	parameter LANE_N = 4,
	parameter BLOCK_W = HEAD_W+DATA_W,
	parameter LANE0_CNT_N = IS_40G ? 1 : 2,
	parameter MAX_SKEW_BIT_N = 1856
)(
	input clk,
	input nreset,

	// transiver
    input  [LANE_N-1:0]        serdes_v_i,
    input  [LANE_N*DATA_W-1:0] serdes_data_i,
    input  [LANE_N*HEAD_W-1:0] serdes_head_i,
    output [LANE_N-1:0]        gearbox_slip_o,
	
	// lite MAC interface
	// need to add wrapper to interface with x(l)gmii
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

// block sync
logic [HEAD_W-1:0] bs_head[LANE_N-1:0];
logic [LANE_N-1:0] bs_lock_v;

// alignement marker lock
logic [BLOCK_W-1:0] am_block[LANE_N-1:0];
logic [LANE_N-1:0]  am_lane_id[LANE_N-1:0]; // lane onehot identified
logic [LANE_N-1:0]  am_slip_v;
logic [LANE_N-1:0]  am_lock_v;
logic [LANE_N-1:0]  am_lite_v;
logic [LANE_N-1:0]  am_lite_lock_v;

// lane reorder, `nord` = not ordered
logic [LANE_N*LANE_N-1:0]  nord_lane_id;
logic [LANE_N*BLOCK_W-1:0] nord_block;
logic [LANE_N*BLOCK_W-1:0] ord_block;

// deskew
logic [LANE_N*BLOCK_W-1:0] deskew_block;

// alignement marker removal
logic [LANE_N-1:0] amr_block_v;

// descrambler
logic               scram_v;
logic [SCRAM_W-1:0] scram_data;
logic [SCRAM_W-1:0] descram_data;

genvar l;
generate
for(l=0; l<LANE_N; l++)begin : lane

assign bs_head[l] = serdes_head_i[l*HEAD_W+HEAD_W-1:l*HEAD_W];

// block sync
block_sync_rx #(.HEAD_W(HEAD_W))
m_bs_rx(
	.clk(clk),
	.nreset(nreset),
	.valid_i(serdes_v_i[l]),
	.head_i(bs_head[l]),
	.slip_v_o(gearbox_slip_o[l]),
	.lock_v_o(bs_lock_v[l])
);
// alignement marker lock
assign am_block[l] = { serdes_data_i[l*DATA_W+DATA_W-1:l*DATA_W], 
				       serdes_head_i[l*HEAD_W+HEAD_W-1:l*HEAD_W] };
am_lock_rx #(
	.BLOCK_W(BLOCK_W),
	.LANE_N(LANE_N))
m_am_lock_rx(
	.clk(clk),
	.nreset(nreset),
	.valid_i(serdes_v_i[l]),
	.block_i(am_block[l]),
	.slip_v_o(am_slip_v[l]),
	.lock_v_o(am_lock_v[l]),
	.lite_am_v_o(am_lite_v[l]),
	.lite_lock_v_o(am_lite_lock_v[l]),
	.lane_o(am_lane_id[l])
);

// lane reordering
assign nord_lane_id[l*LANE_N+LANE_N-1:l*LANE_N] = am_lane_id[l];
assign nord_block[l*BLOCK_W+BLOCK_W-1:l*BLOCK_W] = am_block[l];
end
endgenerate
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
	.valid_i(bs_lock_v),
	.am_lite_v_i(am_lite_v),
	.am_lite_lock_v_i(am_lite_lock_v), 
	.am_lite_lock_lost_v_i(am_slip_v),
	.data_i(ord_block),
	.data_o(deskew_block)
);
// alignement marker removal
// mask validity of block on alignement marker
assign amr_block_v = bs_lock_v & am_lite_lock_v & ~am_lite_v;

// descramble
assign scram_v = &amr_block_v;
generate
	for(l=0; l<LANE_N; l++) begin
		// remove head, get only data
		assign scram_data[l*DATA_W+DATA_W-1:l*DATA_W] = deskew_block[l*BLOCK_W+BLOCK_W-1:l*BLOCK_W+HEAD_W];
	end
endgenerate
descrambler_64b66b_rx #(
	.LEN(SCRAM_W)
)
m_descrambler_rx(
	.clk(clk),
	.nreset(nreset),
	.valid_i(scram_v),
	.scram_i(scram_data),
	.data_o(descram_data)
);

// decode

logic [HEAD_W-1:0] dec_head[LANE_N-1:0];
logic [DATA_W-1:0] dec_data[LANE_N-1:0];

generate
for(l=0; l<LANE_N; l++) begin

assign dec_head[l] = deskew_block[l*BLOCK_W+HEAD_W-1:l*BLOCK_W];
assign dec_data[l] = descram_data[l*DATA_W+DATA_W-1:l*DATA_W];

dec_lite_rx #(
	.IS_40G(IS_40G),
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

assign valid_o[l] = amr_block_v[l];
end
endgenerate

endmodule
