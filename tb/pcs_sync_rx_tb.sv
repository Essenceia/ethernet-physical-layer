/* Testbench for RX frame sync */
`define TB_LOOP_CNT 100

module pcs_sync_rx_tb;

localparam HEAD_W = 2;
localparam DATA_W = 64;
localparam BLOCK_W = HEAD_W + DATA_W;

reg   clk = 1'b0;
logic nreset; 
logic              valid_i; // signal_ok
logic [HEAD_W-1:0] head_i;
logic              slip_v_o; // slip_done
logic              lock_v_o; // rx_block_lock

always clk = #5 ~clk;

initial begin
	$dumpfile("build/wave.vcd");
	$dumpvars(0, pcs_sync_rx_tb);
	nreset = 1'b0;
	#10;
	nreset = 1'b1;
	valid_i = 1'b0;	
	// simple test, see if we can detect lock
	for(int t=0; t < `TB_LOOP_CNT; t++ ) begin
		#10
		head_i = ( $random % 2 )? 2'b01 : 2'b10;
		valid_i = 1'b1;
	end
	// see if we lose the lock
	valid_i = 1'b0;
	#20
	$finish;
end

pcs_sync_rx #(.HEAD_W(HEAD_W))
m_uut(
	.clk(clk),
	.nreset(nreset),
	.valid_i(valid_i),
	.head_i(head_i),
	.slip_v_o(slip_v_o),
	.lock_v_o(lock_v_o)
);


endmodule
