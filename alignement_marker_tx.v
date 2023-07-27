module alignement_marker_tx(
	parameter LANE_N = 4,
	parameter BLOCK_W = 66
)(
	input clk,
	input nreset,

	input [LANE_N*BLOCK_W-1:0] data_i,

	output [LANE_N*BLOCK_W-1:0] data_o
);
localparam GAP_W = 14;
localparam [BLOCK_W-1:0]
 	// 0x90, 0x76, 0x47, BIP3 , 0x6F, 0x89, 0xB8, BIP7
	MARKER_LANE0 = { 8{1'bx},8'hb8, 8'h89,8'h6f,{8{1'bx}}, 8'h47, 8'h76, 8'h90 }
	// 0xF0, 0xC4, 0xE6, BIP3 , 0x0F, 0x3B, 0x19, BIP7
	MARKER_LANE1 = { 8{1'bx},8'h19, 8'h3b, 8'h0f, {8{1'bx}}, 8'he6, 8'hc4, 8'hf0 }
	// 0xC5, 0x65, 0x9B, BIP3 , 0x3A, 0x9A, 0x64, BIP7
	MARKER_LANE2 = { 8{1'bx},8'h64, 8'h9a, 8'h3a, {8{1'bx}}, 8'h9b, 8'h65, 8'hc5 }
	// 0xA2, 0x79, 0x3D, BIP3 , 0x5D, 0x86, 0xC2, BIP7
	MARKER_LANE3 = { 8{1'bx},8'hc2, 8'h86, 8'h5d, {8{1'bx}}, 8'h3d, 8'h79, 8'ha2 }
// number of cycles since last alignement marker
// count 16383 blocks between 2 makrets
// which is equivalent to the overflow on 14 bits
reg   [GAP_W-1:0] gap_q;
logic [GAP_W-1:0] gap_next;
logic [GAP_W-1:0] gap_add;
logic             gap_add_overflow;
assign { gap_add_overflow, gap_add } = gap_q + {{GAP_W-1{1'b0}}, 1'b1};
assign gap_next = add_market_v_q ? {GAP_W{1'b0}} : gap_q;
 
logic add_market_v_next;
reg   add_market_v_q;

assign add_market_v_next = gap_overflow;

always @(posedge clk) begin
	if ( ~nreset ) begin
		gap_q <= {GAP_W{1'b0}};
		add_market_v_q <= 1'b1;// add alignement market on reset
	end else begin
		gap_q <= gap_next;
		add_market_v_q <= add_market_v_next;
	end
end
//lane 0
alignement_marker_lane_tx #(.LANE_ENC(MARKER_LANE0))
m_market_lane0(
	.marker_v(add_market_v_q),
	.data_i(data_i[BLOCK_W-1:0]),	
	.data_o(data_o[BLOCK_W-1:0])	
);
//lane 1
alignement_marker_lane_tx #(.LANE_ENC(MARKER_LANE1))
m_market_lane1(
	.marker_v(add_market_v_q),
	.data_i(data_i[2*BLOCK_W-1:BLOCK_W]),	
	.data_o(data_o[2*BLOCK_W-1:BLOCK_W])	
);
//lane 2
alignement_marker_lane_tx #(.LANE_ENC(MARKER_LANE2))
m_market_lane2(
	.marker_v(add_market_v_q),
	.data_i(data_i[3*BLOCK_W-1:2*BLOCK_W]),	
	.data_o(data_o[3*BLOCK_W-1:2*BLOCK_W])	
);
//lane 3
alignement_marker_lane_tx #(.LANE_ENC(MARKER_LANE3))
m_market_lane3(
	.marker_v(add_market_v_q),
	.data_i(data_i[4*BLOCK_W-1:3*BLOCK_W]),	
	.data_o(data_o[4*BLOCK_W-1:3*BLOCK_W])	
);


endmodule
