/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

module am_lock_rx #(
	parameter BLOCK_W = 66,
	parameter LANE_N = 4
)(
	input clk,
	input nreset,

	input               valid_i,

	/* verilator lint_off UNUSEDSIGNAL*/
	// block data, bip3 and bip7 will not be checked 
	input [BLOCK_W-1:0] block_i,
	/* verilator lint_on UNUSEDSIGNAL*/

	output              lock_v_o,

	// lite interface used by deskew
	output              lite_am_v_o,
	output              lite_lock_v_o,

	output [LANE_N-1:0] lane_o	
);
localparam GAP_N = 16383;
localparam GAP_W = $clog2(GAP_N);
localparam NV_CNT_N = 4; 
localparam NV_CNT_W = $clog2(NV_CNT_N);
localparam SYNC_CTRL = 2'b10;
localparam [BLOCK_W-1:0]
	MARKER_LANE0 = { {8{1'bx}},8'hb8, 8'h89, 8'h6f, {8{1'bx}}, 8'h47, 8'h76, 8'h90 ,SYNC_CTRL},
	MARKER_LANE1 = { {8{1'bx}},8'h19, 8'h3b, 8'h0f, {8{1'bx}}, 8'he6, 8'hc4, 8'hf0 ,SYNC_CTRL},
	MARKER_LANE2 = { {8{1'bx}},8'h64, 8'h9a, 8'h3a, {8{1'bx}}, 8'h9b, 8'h65, 8'hc5 ,SYNC_CTRL},
	MARKER_LANE3 = { {8{1'bx}},8'hc2, 8'h86, 8'h5d, {8{1'bx}}, 8'h3d, 8'h79, 8'ha2 ,SYNC_CTRL};
logic [BLOCK_W-1:0] marker_lane[LANE_N-1:0];
assign marker_lane[0] = MARKER_LANE0;
assign marker_lane[1] = MARKER_LANE1;
assign marker_lane[2] = MARKER_LANE2;
assign marker_lane[3] = MARKER_LANE3;

// counters
reg   [NV_CNT_W-1:0] nv_cnt_q;
logic [NV_CNT_W-1:0] nv_cnt_next;
logic [NV_CNT_W-1:0] nv_cnt_add;// am_invld_cnt
logic                nv_cnt_add_of;
logic                nv_cnt_rst_v;
logic                nv_cnt_4;
logic                nv_cnt_zero;

// match alignement marker
logic am_first_v; // found a valid alignement marker, lite version
logic am_v;
logic slip_v;

assign nv_cnt_rst_v =  sync_q | ( lock_q & gap_zero & lane_match_same ); 
// add
assign { nv_cnt_add_of, nv_cnt_add } = nv_cnt_q + {{NV_CNT_W-1{1'b0}}, lock_q & gap_zero & ~lane_match_same}; 
assign nv_cnt_4    = nv_cnt_add_of;
assign nv_cnt_zero = ~|nv_cnt_q;

assign nv_cnt_next = nv_cnt_rst_v ? {NV_CNT_W{1'b0}} : nv_cnt_add;

// gap
reg   [GAP_W-1:0] gap_q;
logic [GAP_W-1:0] gap_next;
logic [GAP_W-1:0] gap_add;
logic             unused_gap_add_of;
logic             gap_zero;
logic             gap_rst_v;

assign gap_rst_v = invalid_q | slip_v;
assign {unused_gap_add_of, gap_add} = gap_q + { {GAP_W-1{1'b0}},1'b1 };
assign gap_next = gap_rst_v ? {GAP_W{1'b0}}: gap_add; 

assign gap_zero = ~|gap_q;

always @(posedge clk) begin
	nv_cnt_q <= nv_cnt_next;
	gap_q <= gap_next;
end

// alignement marker detection
// current lane
reg   [LANE_N-1:0] lane_q;
logic [LANE_N-1:0] lane_next;
logic [LANE_N-1:0] lane_match;
logic              lane_match_same;// match same the alignement marker on the same lane

assign lane_match_same = |(lane_match == lane_q) & nv_cnt_zero;
genvar i;
generate
	for( i=0 ; i < LANE_N; i++ ) begin
		assign lane_match[i] = (marker_lane[i][3*8+2-1:0]  == block_i[3*8+2-1:0] )
							 & (marker_lane[i][7*8+2-1:34] == block_i[7*8+2-1:34]);
	end
endgenerate

assign lane_next = gap_zero ? lane_match : lane_q; 
always @(posedge clk) begin
	lane_q <= lane_next;
end

assign am_first_v = |lane_match; 
assign am_v       = gap_zero & lane_match_same;  
assign slip_v = sync_q  & ~|lane_match
			  | first_q & gap_zero & ~lane_match_same
			  | lock_q & nv_cnt_4;
			  

// fsm
reg   sync_q;
logic sync_next;
reg   first_q; // we have found the 1st alignement marker 
logic first_next;
reg   lock_q;
logic lock_next;
reg   invalid_q;
logic invalid_next;

assign invalid_next = ~valid_i; 
assign sync_next  = valid_i 
				  & ( invalid_q
				    | sync_q & ~am_first_v
				    | slip_v);
assign first_next = valid_i 
				   & ( sync_q & am_first_v
				     | first_q & ~gap_zero);
assign lock_next = valid_i
				 & (first_q & am_v
				   |lock_q & ~nv_cnt_4);
 
always @(posedge clk) begin
	if ( ~nreset ) begin
		invalid_q <= 1'b1;
		sync_q <= 1'b0;
		lock_q <= 1'b0;
		first_q <= 1'b0;	
	end else begin
		invalid_q <= invalid_next;
		sync_q <= sync_next;
		lock_q <= lock_next;
		first_q <= first_next;
	end
end
// output
assign lock_v_o = lock_q;
assign lane_o   = lane_q;

//assign slip_v_o = slip_v;

assign lite_am_v_o   = am_first_v;
assign lite_lock_v_o = first_q | lock_q; 

`ifdef FORMAL
logic [3:0] f_fsm;
assign f_fsm = { invalid_q , sync_q , first_q, lock_q };

always @(posedge clk) begin
	if ( nreset ) begin
		// xcheck
		xcheck_valid_i : assert( ~$isunknown(valid_i));
		xcheck_block_i : assert( ~valid_i | valid_i & ~$isunknown(block_i));
		xcheck_lock_v_o : assert( ~$isunknown(lock_v_o));
		xcheck_lane_o : assert( ~lock_v_o | lock_v_o & ~$isunknown(lane_o));
	//	xcheck_slip_v_o : assert( ~$isunknown(slip_v_o));

		// fsm
		sva_fsm_onehot : assert( $onehot(f_fsm));
	end
end
`endif
endmodule
