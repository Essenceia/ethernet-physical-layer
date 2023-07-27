`ifndef
`define TB_LOOP_CNT_N 16400
`endif
module pcs_40g_tx_tb;

localparam LANE_N = 4;
localparam DATA_W = 64;
localparam KEEP_W = $clog2(DATA_W);
	
localparam PMA_DATA_W = 16; 
localparam PMA_CNT_N  = (LANE_N*DATA_W)/PMA_DATA_W;

// MAC
logic [LANE_N-1:0] ctrl_v_i;
logic [LANE_N-1:0] idle_v_i;
logic [LANE_N-1:0] start_v_i;
logic [LANE_N-1:0] term_v_i;
logic [LANE_N-1:0] err_v_i;
logic [LANE_N*DATA_W-1:0] data_i; // tx data
logic [LANE_N*KEEP_W-1:0] keep_i;
logic              ready_o;	
// PMA
logic [PMA_CNT_N*PMA_DATA_W-1:0] data_o;

reg   clk = 1'b0;
logic nreset;

always clk = #5 ~clk;

initial begin
	$dumpfile("build/pcs_40g_tx_tb.vcd");
	$dumpvars(0, pcs_40g_tx_tb);
	nreset = 1'b0;
	#10
	nreset = 1'b1;
	ctrl_v_i  = {LANE_N{1'b1}};
	idle_v_i  = {LANE_N{1'b1}};
	term_v_i  = {LANE_N{1'b0}};
	err_v_i   = {LANE_N{1'b0}};	
	start_v_i = {LANE_N{1'b0}};
	#10
	for ( int i= 0; i < `TB_LOOP_CNT_N; i ++ ) begin
		#10
		`ifdef DEBUG
		$display("Seq cnt %d, align marker gap %d", m_pcs_40g_tx.seq_q, m_pcs_40g_tx.m_align_market.gap_q );
		`elseif
		// have to add something to make iverilog happy
		idle_v_i  = {LANE_N{1'b1}};
		`endif
		
	end
	
	$display("Sucess");	
	$finish;
end


// uut
pcs_40g_tx #( .LANE_N(LANE_N), .DATA_W(DATA_W), .KEEP_W(KEEP_W))
m_pcs_40g_tx(
	.clk(clk),
	.nreset(nreset),
	.ctrl_v_i(ctrl_v_i),
	.idle_v_i(idle_v_i),
	.start_v_i(start_v_i),
	.term_v_i(term_v_i),
	.err_v_i(err_v_i),
	.data_i(data_i),
	.keep_i(keep_i),
	.ready_o(ready_o),	
	.data_o(data_o)
);

endmodule
