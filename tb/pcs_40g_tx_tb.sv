`ifndef TB_LOOP_CNT_N
`define TB_LOOP_CNT_N 1
`endif
module pcs_40g_tx_tb;

localparam LANE_N = 1;
localparam DATA_W = 64;
localparam KEEP_W = $clog2(DATA_W);
	
localparam PMA_DATA_W = 16; 
localparam PMA_CNT_N  = (LANE_N*DATA_W)/PMA_DATA_W;

localparam DEBUG_ID_W = 64;

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
logic [PMA_CNT_N*PMA_DATA_W-1:0] pma_o;
logic [PMA_CNT_N*PMA_DATA_W-1:0] tb_pma;

// debug id
logic [DEBUG_ID_W-1:0] tb_debug_id;

reg   clk = 1'b0;
logic nreset;

always clk = #5 ~clk;

task new_block();
	// next block driver
	$tb(ctrl_v_i, idle_v_i, start_v_i,term_v_i, keep_i, 
		err_v_i , data_i);	
	// expected result
	$tb_exp(tb_pma, tb_debug_id);
endtask

initial begin
	$dumpfile("build/wave.vcd");
	$dumpvars(0, pcs_40g_tx_tb);
	nreset = 1'b0;
	#10
	nreset = 1'b1;
	
	for ( int i= 0; i < `TB_LOOP_CNT_N; i ++ ) begin
		new_block();		
		#10
		`ifdef DEBUG
		$display("Seq cnt %d, align marker gap %d", m_pcs_40g_tx.seq_q, m_pcs_40g_tx.m_align_market.gap_q );
		`else
		// have to add something to make iverilog happy
		idle_v_i  = {LANE_N{1'b1}};
		`endif
		
	end
	$tb_end();
	
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
	.data_o(pma_o)
);

endmodule
