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
reg   [BLOCK_W-1:0] buff_q[MAX_SKEW_BLOCK_N-1:0];
logic [BLOCK_W-1:0] buff_next[MAX_SKEW_BLOCK_N-1:0]; 
assign buff_next[0] = data_i;
genvar i;
generate
	for(i=1; i < MAX_SKEW_BLOCK_N; i++ ) begin
		assign buff_next[i] = buff_q[i-1];
	end

	for(i=0; i < MAX_SKEW_BLOCK_N; i++) begin : loop_buff
		`ifdef DEBUG
		logic [BLOCK_W-1:0] db_buff_next;
		logic [BLOCK_W-1:0] db_buff_q;
		assign db_buff_next = buff_next[i];
		assign db_buff_q = buff_q[i];
		`endif	
		always @(posedge clk) begin
			buff_q[i] <= buff_next[i];
		end
	end
endgenerate

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
				 buff_rd = buff_q[j-1];
			end
			/* verilator lint_on WIDTHEXPAND */
		end
	end
end
// output
assign skew_zero_o = ~|skew_q;

assign data_o = buff_rd;
endmodule
