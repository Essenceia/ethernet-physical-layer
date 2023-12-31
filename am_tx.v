/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */
/* Add alignement marker on tx pipe */
module am_tx #(
	parameter LANE_N = 4,
	parameter HEAD_W = 2,
	parameter DATA_W = 64,
	parameter [DATA_W-1:0]
 	// 0x90, 0x76, 0x47, BIP3 , 0x6F, 0x89, 0xB8, BIP7
	MARKER_LANE0 = { {8{1'bx}}, 8'hb8, 8'h89, 8'h6f, {8{1'bx}}, 8'h47, 8'h76, 8'h90 },
	// 0xF0, 0xC4, 0xE6, BIP3 , 0x0F, 0x3B, 0x19, BIP7
	MARKER_LANE1 = { {8{1'bx}}, 8'h19, 8'h3b, 8'h0f, {8{1'bx}}, 8'he6, 8'hc4, 8'hf0 },
	// 0xC5, 0x65, 0x9B, BIP3 , 0x3A, 0x9A, 0x64, BIP7
	MARKER_LANE2 = { {8{1'bx}}, 8'h64, 8'h9a, 8'h3a, {8{1'bx}}, 8'h9b, 8'h65, 8'hc5 },
	// 0xA2, 0x79, 0x3D, BIP3 , 0x5D, 0x86, 0xC2, BIP7
	MARKER_LANE3 = { {8{1'bx}}, 8'hc2, 8'h86, 8'h5d, {8{1'bx}}, 8'h3d, 8'h79, 8'ha2 },

	parameter [LANE_N*DATA_W-1:0] MARKER_LANE={ MARKER_LANE3, MARKER_LANE2, MARKER_LANE1, MARKER_LANE0}
)
(
	input clk,
	input nreset,

	/* Gearbox */
	input                      valid_i, /* accept data this cycle */
	output [LANE_N*HEAD_W-1:0] head_o,
	output [LANE_N*DATA_W-1:0] data_o,

	/* Encoder */ 
	input [LANE_N*HEAD_W-1:0]  head_i,

	/* Scrambler */
	input [LANE_N*DATA_W-1:0]  data_i,
	output                     marker_v_o
);
localparam GAP_W = 14;
// number of cycles since last alignement marker
// count 16383 blocks between 2 makrets
// which is equivalent to the overflow on 14 bits
reg   [GAP_W-1:0] gap_q;
logic [GAP_W-1:0] gap_next;
logic [GAP_W-1:0] gap_add;
logic             unused_gap_add_of;
assign { unused_gap_add_of, gap_add } = gap_q + {{GAP_W-1{1'b0}}, 1'b1};
assign gap_next = gap_add;
 
logic add_market_v_next;
reg   add_market_v_q;

// alginement marker is inserted every 16383 blocks's 
// 16383 = 2^14 - 1
assign add_market_v_next = &gap_q;

always @(posedge clk) begin
	if ( ~nreset ) begin
		// reset to 1 by default as 0 is the cycle were we
		// insert the aligment marker
		gap_q <= {{GAP_W-1{1'b0}}, 1'b1};
		add_market_v_q <= 1'b0;// don't add alignement market on reset
	end else if ( valid_i ) begin
		gap_q <= gap_next;
		add_market_v_q <= add_market_v_next;
	end
end

genvar i;
generate
for( i = 0; i < LANE_N; i++) begin : gen_am_lane_loop
	logic [DATA_W-1:0] data;
	logic [HEAD_W-1:0] head;
	logic [DATA_W-1:0] data_m;
	logic [HEAD_W-1:0] head_m;
	assign data = data_i[i*DATA_W+DATA_W-1:i*DATA_W];
	assign head = head_i[i*HEAD_W+HEAD_W-1:i*HEAD_W];	
	assign data_o[i*DATA_W+DATA_W-1:i*DATA_W] = data_m;
	assign head_o[i*HEAD_W+HEAD_W-1:i*HEAD_W] = head_m;
	am_lane_tx #(.LANE_ENC(MARKER_LANE[i*DATA_W+DATA_W-1:i*DATA_W]))
	m_market_lane(
		.clk(clk),
		.nreset(nreset),
		.marker_v(add_market_v_q),
		.valid_i(valid_i),
		.data_i({ data , head }),	
		.data_o({ data_m, head_m })	
	);
end
endgenerate

assign marker_v_o = add_market_v_q;

`ifdef FORMAL

always @(posedge clk) begin
	if( nreset ) begin
		// aligmenent marker added on sequence cnt 2^14 ( overlow )
		sva_marker_2_pow_14 : assert( ~marker_v_o | marker_v_o & gap_add_overflow );
		sva_marker_gap_zero : assert( ~marker_v_o | marker_v_o & ( gap_q == 0 ) );
	end
end
`endif
endmodule
