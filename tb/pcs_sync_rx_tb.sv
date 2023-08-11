/* Testbench for RX frame sync */
`define SYNC_CTRL 2'b10
`define SYNC_DATA 2'b01

`define TB_TEST3_LOOP 150

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

int loop_lock;
int nv_sh_sent;
int sh_v; 

initial begin
	$dumpfile("build/wave.vcd");
	$dumpvars(0, pcs_sync_rx_tb);
	nreset = 1'b0;
	#10;
	nreset = 1'b1;
	valid_i = 1'b0;
	// test 1 : TEST_SH -> 64_GOOD -> TEST_SH2	
	// simple test, see if we can detect lock
	// we need at least 64 blocks to trigger a lock
	$display("test 1 %t", $time);
	loop_lock =  64 + ( $random % 20 ); 
	for(int t=0; t < loop_lock; t++ ) begin
		#10
		head_i = ( $random % 2 )? `SYNC_CTRL : `SYNC_DATA;
		valid_i = 1'b1;
		// only sending valid lock's should never slip
		assert( ~slip_v_o );
	end
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

	$display("Test finished $t", $time);	
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
