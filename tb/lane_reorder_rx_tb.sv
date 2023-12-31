/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

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
	/* verilator lint_off UNUSEDSIGNAL*/
	int idx;
	/* verilator lint_on UNUSEDSIGNAL*/
	for( int i= 0; i < LANE_N; i++ ) begin: check_data_idx_loop
		/* lane index is encoded on onehot
		 * get index of first 1 in onehot vector */
		idx =$clog2( tb_lane_i[i]);
		`ifdef DEBUG
		$display("check reorder data match for lane %d", idx);
		`endif
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
	rand_lane = LANE_W'($random % LANE_N);
	for(int i=0; i < LANE_N; i++ ) begin
		tb_lane_i[i] = ( 1 << rand_lane );
		`ifdef DEBUG
		$display("Rand lane set %d", tb_lane_i[i]);
		`endif
		rand_lane++;
	end
	
endtask

/* The following generate block isn't re-evaluated by verilator 
 * every cycle if the left hand side is written in a task. 
 * This isn't the case for iverilog, as such test fails with
 * verilator */
genvar x;
generate
	for(x=0; x<LANE_N; x++) begin
		assign lane_i[x*LANE_N+LANE_N-1:x*LANE_N]     = tb_lane_i[x];
		assign block_i[x*BLOCK_W+BLOCK_W-1:x*BLOCK_W] = tb_block_i[x];
		assign tb_block_o[x] = block_o[x*BLOCK_W+BLOCK_W-1:x*BLOCK_W];
	end
endgenerate

initial begin
	$dumpfile("wave/lane_reorder_rx_tb.vcd");
	$dumpvars(0, lane_reorder_rx_tb);

	`ifdef VERILATOR
	$display("ERROR : Test will fail on veriltor due to generate block assignations not being re-evaluated when driver is modified in task !");
	`endif
	// test 1 : sending no valid data
	$display("test 1 %t", $time); 
	for(int i=0; i<LANE_N; i++) begin
		tb_lane_i[i] = '0;
		tb_block_i[i] = BLOCK_W'({$random, $random, $random });
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
