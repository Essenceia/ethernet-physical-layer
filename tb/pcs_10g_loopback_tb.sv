/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

`ifndef TB_LOOP_N
`define TB_LOOP_N 10
`endif

/* pcs 10g loopback tb
 * Small test bench to check module behavior
 */
module pcs_10g_loopback_tb;
parameter IS_10G = 1;
parameter DATA_W = 64;

reg clk = 1'b0;
reg nreset;

logic rx_locked_i;
logic [DATA_W-1:0] rx_par_data_i;
logic [DATA_W-1:0] tx_par_data_o;

/*verilator lint_off BLKSEQ*/
always #5 clk = ~clk;
/*verilator lint_on BLKSEQ*/

initial begin
	$dumpfile("wave/pcs_10g_loopback_tb.vcd");
	$dumpvars(0, pcs_10g_loopback_tb);
	nreset = 1'b0;
	#10
	nreset = 1'b1;
	rx_locked_i = 1'b0;
	#20
	// begin testing
	for(int i=0; i< `TB_LOOP_N; i++)begin
		#10	
		rx_locked_i = 1'b0;
		rx_par_data_i = { $random, $random };	
	end
	#10
	$finish;
end


pcs_10g_loopback #(
	IS_10G (IS_10G),
	DATA_W(DATA_W)
)m_pcs_10g_loopback(
	.rx_par_clk    (clk),
	.tx_par_clk    (clk),
	.nreset        (nreset),
	.rx_locked_i   (rx_locked_i),
	.rx_par_data_i (rx_par_data_i),
	.tx_par_data_o (tx_par_data_o)	
);

endmodule
