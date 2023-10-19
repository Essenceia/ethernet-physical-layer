/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

`ifndef TB_LOOP_N
`define TB_LOOP_N 5
`endif

`define SYNC_CTRL 2'b10
`define SYNC_DATA 2'b01	

/* pcs 10g loopback tb
 * Small test bench to check module behavior
 */
module pcs_10g_loopback_tb;
parameter IS_10G = 1;
parameter DATA_W = 64;
parameter HEAD_W = 2;
parameter BLOCK_W = HEAD_W + DATA_W;

reg clk = 1'b0;
reg nreset;

logic rx_locked_i;
logic [DATA_W-1:0] rx_par_data_i;
logic [DATA_W-1:0] tx_par_data_o;

/*verilator lint_off BLKSEQ*/
always #5 clk = ~clk;
/*verilator lint_on BLKSEQ*/


task send_valid_block();
	logic [BLOCK_W-1:0] buff;
	logic [HEAD_W-1:0] head;
	head = $random % 2 ? `SYNC_DATA : `SYNC_CTRL;
	buff = { $random, $random, head };	
	
	rx_par_data_i = buff[DATA_W-1:0];
	buff = buff >> DATA_W;
	for(int i=2; i < 64; i=i+2) begin
		#10
	 	rx_par_data_i = buff;	
		head = $random % 2 ? `SYNC_DATA : `SYNC_CTRL;
		buff = { $random, $random, head };	
		rx_par_data_i = buff << i;
		buff = buff >> i; 
	end
	#10
	rx_par_data_i = buff;
	#10
	rx_par_data_i = {DATA_W{1'bx}};	
endtask

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
		rx_locked_i = 1'b1;
		send_valid_block();	
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
