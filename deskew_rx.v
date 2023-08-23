/* Buffers must contain at least as much as the max dynamic skew.
* The maxium skew is the largest difference in the fill level
* of the buffers at any time.
* Lane markers read out of each lane at the same time
*/
module deskew_rx #(
	parameter LANE_N = 4,
	parameter BLOCK_W = 66,
	/* max dynamic skew */
	parameter MAX_SKEW_BIT_N = 1856,
	parameter MAX_SKEW_BLOCK_N = ( MAX_SKEW_BIT_N - BLOCK_W -1 )/BLOCK_W
)(
	input clk,
	input nreset,

	input [LANE_N-1:0] valid_i, // valid blocks, signal_ok and block lock
	// alignement marker lock interface	
	input [LANE_N-1:0] am_lite_v_i,
	input [LANE_N-1:0] am_lite_lock_v_i, 
	
	// block data
	input [LANE_N*BLOCK_W-1:0] data_i,

	// deskewed alignement marker valid
	output                      am_v_o,
	// deskwed data	
	output [LANE_N*BLOCK_W-1:0] data_o
);
// identify slowest lane in order to find
// the alignement marker
logic [LANE_N-1:0] slow_lane;
assign am_v_o = |(am_lite_v_i & slow_lane);

logic am_lite_lock_full_v;
assign am_lite_lock_full_v = &( am_lite_lock_v_i & valid_i );
genvar l;
generate
	for(l=0; l<LANE_N; l++) begin
		// displatch data per lane
		deskew_lane_rx #(
			.BLOCK_W(BLOCK_W),
			.MAX_SKEW_BIT_N(MAX_SKEW_BIT_N),
			.MAX_SKEW_BLOCK_N(MAX_SKEW_BLOCK_N)
		)m_deskew_lane(
			.clk(clk),
			.nreset(nreset),
			.am_lite_v_i(am_lite_v_i[l]),
			//.am_lite_lock_lost_v_i(am_lite_lock_lost_v_i[l]),
			.am_lite_lock_full_v_i(am_lite_lock_full_v),
			.data_i(data_i[l*BLOCK_W+BLOCK_W-1:l*BLOCK_W]),
			.skew_zero_o(slow_lane[l]),
			.data_o(data_o[l*BLOCK_W+BLOCK_W-1:l*BLOCK_W])
		);
	end
endgenerate

endmodule
