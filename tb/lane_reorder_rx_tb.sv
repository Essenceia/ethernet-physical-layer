`define TB_LOOP_CNT 10

module lane_reorder_rx_tb;

localparam LANE_N = 4;
localparam LANE_W = $clog2(LANE_N);
localparam BLOCK_W = 66;

logic [LANE_N*LANE_N-1:0]  lane_i;
logic [LANE_N*BLOCK_W-1:0] block_i;
logic [LANE_N*BLOCK_W-1:0] block_o;

logic [LANE_N-1:0]  tb_lane_i [LANE_N-1:0];
logic [BLOCK_W-1:0] tb_block_i [LANE_N-1:0];
logic [BLOCK_W-1:0] tb_block_o [LANE_N-1:0];


// check if we get the correct data
// in output block
task check_correct_data();
	int idx;
	for( int i= 0; i < LANE_N; i++ ) begin
		idx =$clog2( tb_lane_i[i]);
		assert( tb_block_i[i] == tb_block_o[idx]);
	end
endtask

// Assign each block a unique re-order id and
// check if we get the correct data
task test_reorder();
	// each block needs a unique lane id
	// we are going to assign them sequentially
	// to make sure this constraint is respected
	logic [LANE_W-1:0] rand_lane;	
	rand_lane = $random;
	for(int i=0; i < LANE_N; i++ ) begin
		tb_lane_i[i] = ( 1 << rand_lane );
		rand_lane++;
	end
	
endtask

genvar x;
generate
	for(x=0; x<LANE_N; x++) begin
		assign lane_i[x*LANE_N+LANE_N-1:x*LANE_N]     = tb_lane_i[x];
		assign block_i[x*BLOCK_W+BLOCK_W-1:x*BLOCK_W] = tb_block_i[x];
		assign tb_block_o[x] = block_o[x*BLOCK_W+BLOCK_W-1:x*BLOCK_W];
	end
endgenerate

initial begin
	$dumpfile("build/wave.vcd");
	$dumpvars(0, lane_reorder_rx_tb);

	// test 1 : sending no valid data
	$display("test 1 %t", $time); 
	for(int i=0; i<LANE_N; i++) begin
		tb_lane_i[i] = '0;
		tb_block_i[i] = {$random, $random, $random };
	end
	#10
	assert($isunknown(block_o));
	
	// test 2 : sending valid data, see if the output
	// block is corrext
	$display("test 2 %t", $time); 
	for(int i=0; i < `TB_LOOP_CNT; i++) begin
		test_reorder();
		#10
		check_correct_data();
	end
	$display("Test finished");
	$finish;
end

lane_reorder_rx #(
	.LANE_N(LANE_N),
	.BLOCK_W(BLOCK_W)
)m_uut(
	.lane_i(lane_i),
	.block_i(block_i),
	.block_o(block_o)
);

endmodule
