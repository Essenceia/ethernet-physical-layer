/* Testbench for RX frame sync */
`define SYNC_CTRL 2'b10
`define SYNC_DATA 2'b01

`define TB_TEST3_LOOP 150

module am_lock_rx_tb;

localparam HEAD_W = 2;
localparam DATA_W = 64;
localparam BLOCK_W = HEAD_W + DATA_W;
localparam [BLOCK_W-1:0]
	MARKER_LANE0 = { `SYNC_CTRL, {8{1'bx}},8'hb8, 8'h89, 8'h6f, {8{1'bx}}, 8'h47, 8'h76, 8'h90 },
	MARKER_LANE1 = { `SYNC_CTRL, {8{1'bx}},8'h19, 8'h3b, 8'h0f, {8{1'bx}}, 8'he6, 8'hc4, 8'hf0 },
	MARKER_LANE2 = { `SYNC_CTRL, {8{1'bx}},8'h64, 8'h9a, 8'h3a, {8{1'bx}}, 8'h9b, 8'h65, 8'hc5 },
	MARKER_LANE3 = { `SYNC_CTRL, {8{1'bx}},8'hc2, 8'h86, 8'h5d, {8{1'bx}}, 8'h3d, 8'h79, 8'ha2 };
localparam LANE_N = 4;
localparam GAP_N = 16383;

reg   clk = 1'b0;
logic nreset; 
logic               valid_i; // signal_ok
logic [BLOCK_W-1:0] block_i;
logic               slip_v_o; // slip_done
logic               lock_v_o; // rx_block_lock
logic [LANE_N-1:0]  lane_o;

always clk = #5 ~clk;

logic [BLOCK_W-1:0] marker_lane[LANE_N-1:0];
assign marker_lane[0] = MARKER_LANE0;
assign marker_lane[1] = MARKER_LANE1;
assign marker_lane[2] = MARKER_LANE2;
assign marker_lane[3] = MARKER_LANE3;

task aquire_lock( input int extra_cycles, int lane );
	logic [HEAD_W-1:0] head;
	logic [DATA_W-1:0] data;
	// write first am 
	#10
	valid_i = 1'b1;
	block_i = marker_lane[lane]; 
	for(int t=0; t < GAP_N ; t++ ) begin
		#9
		head = ( $random % 2 )? `SYNC_CTRL : `SYNC_DATA;
		data = { $random, $random };
		block_i = {data, head};
		// only sending valid lock's should never slip
		#1
		assert( ~slip_v_o );
	end
	// write second am
	block_i = marker_lane[lane];
	for(int t=0; t<extra_cycles; t++) begin
		#10
		assert( lock_v_o); 
	end
endtask

initial begin
	$dumpfile("build/wave.vcd");
	$dumpvars(0, am_lock_rx_tb);
	nreset = 1'b0;
	#10;
	nreset = 1'b1;
	valid_i = 1'b0;
	$finish;
end

am_lock_rx #(.BLOCK_W(BLOCK_W), .LANE_N(LANE_N))
m_uut(
	.clk(clk),
	.nreset(nreset),
	.valid_i(valid_i),
	.block_i(block_i),
	.slip_v_o(slip_v_o),
	.lock_v_o(lock_v_o),
	.lane_o(lane_o)
);


endmodule
