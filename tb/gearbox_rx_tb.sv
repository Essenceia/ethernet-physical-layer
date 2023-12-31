/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

/* RX gearbox tb, test basis 64 -> 66 buffering functionality and bit slip */

`define TB_LOOP_CNT 10

module gearbox_rx_tb;

localparam DATA_W = 64;
localparam HEAD_W = 2;
localparam SEQ_N = 32;
localparam BLOCK_W = DATA_W + HEAD_W;

reg   clk = 1'b0;

/* verilator lint_off BLKSEQ */
always clk = #5 ~clk;
/* verilator lint_on BLKSEQ */
logic nreset;
logic              lock_v_i;
logic [DATA_W-1:0] data_i;
logic              slip_v_i;
logic              valid_o; // backpressure, buffer is full, need a cycle to clear 
logic [HEAD_W-1:0] head_o;
logic [DATA_W-1:0] data_o;

/* tb 
 * full data to be received after gearbox */
logic [DATA_W-1:0]   tb_pma_data;

logic [BLOCK_W-1:0]  tb_pcs_data;
logic [BLOCK_W-1:0]  tb_pcs_data_arr[SEQ_N:0];

/* verilator lint_off UNUSEDSIGNAL */
/* debug signal to view the difference between gotten
 * and expected */
logic [BLOCK_W-1:0] tb_pcs_data_diff;
/* verilator lint_on UNUSEDSIGNAL */

reg   [DATA_W-1:0]  tb_buff_q;
logic [DATA_W-1:0]  tb_buff_next_arr[SEQ_N:0];
logic [DATA_W-1:0]  tb_buff_next;

logic [BLOCK_W-1:0] tb_gb_data;

/* Simple gearbox test
 * There is no slipage during this sequence.
 * This test generate a random array of 66b of data for a given
 * sequence and check it is correctly outputed aligned on 64b */
task simple_test();
	// 64 bit pma data
	logic [DATA_W-1:0] pma;

	for( int seq = 0; seq<= SEQ_N; seq++ ) begin
		lock_v_i = 1'b1;
		slip_v_i = 1'b0;
		//pma = {8{8'h01}};
		pma = {$random, $random};
		tb_pma_data = pma;

		data_i = tb_pma_data; 
		#1
		
		tb_buff_next = tb_buff_next_arr[seq];
		tb_pcs_data = tb_pcs_data_arr[seq];
		
		/* check pcs data matches */
		tb_gb_data = { data_o, head_o };
		if ( seq > 0 ) begin
			tb_pcs_data_diff = tb_gb_data ^ tb_pcs_data; 
			assert( tb_gb_data == tb_pcs_data);	
		end
		#9
		lock_v_i = 1'b1;
	end	
endtask

genvar i;
generate 
	for( i = 0; i < SEQ_N; i++) begin : tb_buff_next_loop
		if ( i == 0 ) begin : i_eq_zero
			assign tb_buff_next_arr[i] = tb_pma_data[DATA_W-1:0];
			assign tb_pcs_data_arr[i] = {BLOCK_W{1'bx}}; 
		end else begin : i_gt_zero
			assign tb_buff_next_arr[i] ={ {2*i{1'bx}}, tb_pma_data[DATA_W-1:2*i]};
			assign tb_pcs_data_arr[i] = { tb_pma_data[2*i-1:0], tb_buff_q[DATA_W-1-2*(i-1):0]}; 
		end
		`ifdef DEBUG
		logic [BLOCK_W-1:0] db_pcs_data;
		logic [DATA_W-1:0] db_buff_next;
		assign db_pcs_data = tb_pcs_data_arr[i];
		assign db_buff_next = tb_buff_next_arr[i];
		`endif

	end
endgenerate
/* buffer tb data */
always @(posedge clk) begin
	tb_buff_q <= tb_buff_next;
end

/* Bit Slip test */
task slip();
	lock_v_i = 1'b1;
	data_i = {8{8'h01}};
	for(int x=0; x < 64; x++) begin
		#10
		/* verilator lint_off WIDTHTRUNC*/
		slip_v_i = $random;
		/* verilator lint_on WIDTHTRUNC*/
	end
	slip_v_i = 1'b0;
endtask

/* Lock lost test
 * Check to see if gearbox output is correctly invalid */
task lock_lost();
	lock_v_i = 1'b0;
	for(int x=0; x < `TB_LOOP_CNT; x++) begin
		#10
		assert( valid_o == 1'b0 );
		/* check sequence cnt is re-set to 0 */
		assert( m_gearbox_rx.seq_q == 'd0 );
	end
	lock_v_i = 1'b1;
endtask

/* data check */
always @(posedge clk) begin
	if ( nreset ) begin
		assert( ~$isunknown(valid_o));
		if ( valid_o ) begin
			assert( ~$isunknown(data_o));
			assert( ~$isunknown(head_o));
		end
	end
end

initial begin
	$dumpfile("wave/gearbox_rx_tb.vcd");
	$dumpvars(0, gearbox_rx_tb);
	nreset = 1'b0;
	lock_v_i = 1'b0;
	#10
	nreset = 1'b1;
	
	/* Test 1 */
	$display("test 1 %t", $time);
	simple_test();

	/* Test 2 */
	$display("test 2 %t", $time);
	/* test slipage */
	slip();
	#10	

	/* Test 3 */
	$display("test 3 %t", $time);
	/* test lock lost */
	lock_lost();

	// self check
	// no difference between got and expected
	#10
	$display("Sucess");	
	$finish;
end

// uut 
gearbox_rx #(
	.HEAD_W(HEAD_W),
	.DATA_W(DATA_W)
)m_gearbox_rx(
	.clk(clk),
	.nreset(nreset),
	.lock_v_i(lock_v_i),
	.data_i(data_i),
	.slip_v_i(slip_v_i),
	.valid_o(valid_o), 
	.head_o(head_o),
	.data_o(data_o)
);
endmodule
