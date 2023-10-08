/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

/* Buffers must contain at least as much as the max dynamic skew.
* The maxium skew is the largest difference in the fill level
* of the buffers at any time.
* Lane markers read out of each lane at the same time */
module deskew_rx #(
	parameter LANE_N = 4,
	parameter BLOCK_W = 66,
	/* max dynamic skew */
	parameter MAX_SKEW_BIT_N = 1856,
	parameter MAX_SKEW_BLOCK_N = ( MAX_SKEW_BIT_N - BLOCK_W -1 )/BLOCK_W
)(
	input clk,
	input nreset,

	/* Block sync */
	input [LANE_N-1:0] lock_v_i, // block lock and signal_ok
	
	/* Alignement marker lock */
	/* we are seeing an alignement marker on lane */	
	input [LANE_N-1:0] am_lite_v_i,
	/* lite lock, we have seen an valid alignement marker on this lane */
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
assign am_lite_lock_full_v = &( am_lite_lock_v_i & lock_v_i );
genvar l;
generate
	for(l=0; l<LANE_N; l++) begin : gen_deskew_lane
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
