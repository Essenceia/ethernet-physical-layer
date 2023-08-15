module deskew_rx_tb;
localparam LANE_N = 4;
localparam BLOCK_W = 66;
localparam MAX_SKEW_BIT_N = 1856;
localparam MAX_SKEW_BLOCK_N = ( MAX_SKEW_BIT_N - BLOCK_W -1 )/BLOCK_W;

reg clk = 1'b0; 
logic nreset;

logic [LANE_N-1:0] valid_i;
logic [LANE_N-1:0] am_slip_v_i; 
logic [LANE_N-1:0] am_lock_v_i;
logic [LANE_N*BLOCK_W-1:0] data_i;
logic [LANE_N*BLOCK_W-1:0] data_o;

logic [BLOCK_W-1:0] tb_data_i[LANE_N-1:0];
logic [BLOCK_W-1:0] tb_data_o[LANE_N-1:0];


always clk = #5 ~clk;

`ifdef NOT_IVERILOG
// iverilog doesn't have support for this yet
// error :
// sorry: Subroutine ports with unpacked dimensions are not yet supported.

typedef int skew_arr_t[LANE_N];
skew_arr_t skew;

function skew_arr_t create_skew();
	skew_arr_t arr;
	for(int i=0; i<LANE_N; i++)begin
		arr[i] = $random % MAX_SKEW_BLOCK_N;
	end
	return arr;
endfunction
`else
int skew[LANE_N];
int skew_max = 4;
task create_skew();
	for(int i=0; i < LANE_N; i++ ) begin
		skew[i] = i+1;
	end	
endtask
`endif

task simulate_skew();
	assert( skew_max <= MAX_SKEW_BLOCK_N );

	valid_i = {LANE_N{1'b1}};
	for(int j=0; j < skew_max; j++ ) begin
		for(int i=0; i< LANE_N; i++) begin
			#10;
			tb_data_i[i] = { $random, $random, $random };
			if ( j >= skew[i] ) begin
				am_slip_v_i[i] = 1'b1;
				am_lock_v_i[i] = 1'b0;
				tb_data_i[i] = {BLOCK_W{1'b1}};
			end else begin
				am_slip_v_i[i] = 1'b0;
				am_lock_v_i[i] = 1'b1;
			end
		end	
	end
endtask

genvar i;
generate
	for(i=0; i< LANE_N; i++) begin
		assign data_i[i*BLOCK_W+BLOCK_W-1:i*BLOCK_W] = tb_data_i[i];
		assign tb_data_o[i] = data_o[i*BLOCK_W+BLOCK_W-1:i*BLOCK_W];
	end
endgenerate

initial begin
	$dumpfile("build/wave.vcd");
	$dumpvars(0, deskew_rx_tb);
	nreset = 1'b0;
	#10;
	nreset = 1'b1;
	create_skew();
	valid_i = '0;
	am_slip_v_i = '0;
	am_lock_v_i = '0;

	// test 1 
	$display("Test 1 %t", $time);
	simulate_skew();
	
	$display("Test finished");
	$finish;
end

deskew_rx #(
	.LANE_N(LANE_N),
	.BLOCK_W(BLOCK_W),
	.MAX_SKEW_BIT_N(MAX_SKEW_BIT_N)
)m_deskew_rx(
	.clk(clk),
	.nreset(nreset),
	.valid_i(valid_i),
	.am_slip_v_i(am_slip_v_i),
	.am_lock_v_i(am_lock_v_i),
	.data_i(data_i),
	.data_o(data_o)
);
endmodule
