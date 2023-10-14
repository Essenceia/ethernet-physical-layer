/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

/* Per lane deskew module.
* Buffers blocks to realign all lanes on the slowest.
* In order to save on buffer space we are discarding 
* the alignement marker at this stage. */
module deskew_lane_rx #(
	parameter BLOCK_W = 66,
	/* max dynamic skew */
	parameter MAX_SKEW_BIT_N = 1856,
	parameter MAX_SKEW_BLOCK_N = ( MAX_SKEW_BIT_N - BLOCK_W -1 )/BLOCK_W,
	parameter SKEW_CNT_W = $clog2(MAX_SKEW_BLOCK_N)
)(
	input clk,
	input nreset,

	/* Alignement marker lock */
	input am_lite_v_i, // alignement marker block valid this cycle
	//input am_lite_lock_lost_v_i, // am lock lost 
	input am_lite_lock_full_v_i, // all lanes have seen there alignement marker
	input [BLOCK_W-1:0] data_i,

	// skew offset is zero, used to identify lattest lane
	output               skew_zero_o,
	// deskewed lane data
	output [BLOCK_W-1:0] data_o 
);
// keep track of skew 
reg   [SKEW_CNT_W-1:0] skew_q;
logic [SKEW_CNT_W-1:0] skew_next;  
logic [SKEW_CNT_W-1:0] skew_add;  
logic                  unused_skew_add_of;  
logic skew_rst;
logic skew_en;

assign skew_rst = am_lite_v_i;

assign { unused_skew_add_of, skew_add } = skew_q + { {SKEW_CNT_W-1{1'b0}}, 1'b1};
assign skew_next = skew_rst ? {SKEW_CNT_W{1'b0}} : skew_add;
assign skew_en = ~am_lite_lock_full_v_i;
always @(posedge clk) begin
	if ( ~nreset ) begin
		skew_q <= '0;
	end else if ( skew_en ) begin
		skew_q <= skew_next;
	end
end

// shift buffer
logic [MAX_SKEW_BLOCK_N*BLOCK_W-1:0] buff_q;
logic [MAX_SKEW_BLOCK_N*BLOCK_W-1:0] buff_next; 

assign buff_next[BLOCK_W-1:0] = data_i;

genvar x;
generate
	for(x=1; x < MAX_SKEW_BLOCK_N; x++) begin
        assign buff_next[x*BLOCK_W+:BLOCK_W] = buff_q[(x-1)*BLOCK_W+:BLOCK_W];
	end
endgenerate

always_ff @(posedge clk) begin
	buff_q <= buff_next;
end

// skew is used as read pointer
logic [BLOCK_W-1:0] buff_rd;
always_comb begin
	/* default */
	buff_rd = {BLOCK_W{1'bx}};

	for(int j=0; j<MAX_SKEW_BLOCK_N; j++) begin
		if ( j == 0 )begin
			if( skew_q == 0) begin
				buff_rd = data_i;
			end
		end else begin
			/* verilator lint_off WIDTHEXPAND */
			if( skew_q == j ) begin
			/* verilator lint_on WIDTHEXPAND */
				 buff_rd = buff_q[j*BLOCK_W+:BLOCK_W];
			end
		end
	end
end
// output
assign skew_zero_o = ~|skew_q;

assign data_o = buff_rd;
endmodule
