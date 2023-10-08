/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

`define TB_LOOP_CNT 3
`define TB_MARKER {BLOCK_W{1'b1}}
`define SYNC_CTRL 2'b10
`define SYNC_DATA 2'b01
`define TB_SKEW_RANGE 5

module deskew_rx_tb;
localparam LANE_N = 4;
localparam BLOCK_W = 66;
localparam MAX_SKEW_BIT_N = 1856;
localparam MAX_SKEW_BLOCK_N = ( MAX_SKEW_BIT_N - BLOCK_W -1 )/BLOCK_W;
localparam [BLOCK_W-1:0]
	MARKER_LANE0 = { `SYNC_CTRL, 8'h0,8'hb8, 8'h89, 8'h6f, 8'h0, 8'h47, 8'h76, 8'h90 },
	MARKER_LANE1 = { `SYNC_CTRL, 8'h0,8'h19, 8'h3b, 8'h0f, 8'h0, 8'he6, 8'hc4, 8'hf0 },
	MARKER_LANE2 = { `SYNC_CTRL, 8'h0,8'h64, 8'h9a, 8'h3a, 8'h0, 8'h9b, 8'h65, 8'hc5 },
	MARKER_LANE3 = { `SYNC_CTRL, 8'h0,8'hc2, 8'h86, 8'h5d, 8'h0, 8'h3d, 8'h79, 8'ha2 };

logic [BLOCK_W-1:0] marker_lane[LANE_N-1:0];
assign marker_lane[0] = MARKER_LANE0;
assign marker_lane[1] = MARKER_LANE1;
assign marker_lane[2] = MARKER_LANE2;
assign marker_lane[3] = MARKER_LANE3;


reg clk = 1'b0; 
logic nreset;

logic [LANE_N-1:0] lock_v_i;
logic [LANE_N-1:0] am_lite_v_i; 
logic [LANE_N-1:0] am_lite_lock_v_i;
logic [LANE_N*BLOCK_W-1:0] data_i;
logic [LANE_N*BLOCK_W-1:0] data_o;
/* verilator lint_off UNUSEDSIGNAL*/
logic                      am_v_o;
/* verilator lint_on UNUSEDSIGNAL*/

logic [BLOCK_W-1:0] tb_data_i[LANE_N-1:0];
logic [BLOCK_W-1:0] tb_data_o[LANE_N-1:0];

/*verilator lint_off BLKSEQ */
always clk = #5 ~clk;
/*verilator lint_on BLKSEQ */

int skew[LANE_N];
int skew_max;
task create_skew();
	assert(`TB_SKEW_RANGE <= MAX_SKEW_BLOCK_N );
	skew_max = 0;	
	for(int i=0; i < LANE_N; i++ ) begin
		//skew[i] = $random % `TB_SKEW_RANGE;
		skew[i] = $random % 2;
		skew[i] = ( skew[i] < 0 )? -skew[i] : skew[i];
		skew_max = ( skew_max > skew[i])? skew_max : skew[i];
	end
endtask

task test_deskew();
	assert( skew_max <= MAX_SKEW_BLOCK_N );

	lock_v_i = {LANE_N{1'b1}};
	for(int j=0; j <= skew_max; j++ ) begin
		#10;
		`ifdef DEBUG
		$display("t %t skew %d", $time, j);
		`endif
		for(int i=0; i< LANE_N; i++) begin
			`ifdef DEBUG
			$display("lane %d j %d skew %d", i, j, skew[i]);
			`endif
			tb_data_i[i] = BLOCK_W'({ $random, $random, $random });
			am_lite_lock_v_i[i] = 1'b0;
			am_lite_v_i[i] = 1'b0;
			if ( j == skew[i] ) begin
				tb_data_i[i] = marker_lane[i];
				am_lite_v_i[i] = 1'b1;
			end
			if ( j > skew[i] ) begin
				`ifdef DEBUG
				$display("Set lock for lane %d", i);
				`endif
				am_lite_lock_v_i[i] = 1'b1;
			end
		end
	end
	/* complete lock */
	#10
	am_lite_v_i = '0;
	am_lite_lock_v_i = '1;	
	#1
	/* first cycle where lanes are aligned, we expect
 	 * to see the alignement marker on all lanes.
 	 * Checking the match between a lane and the correct
 	 * alignement marker */
	for(int i=0; i<LANE_N; i++) begin
		if ( tb_data_o[i] != marker_lane[i])begin
			$display("Error on lane %d %t", i, $time);
			assert(tb_data_o[i] == marker_lane[i]);
		end
	end
	#9
	$display("");
endtask

task set_lock_lost(int lane);
	for(int i=0; i < LANE_N; i++) begin
		am_lite_lock_v_i[i] = (lane == i)? 1'b0 : 1'b1;
	end
	#10
	am_lite_lock_v_i = { LANE_N{ 1'b1 }};
endtask

function int get_rand_lane();
	int rand_lane;
	rand_lane = $random % LANE_N;
	rand_lane = ( rand_lane < 0) ? -rand_lane: rand_lane;
	return rand_lane;
endfunction	

task simulate_stream();
	#10
	for(int i=0; i< LANE_N; i++) begin
		tb_data_i[i] = BLOCK_W'({ $random, $random, $random });
	end
endtask

genvar l;
generate
	for(l=0; l< LANE_N; l++) begin
		assign data_i[l*BLOCK_W+BLOCK_W-1:l*BLOCK_W] = tb_data_i[l];
		assign tb_data_o[l] = data_o[l*BLOCK_W+BLOCK_W-1:l*BLOCK_W];
	end
endgenerate
int tmp_lane; 
initial begin
	$dumpfile("wave/deskew_rx_tb.vcd");
	$dumpvars(0, deskew_rx_tb);
	nreset = 1'b0;
	#10;
	nreset = 1'b1;
	lock_v_i = '0;
	am_lite_v_i = '0;
	am_lite_lock_v_i = '0;

	`ifdef VERILATOR
	$display("ERROR: Test bench not supported to verilator, use iverilog");
	`endif
	// test 1 : run a sequence of 3 different test 
	// each time with a different skew configuration
	$display("Test 1   %t", $time);
	for(int i=0; i < `TB_LOOP_CNT; i++) begin
		
		create_skew();
		// test 1 : simple locking on multiple lanes
		// lost lock got to lock on all lanes 
		$display("Test 1.1 %t", $time);
		test_deskew();
		
		// test 2 : lose lock on a lane while locked
		// and test reset of deskew
		$display("Test 1.2 %t", $time);
		set_lock_lost(get_rand_lane());
		test_deskew();
	
		// test 3 : lose locking on a lane after having locked
		$display("Test 1.3 %t", $time);
		// start by re-losing lock
		tmp_lane = get_rand_lane();
		set_lock_lost(tmp_lane);
		
		// sending am_v and lock on first 3 lanes
		am_lite_v_i = { {LANE_N-3{1'b0}}, {3{1'b1}} };
		#10
		am_lite_lock_v_i = { {LANE_N-3{1'b0}}, {3{1'b1}} };
		// lose lock on lane again
		#10
		am_lite_v_i = {{LANE_N-3{1'b1}}, {3{1'b0}}};
		set_lock_lost(tmp_lane);
		#10	
		// begin sucessfull lock
		test_deskew();	
	
	end	
		
	#20	
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
	.lock_v_i(lock_v_i),
	.am_lite_v_i(am_lite_v_i),
	.am_lite_lock_v_i(am_lite_lock_v_i),
	.data_i(data_i),
	.am_v_o(am_v_o),
	.data_o(data_o)
);
endmodule
