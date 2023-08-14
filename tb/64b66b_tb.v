module lite_64b66b_tb;
localparam LEN = 32;
localparam TV_W = 64;

reg clk = 1'b0;
reg nreset;
logic                  valid_i;
logic [LEN-1:0] data_i;
logic [LEN-1:0] data_o;
logic [LEN-1:0] scram_o;

always #5 clk = ~clk;

logic [TV_W-1:0] tb_data  = 64'h1e ;
// expected output can be generated using the program
// located in `tb`
logic [TV_W-1:0] tb_scram = 64'h7bfff0800000001e;

initial begin
	$dumpfile("build/wave.vcd");
	$dumpvars(0, lite_64b66b_tb);
	nreset = 1'b0;
	#10
	nreset = 1'b1;
	// begin testing
	/* no support for this syntax on iverilog 
	for( int i = 0; i < (TV_W/BLOCKS); i ++) begin
		valid_i = 1'b1;
		data_i = tb_data[i*BLOCKS+BLOCKS-1:i*BLOCKS];
		#10
		$display("running scramble cycle %d",i);
	end*/
	valid_i = 1'b1;
	data_i = tb_data[31:0];
	#1
	assert(tb_scram[31:0] == scram_o[31:0]);
	#9
	data_i = tb_data[63:32];
	#1
	assert(tb_scram[63:32] == scram_o[31:0]);
	#9
	valid_i = 1'b0;
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
