/* PCS on the transmission path 
 * 
 * This module does not support a configurable data width,
 * it expects 256b of data from the mac every cycle.
 *
 * The meaning of "lane" is difference for 40g than 10g.
 * In 10g each block had 2x4 lanes, in 40g the xgmii data
 * is composed of 4 lanes of 1 block width.
 * */
module pcs_tx#(
	parameter IS_10G = 0,
	parameter LANE_N = IS_10G ? 1 : 4,
	parameter DATA_W = 64,
	parameter HEAD_W = 2,
	parameter BLOCK_W = DATA_W+HEAD_W,
	parameter KEEP_W = DATA_W/8,
	parameter LANE0_CNT_N = IS_10G ? 2 : 1,
	parameter XGMII_DATA_W = LANE_N*DATA_W,
	parameter XGMII_KEEP_W = LANE_N*KEEP_W
)(
	input clk,
	input nreset,

	// MAC
	input [LANE_N-1:0]             ctrl_v_i,
	input [LANE_N-1:0]             idle_v_i,
	input [LANE_N*LANE0_CNT_N-1:0] start_v_i,
	input [LANE_N-1:0]             term_v_i,
	input [LANE_N-1:0]             err_v_i,
	input [XGMII_DATA_W-1:0]       data_i, // tx data
	input [XGMII_KEEP_W-1:0]       keep_i,


	output                        ready_o,// am_v not used in 10GBASE_R mode	
	// gearbox
	output [LANE_N*BLOCK_W-1:0]   data_o
);
localparam SEQ_W  = $clog2(DATA_W/HEAD_W+1);
// encoder
logic [LANE_N-1:0]       unused_enc_head_v;
logic [XGMII_DATA_W-1:0] data_enc; // encoded

// scrambler
logic [XGMII_DATA_W-1:0] data_scram; // scrambled

if ( IS_10G==0 ) begin
end

// sync header is allways valid
logic [LANE_N*HEAD_W-1:0] sync_head;
logic [LANE_N*HEAD_W-1:0] sync_head_mark;

// gearbox 

/* gearbox full has the same value every gearbox
* regardless of the lane, we can ignore all of them 
* but 1 as long as we are sending all the data blocks
* within the same cycle, this may be changed in future
* versions */
/* verilator lint_off UNUSEDSIGNAL*/
logic [LANE_N-1:0] gearbox_full;
/* verilator lint_on UNUSEDSIGNAL*/


// pcs fsm
logic             seq_rst;
logic [SEQ_W-1:0] seq_next;
logic [SEQ_W-1:0] seq_inc;
logic             unused_seq_inc_of;
reg   [SEQ_W-1:0] seq_q;

assign seq_rst = gearbox_full[0];
assign { unused_seq_inc_of, seq_inc } = seq_q + {{SEQ_W-1{1'b0}} , 1'b1};
assign seq_next = seq_rst ? {SEQ_W{1'b0}} : seq_inc;
always @(posedge clk) begin
	if ( ~nreset ) begin
		seq_q <= {SEQ_W{1'b0}};
	end else begin
		seq_q <= seq_next;
	end
end

genvar l;
generate
for( l = 0; l < LANE_N; l++ ) begin :enc_lane_loop
	// encode
	pcs_enc_lite #(.DATA_W(DATA_W), .IS_10G(IS_10G))
	m_pcs_enc(
		.ctrl_v_i(ctrl_v_i[l]),
		.idle_v_i(idle_v_i[l]),
		.start_v_i(start_v_i[l*LANE0_CNT_N+LANE0_CNT_N-1:l*LANE0_CNT_N]),
		.term_v_i(term_v_i[l]),
		.err_v_i(err_v_i[l]),
		.part_i('0),
		.data_i(data_i[l*DATA_W+DATA_W-1:l*DATA_W]), // tx data
		.keep_i(keep_i[l*KEEP_W+KEEP_W-1:l*KEEP_W]),
		.keep_next_i('X),
		.head_v_o(unused_enc_head_v[l]),
		.sync_head_o(sync_head[l*HEAD_W+HEAD_W-1:l*HEAD_W]), 
		.data_o(data_enc[l*DATA_W+DATA_W-1:l*DATA_W])	
	);
end
endgenerate

// scramble
_64b66b_tx #(.LEN(XGMII_DATA_W))
m_64b66b_tx(
	.clk(clk),
	.nreset(nreset),
	.data_i (data_enc  ),
	.scram_o(data_scram)
);

if ( !IS_10G ) begin
	// alignement marker
	logic                    marker_v;
	logic [XGMII_DATA_W-1:0] data_mark; 
	
	// add align marker
	am_tx #(.LANE_N(LANE_N), .HEAD_W( HEAD_W ), .DATA_W(DATA_W))
	m_align_market(
		.clk(clk),
		.nreset(nreset),
		.head_i(sync_head),
		.data_i(data_scram ),
		.marker_v_o(marker_v),
		.head_o(sync_head_mark ),
		.data_o(data_mark )
	);

	// output data : marked data
	for(l=0; l<LANE_N; l++) begin
		assign data_o[l*BLOCK_W+BLOCK_W-1:l*BLOCK_W] = { data_mark[l*DATA_W+DATA_W-1:l*DATA_W], sync_head_mark[l*HEAD_W+HEAD_W-1:l*HEAD_W] };
	end
	assign ready_o = ~marker_v;

end else begin
	// output data : scrambled data
	for(l=0; l<LANE_N; l++) begin
		assign data_o[l*BLOCK_W+BLOCK_W-1:l*BLOCK_W] = { data_scram[l*DATA_W+DATA_W-1:l*DATA_W], sync_head[l*HEAD_W+HEAD_W-1:l*HEAD_W] };
	end
	/* PCS is non blocking in 10G mode
	* The only case where the PCS becomes blocking is when we
	* are adding the alignement marker.
	* And, as there is no alignement marker for 10GBASE and this
	* signal is not expected to be used in this configuration */
	assign ready_o = 1'bX;
end //!IS_10G

`ifdef FORMAL

always @(posedge clk) begin
	// gearbox state should be the same regardless of the lane
	// when we send all the data within the same cycle
	if ( CNT_N == 1 ) begin
		for(l=0; l<LANE_N; l++) begin
			assert ( gearbox_full[0] == gearbox_full[l]);
		end
	end
	
end
`endif
endmodule
