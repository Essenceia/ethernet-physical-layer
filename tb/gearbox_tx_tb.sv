/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

module gearbox_tx_tb;
localparam DATA_W = 64;
localparam HEAD_W = 2;
localparam SEQ_N = DATA_W/HEAD_W;
localparam BLOCK_W = HEAD_W + DATA_W;
localparam TB_BUF_W = SEQ_N * ( BLOCK_W );

reg   clk = 1'b0;
logic nreset;

logic [HEAD_W-1:0] head_i;
logic [DATA_W-1:0] data_i;
logic              accept_v_o; // backpressure, buffer is full, need a cycle to clear 
logic [DATA_W-1:0] data_o;

logic [TB_BUF_W-1:0] tb_buf;
logic [BLOCK_W-1:0]  tb_block;
reg   [TB_BUF_W-1:0] got_buf;
logic [TB_BUF_W-1:0] db_buf_diff;
/* verilator lint_off UNUSEDSIGNAL */
reg   [BLOCK_W-1:0]  got_buf_arr[SEQ_N-1:0];
/* verilator lint_on UNUSEDSIGNAL */

/* verilator lint_off BLKSEQ */
always clk = #5 ~clk;
/* verilator lint_on BLKSEQ */

// generate a random array of 66b of data for a given sequence and
// check it is correctly outputed aligned on 64b
task new_seq();
	// set default values
	logic [HEAD_W-1:0] h;
	logic [DATA_W-1:0] d;
	for( int seq = 0; seq< SEQ_N; seq++ ) begin
		h = 2'b11;
		//d = { $random(), $random() };
		d = 64'hfedcba9876543210;;
		// fill tb buffer
		tb_block = { d, h };
		tb_buf = { tb_block, tb_buf[TB_BUF_W-1:BLOCK_W] };
		// drive uut
		head_i = h;
		data_i = d;
		#1
		assert(accept_v_o);
		$display("Seq %d seq_q %d", seq, m_gearbox_tx.seq_q);
		#9
		h = 2'b10;
	end	
	assert(~accept_v_o);
endtask

always @(posedge clk) begin
	got_buf <= { data_o, got_buf[TB_BUF_W-1:DATA_W]};	
end

genvar x;
generate
	for(x=0; x< SEQ_N; x++)begin
		assign got_buf_arr[x] = got_buf[x*BLOCK_W+:BLOCK_W];
	end
endgenerate

assign db_buf_diff = got_buf ^ tb_buf; 

initial begin
	$dumpfile("wave/gearbox_tx_tb.vcd");
	$dumpvars(0, gearbox_tx_tb);
	nreset = 1'b0;
	#10
	nreset = 1'b1;
	$display("test 1 %t", $time);
	new_seq();
	#10
	// self check
	// no difference between got and expected
	assert( ~|db_buf_diff );
	#10
	$display("Sucess");	
	$finish;
end

always @(posedge clk) begin
	if ( nreset ) begin
		assert( ~$isunknown( data_o ));
	end
end

// uut 
gearbox_tx #(.DATA_W(DATA_W))
m_gearbox_tx(
.clk(clk),
.nreset(nreset),

.head_i(head_i),
.data_i(data_i),
.accept_v_o(accept_v_o),
.data_o(data_o)
);
endmodule
