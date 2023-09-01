/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */
 
`ifndef TB_LOOP_N
`define TB_LOOP_N 100 
`endif

module _64b66b_tb;
localparam LEN = 40;

/* known test vector, used in test 1 */
localparam TV_W = 64;

reg clk = 1'b0;
reg nreset;
logic           valid_i;
logic [LEN-1:0] data_i;
logic [LEN-1:0] data_o;
logic [LEN-1:0] scram_o;


/* debug signals
 * db_data_diff : check binary differences between 
 * original input to scrambler - descrambler pair 
 * and final output.
 * We expect there to be no difference */
logic [LEN-1:0] db_data_diff;

/*verilator lint_off BLKSEQ*/
always #5 clk = ~clk;
/*verilator lint_on BLKSEQ*/

logic [TV_W-1:0] tb_data  = 64'h1e ;
// expected output can be generated using the program
// located in `tb`
logic [TV_W-1:0] tb_scram = 64'h7bfff0800000001e;

// generate a random sequence and pass it though
// the scrambler and the de-scrambler.
// We expect the output to ultimatly 
// match the original data
task test_sramble_decramble(int loop_cnt);
	logic [LEN-1:0] test;
	
	for( int i = 0; i < loop_cnt; i++) begin
		test = set_test();
		data_i = test;
		#1
		assert(~|db_data_diff);
		#9
		/* randomly turn off valid */
		valid_i = $random;
	end
endtask

function logic [LEN-1:0] set_test();
	logic [LEN-1:0] tmp;
	if ( LEN <= 32 ) begin
		tmp = $random;
	end else begin
		for( int i=0; i < (LEN + LEN-1)/32; i++) begin
			tmp = ( tmp << 32 | $random );
		end
	end
	return tmp;
endfunction

assign db_data_diff = data_i ^ data_o; 

initial begin
	$dumpfile("wave/_64b66b_tb.vcd");
	$dumpvars(0, _64b66b_tb);
	nreset = 1'b0;
	#10
	nreset = 1'b1;
	// begin testing
	// test 1 : simple know correct test vector
	if ( LEN == 32 ) begin
		$display("test 1 %t", $time);
		valid_i = 1'b1;
		data_i = tb_data[31:0];
		#1
		assert(tb_scram[31:0] == scram_o[31:0]);
		#9
		data_i = tb_data[63:32];
		#1
		assert(tb_scram[63:32] == scram_o[31:0]);
		#9
		$display("test 1 : PASS");
	end else begin
	$display("test 1 : SKIP, LEN parameter not 32"); 
	end
	// test 2 : verify the output of the descambler
	// matches initial data
	$display("test 2 %t", $time);
	test_sramble_decramble(`TB_LOOP_N);

	#10
	$display("Test finished\n");
	$finish;
end

_64b66b_tx #( .LEN(LEN))
m_64b66b_tx(
	.clk(clk),
	.nreset(nreset),
	.valid_i(valid_i),
	.data_i(data_i),
	.scram_o(scram_o)
);


_64b66b_rx #( .LEN(LEN))
m_66b64b_rx(
	.clk(clk),
	.nreset(nreset),
	.valid_i(valid_i),
	.scram_i(scram_o),
	.data_o(data_o)
);
endmodule
