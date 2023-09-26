/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

/* Reorder input block data to correct lane based on `lane_i` indicator. */
module lane_reorder_rx#(
	parameter LANE_N = 4,
	parameter BLOCK_W = 66
)(
	`ifdef FORMAL
	input clk,
	`endif
	// lane identifier : onehot  
	input [LANE_N*LANE_N-1:0] lane_i,
	// unordered block
 	input [LANE_N*BLOCK_W-1:0] block_i,

	// reordered block
	output logic [LANE_N*BLOCK_W-1:0] block_o
);

// unordered blocks
logic [BLOCK_W-1:0] block[LANE_N-1:0];
// re-order results
logic [BLOCK_W-1:0] res[LANE_N-1:0];

genvar x;
generate
	for(x=0; x<LANE_N; x++) begin : gen_block_loop
		assign block[x] = block_i[x*BLOCK_W+BLOCK_W-1:x*BLOCK_W];
		assign block_o[x*BLOCK_W+BLOCK_W-1:x*BLOCK_W] = res[x];
	end
endgenerate

/* re-order lane based on content of `lane_i`,
 * if we have no match ( lane_i[i] == '0 ) drive 'X
 * as default value */
always_comb begin
	for(int i=0; i< LANE_N; i++) begin
		res[i] = {BLOCK_W{1'bx}};
		for(int j=0; j< LANE_N;j++) begin
			if(lane_i[i*LANE_N+j] == 1'b1) res[j] = block[i];	
		end
	end
end


`ifdef FORMAL
always @(posedge clk) begin
	generate
		for(i=0; i<LANE_N;i++) begin
		// lane onehot
		assert($onehot0(lane_i[i*LANE_N+LANE-1:i*LANE_N]);
		end
	endgenerate
end
`endif
endmodule
