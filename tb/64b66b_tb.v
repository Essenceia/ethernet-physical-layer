`define TB_LOOP_CNT 100 

module lite_64b66b_tb;
localparam LEN = 32;
localparam TV_W = 64;

reg clk = 1'b0;
reg nreset;
logic                  valid_i;
logic [LEN-1:0] data_i;
logic [LEN-1:0] data_o;
logic [LEN-1:0] scram_o;
logic [LEN-1:0] data_diff;

always #5 clk = ~clk;

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
	test = $random;
	for( int i = 0; i < loop_cnt; i++) begin
		data_i = test;
		#1
		assert(data_o == data_i);
		#9
		test = $random;
	end
endtask

assign data_diff = data_i ^ data_o; 

initial begin
	$dumpfile("build/wave.vcd");
	$dumpvars(0, lite_64b66b_tb);
	nreset = 1'b0;
	#10
	nreset = 1'b1;
	// begin testing
	// test 1 : simple know correct test vector
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

	// test 2 : verify the output of the descambler
	// matches initial data
	test_sramble_decramble(`TB_LOOP_CNT);

	#10
	$display("Test finished");
	$finish;
end

scrambler_64b66b_tx #( .LEN(LEN))
m_64b66b_tx(
	.clk(clk),
	.nreset(nreset),
	.valid_i(valid_i),
	.data_i(data_i),
	.scram_o(scram_o)
);


descrambler_64b66b_rx #( .LEN(LEN))
m_66b64b_rx(
	.clk(clk),
	.nreset(nreset),
	.valid_i(valid_i),
	.scram_i(scram_o),
	.data_o(data_o)
);
endmodule
