/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

/* PCS encode block
*
* Add control additional control blocks.*/
module pcs_enc_lite #(
	parameter IS_10G = 0,
	parameter DATA_W = 64,
	parameter KEEP_W = DATA_W/8,
	parameter BLOCK_W = 64,
	parameter CNT_N = BLOCK_W/DATA_W,
	//parameter CNT_W = $clog2( CNT_N ),
	parameter PART_MSB = CNT_N > 1 ? CNT_N-1:0,
	parameter KEEP_NEXT_MSB = CNT_N > 1 ? (CNT_N-1)*KEEP_W-1 : 0,
	parameter LANE0_CNT_N = IS_10G ? 2 : 1,
	parameter FULL_KEEP_W = CNT_N*KEEP_W,
	parameter BLOCK_TYPE_W = 8,
	parameter CTRL_W  = 7
)(
	// data clk
	//input clk,
	//input nreset,

	input                    ctrl_v_i,
	input                    idle_v_i,
	input [LANE0_CNT_N-1:0]  start_v_i,
	input                    term_v_i,

	/* verilator lint_off UNUSEDSIGNAL*/
	// TODO : add encoding of error 
	input                    err_v_i,
	/* verilator lint_on UNUSEDSIGNAL*/	

	input [DATA_W-1:0] data_i, // tx data
	input [KEEP_W-1:0] keep_i,

	/* verilator lint_off ASCRANGE */
	/* verilator lint_off UNUSEDSIGNAL*/
	input [PART_MSB:0]        part_i,
	input [KEEP_NEXT_MSB:0]   keep_next_i,
	/* verilator lint_on UNUSEDSIGNAL*/	
	/* verilator lint_on ASCRANGE */

	output                    head_v_o,
	output [1:0]              sync_head_o, 
	output [DATA_W-1:0] data_o		
);
/* verilator lint_off UNUSEDPARAM*/
localparam [BLOCK_TYPE_W-1:0]
    BLOCK_TYPE_CTRL     = 8'h1e, // C7 C6 C5 C4 C3 C2 C1 C0 BT
    BLOCK_TYPE_OS_4     = 8'h2d, // D7 D6 D5 O4 C3 C2 C1 C0 BT
    BLOCK_TYPE_START_4  = 8'h33, // D7 D6 D5    C3 C2 C1 C0 BT
    BLOCK_TYPE_OS_START = 8'h66, // D7 D6 D5    O0 D3 D2 D1 BT
    BLOCK_TYPE_OS_04    = 8'h55, // D7 D6 D5 O4 O0 D3 D2 D1 BT
    BLOCK_TYPE_START_0  = 8'h78, // D7 D6 D5 D4 D3 D2 D1    BT
    BLOCK_TYPE_OS_0     = 8'h4b, // C7 C6 C5 C4 O0 D3 D2 D1 BT
    BLOCK_TYPE_TERM_0   = 8'h87, // C7 C6 C5 C4 C3 C2 C1    BT
    BLOCK_TYPE_TERM_1   = 8'h99, // C7 C6 C5 C4 C3 C2    D0 BT
    BLOCK_TYPE_TERM_2   = 8'haa, // C7 C6 C5 C4 C3    D1 D0 BT
    BLOCK_TYPE_TERM_3   = 8'hb4, // C7 C6 C5 C4    D2 D1 D0 BT
    BLOCK_TYPE_TERM_4   = 8'hcc, // C7 C6 C5    D3 D2 D1 D0 BT
    BLOCK_TYPE_TERM_5   = 8'hd2, // C7 C6    D4 D3 D2 D1 D0 BT
    BLOCK_TYPE_TERM_6   = 8'he1, // C7    D5 D4 D3 D2 D1 D0 BT
    BLOCK_TYPE_TERM_7   = 8'hff; //    D6 D5 D4 D3 D2 D1 D0 BT
/* verilator lint_on UNUSEDPARAM*/

localparam [CTRL_W-1:0] CTRL_IDLE = 7'h00;

logic part_zero;
// block type
logic [FULL_KEEP_W-1:0]  block_keep;
logic [FULL_KEEP_W-1:0]  term_mask_lite;
logic                    unused_term_mask_lite_of;
logic [BLOCK_TYPE_W-1:0] term_block_type;
// block type field
logic                    block_type_v;
logic [BLOCK_TYPE_W-1:0] block_type;
assign block_type_v = ctrl_v_i;

