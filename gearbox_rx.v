/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

/* Rx gearbox, accepts 64 bits and produces 66 */
module gearbox_rx #(
	parameter HEAD_W = 2,
	parameter DATA_W = 64
)(
	input clk,
	input nreset,

	input [DATA_W-1:0] data_i,

	// gearbox output
	output              valid_o, // backpressure, buffer is full, need a cycle to clear 
	output [HEAD_W-1:0] head_o,
	output [DATA_W-1:0] data_o
);
localparam BLOCK_DATA_W = DATA_W + HEAD_W;

localparam FIFO_W = DATA_W;
localparam SHIFT_N = DATA_W / HEAD_W;

localparam CNT_W = $clog2(SHIFT_N+1);

// current fifo depth is derrived from the sequence number
logic [FIFO_W-1:0] fifo_next;
reg   [FIFO_W-1:0] fifo_q;

// input sync header is valid
logic head_v;

generate

if ( DATA_W == BLOCK_DATA_W ) begin : gen_data_w_eq_block_w_head_v
	assign head_v = 1'b1;
end else begin : gen_data_w_neq_block_w_head_v
	assign head_v = ~|seq_i[CNT_W:0];
end

endgenerate

// shift data
localparam MASK_ARR_W = FIFO_W / HEAD_W;

logic [SHIFT_N:0] shift_sel;
logic [FIFO_W-1:0] wr_fifo_shifted_arr[SHIFT_N-1:0];
logic [FIFO_W-1:0] wr_data_shifted; // write data to write into fifo register
logic [MASK_ARR_W-1:0] wr_mask_lite_shifted_arr[SHIFT_N-1:0];

logic [BLOCK_DATA_W-1:0] rd_data_shifted_arr[SHIFT_N-1:1];
logic [BLOCK_DATA_W-1:0] rd_data_shifted;

logic [MASK_ARR_W-1:0] rd_fifo_mask_lite_arr[SHIFT_N-1:0];
logic [MASK_ARR_W-1:0] rd_fifo_mask_lite;
logic [FIFO_W-1:0]     rd_fifo_mask; // full version of the mask

genvar i;
generate
	for( i = 0; i < SHIFT_N; i++ ) begin : wr_fifo_shifted_loop
		// wr fifo
		if ( i == 0 ) begin : i_eq_zero
			assign wr_fifo_shifted_arr[i] = data_i;
		end else begin : i_gt_zero
			assign wr_fifo_shifted_arr[i] = { {i*HEAD_W{1'bx}}, data_i[DATA_W-1:DATA_W - i*HEAD_W] };
		end	
	end
	
	for( i = 1; i < SHIFT_N; i++ ) begin : rd_shifted_loop
		// rd data and mask
		assign rd_data_shifted_arr[i] = { data_i[0+:i*HEAD], {BLOCK_DATA_W-i*HEAD_W{1'bx}}}; 
		assign rd_fifo_mask_lite_arr[i] = { {i{1'b0}}, {MASK_ARR_W - i{1'b1}}};
	end
	
	for( i = 0; i <=SHIFT_N; i++) begin : shift_sel_loop
		assign shift_sel[i] = ( seq_i == i );
	end
endgenerate

always_comb begin
	// wr fifo
	for( int x=0; x < SHIFT_N; x++) begin
		if ( shift_sel[x] ) wr_fifo_shifted = wr_fifo_shifted_arr[x];
	end
	// rd mask 
	for( int x=1; x < SHIFT_N; x++) begin
		/* setting default state to prevent latch inference */
		if ( shift_sel[x] ) rd_data_shifted = rd_data_shifted_arr[x];
		if ( shift_sel[x] ) rd_fifo_mask_lite = rd_fifo_mask_lite_arr[x];
	end
end
// extend masks
generate
	for( i = 0; i < MASK_ARR_W; i++ ) begin : mask_loop
		assign rd_fifo_mask[i*HEAD_W+HEAD_W-1:i*HEAD_W] = {HEAD_W{rd_fifo_mask_lite_shifted[i] }};
	end
endgenerate
// buf data
assign fifo_next = wr_data_shifted;
always @(posedge clk) begin
	fifo_q <= fifo_next;
end

assign valid_o = ~|cnt_q; // cnt_q == 0

assign data_o = rd_fifo_mask & fifo_q | ~rd_fifo_mask & rd_data_shifted;
endmodule
