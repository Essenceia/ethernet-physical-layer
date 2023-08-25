`ifndef TB_LOOP_N
`define TB_LOOP_N 60000
`endif

/* marker_tb
 * TB to test the market alignement feature.
 * Written to help test this feature in isolation
 * using the same C model as the vpi in hopes to 
 * hit this case faster. This marker will only be
 * added once every 2^14 cycles.
 */
module am_tx_tb;
parameter LANE_N = 4;
parameter HEAD_W = 2;
parameter DATA_W = 64;
parameter BLOCK_W = HEAD_W+DATA_W;

reg clk = 1'b0;
reg 		nreset;

logic [LANE_N*HEAD_W-1:0] head_i; 
logic [LANE_N*DATA_W-1:0] data_i; 

logic [LANE_N*HEAD_W-1:0] head_o;
logic [LANE_N*DATA_W-1:0] data_o;

logic [LANE_N*DATA_W-1:0] tb_data_o;
logic [LANE_N*HEAD_W-1:0] tb_head_o;

logic [LANE_N*DATA_W-1:0] tb_data_diff;

logic marker_v_o;
logic tb_marker_v_o;

always #5 clk = ~clk;

initial begin
	`ifndef VERILATOR
	$dumpfile("wave/am_tx_tb.vcd");
	$dumpvars(0, am_tx_tb);
	`endif
	nreset = 1'b0;
	#10
	// begin testing
	for(int i=0; i< `TB_LOOP_N; i++)begin
		#9
		nreset = 1'b1;
		`ifdef DEBUG
		$display("time %t", $time);
		`endif
		`ifndef VERILATOR
		$tb_marker(head_i,data_i, tb_marker_v_o, tb_head_o, tb_data_o); 
		`endif
		#1
		check();
	end
	$finish;
end

assign tb_data_diff = data_o ^ tb_data_o;

task check();
			assert(tb_marker_v_o == marker_v_o);
			assert(tb_head_o == head_o);
			assert(tb_data_o == data_o);
endtask
am_tx #(.LANE_N(LANE_N)) m_uut(
	.clk(clk),
	.nreset(nreset),
	.head_i(head_i),
	.data_i(data_i),
	.marker_v_o(marker_v_o),
	.head_o(head_o),
	.data_o(data_o)
);


endmodule