generate

if ( IS_10G ) begin : gen_is_10g_block_type	

assign block_type   = {BLOCK_TYPE_W{start_v_i[0] }} & BLOCK_TYPE_START_0
					| {BLOCK_TYPE_W{start_v_i[1] }} & BLOCK_TYPE_START_4
					| {BLOCK_TYPE_W{term_v_i}} & term_block_type
					| {BLOCK_TYPE_W{idle_v_i}} & BLOCK_TYPE_CTRL;

end else begin : gen_10g_block_type

// start signal can only be sent on lower order byte
assign block_type   = {BLOCK_TYPE_W{start_v_i}} & BLOCK_TYPE_START_0
					| {BLOCK_TYPE_W{term_v_i}} & term_block_type
					| {BLOCK_TYPE_W{idle_v_i}} & BLOCK_TYPE_CTRL;
end /* !IS_10G */

// terminate block type
if ( CNT_N > 1 ) begin : gen_cnt_n_gt_1_block_keep
	assign block_keep = { keep_next_i, keep_i };
end else begin : gen_cnt_n_eq_1_block_keep
	assign block_keep =  keep_i;
end

endgenerate

assign { unused_term_mask_lite_of, term_mask_lite } = block_keep + {{FULL_KEEP_W-1{1'b0}}, 1'b1};
always @(term_mask_lite) begin
	case ( term_mask_lite ) 
		8'b00000001 : term_block_type = BLOCK_TYPE_TERM_0;
		8'b00000010 : term_block_type = BLOCK_TYPE_TERM_1;
		8'b00000100 : term_block_type = BLOCK_TYPE_TERM_2;
		8'b00001000 : term_block_type = BLOCK_TYPE_TERM_3;
		8'b00010000 : term_block_type = BLOCK_TYPE_TERM_4;
		8'b00100000 : term_block_type = BLOCK_TYPE_TERM_5;
		8'b01000000 : term_block_type = BLOCK_TYPE_TERM_6;
		8'b10000000 : term_block_type = BLOCK_TYPE_TERM_7;
		default : term_block_type = 'X;
	endcase
end
// data 
logic [DATA_W-BLOCK_TYPE_W-1:0] data_ctrl;
assign data_ctrl = idle_v_i ? {8{CTRL_IDLE}} : data_i[DATA_W-1:BLOCK_TYPE_W];
// output data
assign data_o = { data_ctrl , block_type_v ? block_type : data_i[BLOCK_TYPE_W-1:0] };
// sync header data or control
// data 2'b01
// cntr 2'b10
assign head_v_o = part_zero;
assign sync_head_o   = { ctrl_v_i, ~ctrl_v_i };

// FSM
assign part_zero = part_i == 'd0; 

`ifdef FORMAL 

logic data_v_f;
assert data_v_f = ~(idle_v_i | err_v_i );
initial begin
	// assume reset
	a_nreset : assume( ~nreset );
end

always_comb begin
	// xcheck
	sva_xcheck_ctrl_i : assert( ~$isunknown({idle_v_i, start_v_i, term_v_i, err_v_i }));
	sva_xcheck_keep_i : assert ( ~data_v_f | data_v_f & ~$isunknown( keep_i )); 
	genvar f;
	generate 
		for( f=0; f < KEEP_W; f++) begin
			assert( ~(data_v_f&keep_i[f]) | data_v_f & keep_i[f] & ~$isunknown(data_i[f*8+7:f*8]));
		end
	endgenerate
	if ( BLOCK_W != DATA_W ) begin
	sva_xcheck_part_i : assert( ~data_v_f | data_v_f & ~$isunknown( part_i ));
	sva_xcheck_keep_next_i : assert( ~data_v_f | data_v_f & ~$isunknown( keep_next_i ));
	end
	// control signals
	sva_ctrl_onehot: assert( ~(part_zero & ctrl_v_i)  | part_zer & ctrl_v_i & ~$onehot({idle_v_i, start_v_i, term_v_i, err_v_i }));
end
`endif
endmodule
