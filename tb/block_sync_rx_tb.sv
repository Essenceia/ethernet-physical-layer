/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */
 
`define SYNC_CTRL 2'b10
`define SYNC_DATA 2'b01

`define TB_TEST3_LOOP 150
`define TB_TEST6_LOOP 10

/* Testbench for RX frame sync */
module block_sync_rx_tb;

localparam HEAD_W = 2;
localparam DATA_W = 64;
localparam BLOCK_W = HEAD_W + DATA_W;

reg   clk = 1'b0;
logic nreset; 
logic              valid_i; // data valid 
logic              signal_v_i; // signal_ok
logic [HEAD_W-1:0] head_i;
logic              slip_v_o; // slip_done
logic              lock_v_o; // rx_block_lock

always clk = #5 ~clk;

int loop_lock;
int nv_sh_sent;
int sh_v; 

task aquire_lock( input int loop_lock );
	// need at least 64 valid blocks to aquire lock
	assert( loop_lock >= 64 );
	for(int t=0; t < loop_lock; t++ ) begin
		#9
		head_i = ( $random % 2 )? `SYNC_CTRL : `SYNC_DATA;

		/* send invalid signal, do no count these cycles */
		valid_i = (( $random % 6 ) == 0 )? 1'b0: 1'b1;
		if ( valid_i == 1'b0 ) begin
			t--;
		end

		signal_v_i = 1'b1;
		// only sending valid lock's should never slip
		#1
		assert( ~slip_v_o );
	end
endtask

initial begin
	$dumpfile("wave/block_sync_rx.vcd");
	$dumpvars(0, block_sync_rx_tb);
	nreset = 1'b0;
	#10;
	nreset = 1'b1;
	valid_i = 1'b1;
	signal_v_i = 1'b0;
	// test 1 : TEST_SH -> 64_GOOD -> TEST_SH2	
	// simple test, see if we can detect lock
	// we need at least 64 blocks to trigger a lock
	$display("test 1 %t", $time);
	loop_lock =  64 + ( $random % 20 ); 
	aquire_lock(loop_lock);	
	// we should be locked
	assert( lock_v_o );
	
	// test 2 : TEST_SH2 -> INVALID_SH -> SLIP
	// After test 1 we have a lock, we will start
	// sending some random sync headers and our logic
	// should detect this and trigger the slip
	// A slip should be detected after 65 wrong heads, but
	// random data might contain a valid sync header ( x3 or x1 )
	$display("test 2 %t", $time);
	nv_sh_sent = 0;
	do begin
		#10
		head_i = $random;
		// check if head is valid
		nv_sh_sent = ( (head_i == `SYNC_DATA) || (head_i == `SYNC_CTRL) ) ? nv_sh_sent: nv_sh_sent+1; 	
	end while (nv_sh_sent != 65); 
	#1
	assert( slip_v_o );
	#9
	// check if we lost the lock
	assert( ~lock_v_o);

	// test 3 : TEST_SH -> SLIP
	// We have lost the lock at this point.
	// Sending rublish data for a few cycles and 
	// check we do not lock and are slipining on 
	// every invalid head
	$display("test 3 %t", $time);
	sh_v = 0;
	for(int t=0; t < `TB_TEST3_LOOP; t++) begin
		#9
		head_i = $random;
		// check if head is valid
		sh_v = ( (head_i == `SYNC_DATA) || (head_i == `SYNC_CTRL) ) ? 1:0; 	
		#1
		if ( !sh_v ) begin
			assert( slip_v_o );
		end	
	end

	// test 4
	// Re-aquire lock and once we have re-locked
	// lose the signal.
	$display("test 4 %t", $time);
	aquire_lock(loop_lock);
	assert(lock_v_o);
	#10;
	valid_i = 1'b1;
	signal_v_i = 1'b0;
	// continue sending valid headers but should have lost lock and there
	// should be no slip
	for(int t = 0; t < loop_lock; t++) begin
		#9
		head_i = ( $random % 2 )? `SYNC_CTRL : `SYNC_DATA;
		#1
		assert( ~slip_v_o );
		assert( ~lock_v_o );
	end	
	// test 5
	// Re-establish signal, re-aquire lock
	$display("test 5 %t", $time);
	signal_v_i = 1'b1;
	aquire_lock( loop_lock );
	assert( lock_v_o );

	/* test 6 
	 * Sending invalid data, with random data,
	 * block lock state should not change */
	$display("test 6 %t", $time);
	valid_i = 1'b0; 
	for(int t=0; t< `TB_TEST6_LOOP; t++) begin
		#9
		head_i = $random;
		#1
		/* by default we have lock, we should still
 	 	* have the lock */		
		assert(lock_v_o);	
	end
	valid_i = 1'b1;	
 	
	$display("Test finished %t", $time);	
	signal_v_i = 1'b0;
	#20
	$finish;
end

block_sync_rx #(.HEAD_W(HEAD_W))
m_uut(
	.clk(clk),
	.nreset(nreset),
	.signal_v_i(signal_v_i),
	.valid_i(valid_i),
	.head_i(head_i),
	.slip_v_o(slip_v_o),
	.lock_v_o(lock_v_o)
);


endmodule
