/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */
 
`define SYNC_CTRL 2'b10
`define SYNC_DATA 2'b01

`define TB_TEST3_LOOP 150

/* Testbench for RX frame sync */
module am_lock_rx_tb;

localparam HEAD_W = 2;
localparam DATA_W = 64;
localparam BLOCK_W = HEAD_W + DATA_W;
localparam [BLOCK_W-1:0]
	MARKER_LANE0 = { {8{1'bx}},8'hb8, 8'h89, 8'h6f, {8{1'bx}}, 8'h47, 8'h76, 8'h90 ,`SYNC_CTRL},
	MARKER_LANE1 = { {8{1'bx}},8'h19, 8'h3b, 8'h0f, {8{1'bx}}, 8'he6, 8'hc4, 8'hf0 ,`SYNC_CTRL},
	MARKER_LANE2 = { {8{1'bx}},8'h64, 8'h9a, 8'h3a, {8{1'bx}}, 8'h9b, 8'h65, 8'hc5 ,`SYNC_CTRL},
	MARKER_LANE3 = { {8{1'bx}},8'hc2, 8'h86, 8'h5d, {8{1'bx}}, 8'h3d, 8'h79, 8'ha2 ,`SYNC_CTRL};
localparam LANE_N = 4;
localparam LANE_W = $clog2(LANE_N);
localparam GAP_N = 16383;

reg   clk = 1'b0;
logic nreset; 
logic               valid_i;
logic               signal_v_i; // signal_ok
logic [BLOCK_W-1:0] block_i;
logic               slip_v_o; // slip_done
logic               lock_v_o; // rx_block_lock

/* verilator lint_off UNUSEDSIGNAL*/
logic               lite_am_v_o;
logic               lite_lock_v_o;
/* verilator lint_on UNUSEDSIGNAL*/

logic [LANE_N-1:0]  lane_o;

/* verilator lint_off BLKSEQ */
always clk = #5 ~clk;
/* verilator lint_on BLKSEQ */

logic [BLOCK_W-1:0] marker_lane[LANE_N-1:0];
assign marker_lane[0] = MARKER_LANE0;
assign marker_lane[1] = MARKER_LANE1;
assign marker_lane[2] = MARKER_LANE2;
assign marker_lane[3] = MARKER_LANE3;

task send_rand_block(int cycles);
	logic [HEAD_W-1:0] head;
	logic [DATA_W-1:0] data;
	for(int t=0; t<cycles; t++) begin
		#10	
		head = ( $random % 2 == 1 )? `SYNC_CTRL : `SYNC_DATA;
		data = { $random, $random };
		block_i = {data, head};
	end
endtask

task aquire_lock( input int extra_cycles, logic [LANE_W-1:0] lane );
	logic [HEAD_W-1:0] head;
	logic [DATA_W-1:0] data;
	// extra cycles should be smaller than the am gap
	assert( extra_cycles < GAP_N );
	// write first am 
	#10
	signal_v_i = 1'b1;
	block_i = marker_lane[lane];
	for(int t=0; t < GAP_N ; t++ ) begin
		#10
		head = ( $random % 2 == 1)? `SYNC_CTRL : `SYNC_DATA;
		data = { $random, $random };
		block_i = {data, head};
		// only sending valid lock's should never slip

		assert( ~slip_v_o );
	end
	// write second am
	#10
	block_i = marker_lane[lane];
	for(int t=0; t<extra_cycles; t++) begin
		#10	
		head = ( $random % 2 == 1)? `SYNC_CTRL : `SYNC_DATA;
		data = { $random, $random };
		block_i = {data, head};
		// lane has locked
		assert( lock_v_o);
		// correct lane 
		assert(lane_o[lane]);
	end
endtask

// increment lane index by 1 
function logic [LANE_W-1:0] inc_lane (logic [LANE_W-1:0] l);
	logic [LANE_W-1:0] inc;
	if ( LANE_W > 1 ) begin
	logic unused_inc_of;
	{ unused_inc_of, inc } = l + {{LANE_W-1{1'b0}}, 1'b1};
	end else begin
	inc = ~l;
	end
	return inc;
endfunction

logic [LANE_W-1:0] tb_lane;

initial begin
	$dumpfile("wave/am_lock_rx_tb.vcd");
	$dumpvars(0, am_lock_rx_tb);
	// AM_LOCK_INIT -> AM_RESET_CNT
	nreset = 1'b0;
	#10;
	nreset = 1'b1;
	valid_i = 1'b1;
	signal_v_i = 1'b1;
	block_i = {BLOCK_W{1'b0}};
	$display("Starting test");
	// test 1 
	// AM_RESET_CNT -> FIND_1ST -> COUNT_1 -> COMP_2ND -> 2_GOOD ->
	// COUNT_2
	// Begining simple lock process right after reset
	// sending 2 correct aligngment marker and checking
	// we have locked on correct lane
	$display("test 1 %t", $time);
	tb_lane = LANE_W'($random % LANE_N);
	aquire_lock(10, tb_lane);

	// test 2
	// COUNT_2 -> SLIP
	// Send random data and send 4 invalid am to provoque slip
	$display("test 2 %t", $time);
	send_rand_block( GAP_N*4 );
	assert(slip_v_o);
	assert(~lock_v_o);
	
	// test 3
	// RESET -> COMP_2ND -> SLIP 
	// Send 2 valid am but each for a different lanes
	$display("test 3 %t", $time);
	#10
	tb_lane = LANE_W'($random % LANE_N);
	block_i = marker_lane[tb_lane];
	send_rand_block(GAP_N);
	#10
	tb_lane = inc_lane(tb_lane);
	block_i = marker_lane[tb_lane];
	#1
	assert(slip_v_o);
	#9
	assert(~lock_v_o);	

	// test 4
	// Lose signal on SLIP/RST
	$display("test 4 %t", $time);
	#10
	signal_v_i = 1'b0;	
	#1
	assert(~slip_v_o);
	#9
	assert(~lock_v_o);

	// test 5 
	// Find 1 and then lose signal	
	$display("test 5 %t", $time);
	#10
	signal_v_i = 1'b1;
	block_i = marker_lane[tb_lane];
	#1
	assert(~slip_v_o);
	#9
	signal_v_i = 1'b0;
	#1
	assert(~slip_v_o);
	#9
	
	// test 6
	// Lock on lane then lose signal 
	$display("test 6 %t", $time);
	signal_v_i = 1'b1;	
	aquire_lock(1, tb_lane);
	assert(~slip_v_o);
	assert(lock_v_o);
	assert(lane_o[tb_lane]);
	#10
	signal_v_i = 1'b0;
	#1
	assert(~slip_v_o);
	#9
	assert(~lock_v_o);	
		
	$display("Test finished");
	$finish;
end

am_lock_rx #(.BLOCK_W(BLOCK_W), .LANE_N(LANE_N))
m_uut(
	.clk(clk),
	.nreset(nreset),
	.valid_i(valid_i),
	.signal_v_i(signal_v_i),
	.block_i(block_i),
	.lock_v_o(lock_v_o),
	
	.lite_am_v_o(lite_am_v_o),
	.lite_lock_v_o(lite_lock_v_o),

	.lane_o(lane_o)
);

/* Slip signal is no longer used in top but is quite
 * usefull for debug, faking output signal */
assign slip_v_o = m_uut.slip_v;

endmodule
