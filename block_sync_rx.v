/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

/* Per lane sync block, uses the sync header to 
* lock onto the the block.
*
* Funtionality outlined in 802.3 figure 49-14
* 
* From clause 82 :
* When the receive channel is in normal or test-pattern mode, the PCS Synchronization process continuously
* monitors inst:IS_SIGNAL.indication(SIGNAL_OK). When SIGNAL_OK indicates OK, then the PCS
* Synchronization process accepts data-units via the inst:IS_UNITDATA_i.indication primitive. It attains
* block synchronization based on the 2-bit synchronization headers on each one of the PCS lanes.
*
*
* */
module block_sync_rx#(
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
localparam CNT_N = 1024;
localparam CNT_W = $clog2(CNT_N);
localparam NV_CNT_N = 65;
localparam NV_CNT_W = $clog2(NV_CNT_N);

// sync header test
logic  sh_v; // sh_valid
assign sh_v = head_i[0] ^ head_i[1]; // vaild syn header can be 2'b10 or 2'b01

// counters
logic [CNT_W-1:0] cnt_next;
reg   [CNT_W-1:0] cnt_q;// sh_cnt 
logic [CNT_W-1:0] cnt_add;
logic             cnt_add_overflow; // 1024 
logic             cnt_64;
logic             cnt_1024;

logic [NV_CNT_W-1:0] nv_cnt_next;
reg   [NV_CNT_W-1:0] nv_cnt_q;// sh_invalid_cnt 
logic [NV_CNT_W-1:0] nv_cnt_add;
logic                unused_nv_cnt_add_of; 
logic                nv_cnt_65; 

logic cnt_rst_v; // reset counters ( RESET_CNT )
// lock set and unset
logic lock_v; // 64_GOOD
logic slip_v; // SLIP


assign cnt_rst_v = invalid_q | lock_v | slip_v | cnt_1024; 

assign { cnt_add_overflow,    cnt_add    } = cnt_q    + {{ CNT_W-1{1'b0}}, sh_v|lock_q };
assign { unused_nv_cnt_add_of, nv_cnt_add } = nv_cnt_q + {{NV_CNT_W-1{1'b0}}, ~sh_v }; 

assign cnt_next = cnt_rst_v ? {CNT_W{1'b0}} : cnt_add;
assign nv_cnt_next = cnt_rst_v ? {NV_CNT_W{1'b0}} : nv_cnt_add;
 
assign nv_cnt_65 = nv_cnt_add == 'd65;
assign cnt_64    = cnt_add == 'd64;
assign cnt_1024  = cnt_add_overflow;
 
always @(posedge clk) begin
	cnt_q <= cnt_next;
	nv_cnt_q <= nv_cnt_next; 
end

// lock and slip
assign slip_v = sync_q & ~sh_v // TEST_SH -> SLIP 
			  | lock_q & nv_cnt_65; // INVALID_SH -> SLIP
assign lock_v = sync_q & cnt_64;
 
// fsm
reg   invalid_q;
logic invalid_next;
reg   sync_q; // syncing in progress, havn't locked
logic sync_next;
reg   lock_q; // have a valid lock
logic lock_next;

assign invalid_next = invalid_q & ~valid_i 
					| ~valid_i;
assign sync_next = valid_i & ( invalid_q // signal ok, start testing
				 | sync_q & ~lock_v // continue testesing, not locked yet
				 | lock_q & slip_v) ;// lost lock startup new sync process
assign lock_next = valid_i 
				 & ( lock_q & ~slip_v // lock not lost 
				   | sync_q & lock_v); // locked
				  
always @(posedge clk) begin
	if ( ~nreset ) begin
		invalid_q <= 1'b1;
		sync_q <= 1'b0;
		lock_q <= 1'b0;
	end else begin
		invalid_q <= invalid_next;
		sync_q <= sync_next;
		lock_q <= lock_next;
	end
end

// output
assign lock_v_o = lock_q; 
assign slip_v_o = slip_v;

`ifdef FORMAL
logic f_fsm;
assign f_fsm = { invalid_q, sync_q, lock_q };

always @(posedge clk) begin
	if ( nreset ) begin
		// check fsm is onehot
		sva_fsm_onehot : assert( $onehot(f_fsm));
	end
end
`endif
endmodule
