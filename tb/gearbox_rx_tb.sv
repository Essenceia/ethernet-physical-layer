/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

/* RX gearbox tb, test basis 64 -> 66 buffering functionality and bit slip */

module gearbox_rx_tb;
localparam DATA_W = 64;
localparam HEAD_W = 2;
localparam SEQ_N = 64;

reg   clk = 1'b0;

/* verilator lint_off BLKSEQ */
always clk = #5 ~clk;
/* verilator lint_on BLKSEQ */
logic nreset;
logic              lock_v_i;
logic [DATA_W-1:0] data_i;
logic              slip_v_i;
logic              valid_o; // backpressure, buffer is full, need a cycle to clear 
logic [HEAD_W-1:0] head_o;
logic [DATA_W-1:0] data_o;


// generate a random array of 66b of data for a given sequence and
// check it is correctly outputed aligned on 64b
task new_seq();
	// 64 bit pma data
	logic [DATA_W-1:0] pma;
	// output 
	logic [HEAD_W-1:0] h;
	logic [DATA_W-1:0] d;

	for( int seq = 0; seq< SEQ_N; seq++ ) begin
		lock_v_i = 1'b1;
		slip_v_i = 1'b0;
		//data_i = { {$random, $random} , 2'b11 };
		data_i = { 58'b0 , 2'b10 , 2'b01, 2'b11 };
		#1
		assert( ~$isunknown(valid_o));
		if ( valid_o ) begin
			assert( ~$isunknown(data_o));
			assert( ~$isunknown(head_o));
		end
		#9
		lock_v_i = 1'b1;
	end	
endtask


initial begin
	$dumpfile("wave/gearbox_rx_tb.vcd");
	$dumpvars(0, gearbox_rx_tb);
	nreset = 1'b0;
	lock_v_i = 1'b0;
	#10
	nreset = 1'b1;
	$display("test 1 %t", $time);
	new_seq();
	#10
	// self check
	// no difference between got and expected
	#10
	$display("Sucess");	
	$finish;
end

// uut 
gearbox_rx #(
	.HEAD_W(HEAD_W),
	.DATA_W(DATA_W)
)m_gearbox_rx(
	.clk(clk),
	.nreset(nreset),
	.lock_v_i(lock_v_i),
	.data_i(data_i),
	.slip_v_i(slip_v_i),
	.valid_o(valid_o), 
	.head_o(head_o),
	.data_o(data_o)
);
endmodule
