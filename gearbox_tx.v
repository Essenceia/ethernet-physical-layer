/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

/* Generic circular buffer
* Expected parameters for data widths : 16,32, 64
* Tested parameters : 16, 64 */
module gearbox_tx #(
	parameter DATA_W = 64,
	parameter HEAD_W = 2
)(
	input clk,
	input nreset,

	input [HEAD_W-1:0] head_i, // sync header
	input [DATA_W-1:0] data_i,

	// gearbox output
	output              accept_v_o, // backpressure, buffer is full, need a cycle to clear 
	output [DATA_W-1:0] data_o
);
localparam FIFO_W  = DATA_W;
localparam SHIFT_N = DATA_W/HEAD_W;
localparam SEQ_W  = $clog2(DATA_W/HEAD_W+1);


logic             fifo_full;
logic             seq_rst;
logic [SEQ_W-1:0] seq_next;
logic [SEQ_W-1:0] seq_inc;
logic             unused_seq_inc_of;
reg   [SEQ_W-1:0] seq_q;

assign fifo_full = seq_q[SEQ_W-1];

/* seq fifo fill : gearbox state */
assign seq_rst = fifo_full;
assign { unused_seq_inc_of, seq_inc } = seq_q + {{SEQ_W-1{1'b0}} , 1'b1};
assign seq_next = seq_rst ? {SEQ_W{1'b0}} : seq_inc;

always @(posedge clk) begin
	if ( ~nreset ) begin
		seq_q <= { SEQ_W{1'b0}};
	end else begin
		seq_q <= seq_next;
	end
end

// current fifo depth is derrived from the sequence number
logic [FIFO_W-1:0] fifo_next;
reg   [FIFO_W-1:0] fifo_q;

// shift data
localparam MASK_ARR_W = FIFO_W / HEAD_W;

logic [SHIFT_N:0] shift_sel;

logic [FIFO_W-1:0] wr_fifo_shifted_arr[SHIFT_N-1:0];
logic [FIFO_W-1:0] rd_data_shifted_arr[SHIFT_N-1:0];
logic [FIFO_W-1:0] wr_fifo_shifted;
logic [FIFO_W-1:0] rd_data_shifted;

genvar i;
generate
	/* shift sel : dec to bin onehot */
	for( i = 0; i <=SHIFT_N; i++) begin : shift_sel_loop
		assign shift_sel[i] = ( seq_q == i );
	end

	/* read and write data shifted */
	for( i = 0; i < SHIFT_N; i++ ) begin : rd_data_shifted_loop
		/* block data to be written to fifo 
		 * seq 0 : write 2 msb bits to fifo 
		 * seq 1 : write 4 msb bits to fifo
		 * ...
	     * seq 31 : write 64 msb bits to fifo 
		 * seq 32 : X */
		assign wr_fifo_shifted_arr[i] = { {DATA_W-(i+1)*HEAD_W{1'bx}} , data_i[DATA_W-1:DATA_W - (i+1)*HEAD_W] };
	
		if ( i != SHIFT_N-1 ) begin : gen_lt_SHIFT_N
			assign rd_data_shifted_arr[i] = { data_i[DATA_W-HEAD_W-i*HEAD_W-1:0], head_i , {i*HEAD_W{1'bx}}} ;
			//assign rd_data_shifted_arr[0] = { data_i[DATA_W-HEAD_W-i*HEAD_W-1:0], head_i } ;
		end else begin : gen_eq_SHIFT_N
			assign rd_data_shifted_arr[i] = {  head_i , {i*HEAD_W{1'bx}} } ;
		end
	end
endgenerate

assign wr_fifo_shifted = wr_fifo_shifted_arr[seq_q[SEQ_W-2:0]];
assign rd_data_shifted = rd_data_shifted_arr[seq_q[SEQ_W-2:0]];

/* read fifo mask
 * seq 0 : nothing from fifo
 * seq 1 : read 2 bytes from fifo ( 1 i lite mask version )
 * seq 2 : read 4 bytes from fifo
 * ...
 * seq 32 : read 64 bytes from fifo ( entire content ) */
logic [MASK_ARR_W-1:0] rd_fifo_mask_lite;
logic unused_rd_fifo_mask_lite;

assign { unused_rd_fifo_mask_lite, rd_fifo_mask_lite } = shift_sel - {{SHIFT_N-1{1'b0}}, 1'b1};

// extend masks
logic [FIFO_W-1:0] rd_fifo_mask; // full version of the mask
generate
	for( i = 0; i < MASK_ARR_W; i++ ) begin : mask_loop
		assign rd_fifo_mask[i*HEAD_W+HEAD_W-1:i*HEAD_W] = {HEAD_W{rd_fifo_mask_lite[i] }};
	end
endgenerate

// buf data
assign fifo_next = wr_fifo_shifted;
always @(posedge clk) begin
	fifo_q <= fifo_next;
end

// buffer is full, tell mac to not send next cycle
assign accept_v_o = ~fifo_full;

assign data_o = rd_fifo_mask & fifo_q | ~rd_fifo_mask & rd_data_shifted;
endmodule
