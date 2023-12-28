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

	/* pma */
	input              lock_v_i,
	input [DATA_W-1:0] data_i,
	/* block sync */
	input              slip_v_i,

	/* to block sync */
	output              valid_o, // output data is valid : backpressure, buffer is full, need a cycle to clear 
	output [HEAD_W-1:0] head_o,
	output [DATA_W-1:0] data_o
);
localparam BLOCK_W = DATA_W + HEAD_W;

localparam FIFO_W = DATA_W;
localparam SHIFT_N = FIFO_W;

localparam CNT_W = $clog2(SHIFT_N+1);


logic [FIFO_W-1:0] wr_fifo_shifted_arr[SHIFT_N-1:0];
logic [FIFO_W-1:0] wr_fifo_shifted; // write data to write into fifo register

logic [BLOCK_W-1:0] rd_data_shifted_arr[SHIFT_N:1];
logic [BLOCK_W-1:0] rd_data_shifted;

genvar i;
generate
	for( i = 0; i < SHIFT_N; i++ ) begin : wr_fifo_shifted_loop
		/* wr fifo data shifted
	 	 * seq_q 0 : write all of data into fifo */	
		assign wr_fifo_shifted_arr[i] = { {i{1'bx}}, data_i[DATA_W-1:i] };
	end
	for( i = 1; i <= SHIFT_N; i++ ) begin : rd_shifted_loop
		// rd data and mask
		assign rd_data_shifted_arr[i] = { data_i[0+:i], {BLOCK_W-i{1'bx}}}; 
	end
	
endgenerate

// sequence
localparam INC_W = $clog2( HEAD_W + 2);
reg   [CNT_W-1:0] seq_q;
logic [CNT_W-1:0] seq_next;
logic [CNT_W-1:0] seq_xor;
logic             seq_rst;
logic [CNT_W-1:0] seq_add;
logic [INC_W-1:0] seq_inc;
logic             unused_seq_add_of;

/* increment by 2 or 3 sequence counter bepending on if we are
 * slipping the lsb */
assign seq_inc = { 1'b1, slip_v_i };
assign {unused_seq_add_of, seq_add } = seq_q + { {CNT_W-INC_W{1'b0}}, seq_inc };

/* reset sequence */
assign seq_rst = ~lock_v_i;

/* reset to zero, and set next to mod % 64 when seq_q >= 64 to keep slip offset */
assign seq_next = {CNT_W{~seq_rst}} & (seq_add & ~{{CNT_W-1{seq_q[CNT_W-1]}},1'b0}) ; 
 
always @(posedge clk) begin
	if ( ~nreset ) begin
		seq_q <= {CNT_W{1'b0}};
	end else begin
		seq_q <= seq_next;
	end
end

logic [SHIFT_N:0] shift_sel;
generate
	for( i = 0; i <= SHIFT_N; i++) begin : shift_sel_loop
		/* verilator lint_off WIDTHEXPAND */
		assign shift_sel[i] = ( seq_q == i );
		/* verilator lint_on WIDTHEXPAND */
	end

logic              unused_rd_data_mask_rev;
logic [DATA_W-1:0] rd_data_mask_rev; // reversed verson of the data mask
logic [BLOCK_W-1:0] rd_data_mask; // full version of the mask

assign {unused_rd_data_mask_rev, rd_data_mask_rev} = shift_sel - {{DATA_W-1{1'b0}}, 1'b1};

assign rd_data_mask[HEAD_W-1:0] = {HEAD_W{1'b0}};
for(i=HEAD_W; i< BLOCK_W; i++) begin: rd_data_mask_reverse
	assign rd_data_mask[i] = rd_data_mask_rev[BLOCK_W-i-1];
end

endgenerate 

always_comb begin : rd_wr_shift_sel

	// rd mask and data
	rd_data_shifted = {BLOCK_W{1'bx}};
	for( int x=1; x <=SHIFT_N; x++) begin
		/* setting default state to prevent latch inference */
		if ( shift_sel[x] ) rd_data_shifted = rd_data_shifted_arr[x];
	end
end

assign wr_fifo_shifted = wr_fifo_shifted_arr[seq_q[CNT_W-2:0]];

// buf data
reg   [FIFO_W-1:0] fifo_q;
logic [FIFO_W-1:0] fifo_next;

assign fifo_next = wr_fifo_shifted;
always @(posedge clk) begin
	fifo_q <= fifo_next;
end

// reassemble output data
logic [BLOCK_W-1:0] block;


assign block = rd_data_mask & rd_data_shifted
			 |~rd_data_mask & {2'bx, fifo_q};

assign valid_o = |seq_q[CNT_W-1:1]; // cnt_q > 1

assign { data_o, head_o } = block; 

endmodule
