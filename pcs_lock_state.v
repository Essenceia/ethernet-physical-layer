/* Per lane sync block, uses the sync header to 
* lock onto the the block.
*
* Funtionality outlined in 802.3 figure 49-14
*
*
* */
module pcs_lock_state#(
	parameter HEAD_W = 2
)(
	input clk,
	input nreset, 


	// SERDES 
	input              valid_i, // signal_ok
	input [HEAD_W-1:0] head_i,
	output             slip_v_o, // slip_done

	// Status
	output             lock_v_o // rx_block_lock
	
);
localparam CNT_N = 64;
localparam CNT_W = $clog2(CNT_N);

// sh_cnt
logic [CNT_W-1:0] cnt_next;
reg   [CNT_W-1:0] cnt_q;
// sh_invalid_cnt
logic [CNT_W-1:0] invalid_cnt_next;
reg   [CNT_W-1:0] invalid_cnt_q;


// block lock
reg   lock_q;
logic lock_next;

always @(posedge clk) begin
	if ( ~nreset ) begin
		lock_q <= 1'b0;
	end else begin
		lock_q <= lock_next;
	end
end

// fsm, follows the 49-14 lock diagram naming for fsm
logic lock_init_next;
logic reset_cnt_next;
logic test_sh_next;
logic valid_sh_next;
logic 64_good_next;
logic invalid_sh_next;
logic slip_next;
reg   lock_init_q;
reg   reset_cnt_q;
reg   test_sh_q;
reg   valid_sh_q;
reg   64_good_q;
reg   invalid_sh_q;


always @(posedge clk) begin
	if ( ~nreset ) begin
		lock_init_q  <= 1'b1;
		reset_cnt_q  <= 1'b0;
		test_sh_q    <= 1'b0;
		valid_sh_q   <= 1'b0;
		64_good_q    <= 1'b0;
		invalid_sh_q <= 1'b0;
		slip_q       <= 1'b0;	
end else begin
		lock_init_q  <= lock_init_next;  
		reset_cnt_q  <= reset_cnt_next;
		test_sh_q    <= test_sh_next;
		valid_sh_q   <= valid_sh_next;
		64_good_q    <= 64_good_next;
		invalid_sh_q <= invalid_sh_next;
		slip_q       <= slip_next;	
	end
end

// output
assign lock_v_o = lock_q; 

`ifdef FORMAL
logic f_fsm;
assign f_fsm = { lock_q };

always @(posedge clk) begin
	if ( nreset ) begin
		// check fsm is onehot
		sva_fsm_onehot : assert( $onehot(f_fsm));
	end
end
`endif
endmodule
