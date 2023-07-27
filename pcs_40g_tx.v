/* PCS on the transmission path 
 * 
 * This module does not support a configurable data width,
 * it expects 256b of data from the mac every cycle.
 *
 * The meaning of "lane" is difference for 40g than 10g.
 * In 10g each block had 2x4 lanes, in 40g the xgmii data
 * is composed of 4 lanes of 1 block width.
 * */
module pcs_40g_tx#(
	parameter LANE_N = 4,
	parameter BLOCK_W = 64,
	parameter KEEP_W = $clog2(BLOCK_W),
	parameter XGMII_DATA_W = LANE_N*BLOCK_W,
	parameter XGMII_KEEP_W = LANE_N*KEEP_W,
	parameter CNT_N = BLOCK_W/XGMII_DATA_W,
	parameter CNT_W = $clog2( CNT_N ),
	parameter BLOCK_TYPE_W = 8,
	
	parameter PMA_DATA_W = 16, 
	parameter PMA_CNT_N  = XGMII_DATA_W/PMA_DATA_W
)(
	input clk,
	input nreset,

	// MAC
	input [LANE_N-1:0]       ctrl_v_i,
	input [LANE_N-1:0]       idle_v_i,
	input [LANE_N-1:0]       start_i,
	input [LANE_N-1:0]       term_i,
	input [LANE_N-1:0]       err_i,
	input [XGMII_DATA_W-1:0] data_i, // tx data
	input [XGMII_KEEP_W-1:0] keep_i,


	output                           ready_o,	
	// PMA
	output [PMA_CNT_N*PMA_DATA_W-1:0] data_o
);
localparam HEAD_W = 2;
localparam SEQ_W  = $clog2(BLOCK_W/HEAD_W+1);
// data
logic [XGMII_DATA_W-1:0] data_enc; // encoded
logic [XGMII_DATA_W-1:0] data_scram; // scrambled
// sync header is allways valid
logic [LANE_N*HEAD_W-1:0] sync_head;
// gearbox full has the same value every gearbox
// regardless of the lane, we can ignore all of them but 1
logic                     gearbox_full;

// pcs fsm
logic             seq_rst;
logic [SEQ_W-1:0] seq_next;
logic [SEQ_W-1:0] seq_inc;
logic             seq_inc_overflow;
reg   [SEQ_W-1:0] seq_q;

assign seq_rst = gearbox_full;
assign { seq_inc_overflow, seq_inc } = seq_q + {{SEQ_W-1{1'b0}} , 1'b1};
assign seq_next = seq_rst ? {SEQ_W{1'b0}} : seq_inc;
always @(posedge clk) begin
	if ( ~nreset ) begin
		seq_q <= {SEQ_W{1'b0}};
	end else begin
		seq_q <= seq_next;
	end
end

genvar l;
for( l = 0; l < LANE_N; l++ ) begin
// encode
pcs_enc_lite #(.DATA_W(BLOCK_W))
m_pcs_enc(
	.clk(clk),
	.nreset(nreset),

	.ctrl_v_i(ctrl_v_i[l]),
	.idle_v_i(idle_v_i[l]),
	.start_i(start_i[l]),
	.term_i(term_i[l]),
	.err_i(err_i[l]),
	.part_i(seq_q[CNT_W-1:0]),
	.data_i(data_i[l*BLOCK_W+BLOCK_W-1:l*BLOCK_W]), // tx data
	.keep_i(keep_i[l*KEEP_W+KEEP_W-1:l*KEEP_W]),
	.keep_next_i(),
	.head_v_o(sync_head_v[l]),
	.sync_head_o(sync_head[l*HEAD_W+HEAD_W-1:l*HEAD_W]), 
	.data_o(data_enc[l*BLOCK_W+BLOCK_W-1:l*BLOCK_W])	
);
// scramble
scrambler_64b66b_tx #(.LEN(BLOCK_W))
m_64b66b_tx(
	.clk(clk),
	.nreset(nreset),
	.data_i(data_enc[l*BLOCK_W+BLOCK_W-1:l*BLOCK_W]),
	.scram_o(data_scram[l*BLOCK_W+BLOCK_W-1:l*BLOCK_W])
);
// alignement marker

// gearbox
gearbox_tx #( .DATA_W(BLOCK_W))
m_gearbox_tx (
	.clk(clk),
	.nreset(nreset),
	.seq_i(seq_q),
	.head_i(sync_head[l*HEAD_W+HEAD_W-1:l*HEAD_W]),
	.data_i(data_scram),
	.full_v_o(gearbox_full),
	.data_o(data_o)
);
endgenerate

assign ready_o = ~gearbox_full[0];

endmodule
