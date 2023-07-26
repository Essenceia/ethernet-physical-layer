/* PCS encode block
*
* Add control additional control blocks.
*
* Limitations :
* - At the end of a packet, if packet size is a multiple
*   of the block size we need a CNT_N cycle pause to sent
*   a block with the terminate control
*/
module pcs_10g_enc_lite #(
	parameter XGMII_DATA_W = 64,
	parameter XGMII_KEEP_W = $clog2(XGMII_DATA_W),
	parameter BLOCK_W = 64,
	parameter CNT_N = BLOCK_W/XGMII_DATA_W,
	parameter CNT_W = $clog2( CNT_N ),

	parameter FULL_KEEP_W = CNT_N*XGMII_KEEP_W,
	parameter BLOCK_TYPE_W = 8,
	parameter CTRL_W  = 7
)(
	// data clk
	input clk,
	input nreset,

	input                    ctrl_v_i,
	input                    idle_v_i,
	input                    start_i,
	input                    term_i,
	input                    err_i,
	input [XGMII_DATA_W-1:0] data_i, // tx data
	input [XGMII_KEEP_W-1:0] keep_i,

	input [CNT_W-1:0]                  part_i,
	input [(CNT_N-1)*XGMII_KEEP_W-1:0] keep_next_i,


	output                    head_v_o,
	output [1:0]              sync_head_o, 
	output [XGMII_DATA_W-1:0] data_o		
);
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

localparam [CTRL_W-1:0] CTRL_IDLE = 7'h07;

// fsm
reg   fsm_idle_q;
reg   fsm_data_q;
reg   fsm_end_delay_q;
logic last_v;
logic ctrl_v;
logic idle_v;
logic fsm_idle_next;
logic fsm_data_next;
logic fsm_end_delay_next;
logic fsm_end;
logic fsm_en;
logic part_zero;
// block type
logic [FULL_KEEP_W-1:0]  block_keep_lite;
logic [FULL_KEEP_W-1:0]  block_keep;
logic [FULL_KEEP_W-1:0]  term_mask_lite;
logic                    term_mask_lite_overflow;
logic [BLOCK_TYPE_W-1:0] term_block_type;
logic                    keep_full;
// block type field
logic                    block_type_v;
logic [BLOCK_TYPE_W-1:0] block_type;
assign block_type_v = ctrl_v;
assign block_type   = {BLOCK_TYPE_W{start_i & ~last_v}} & BLOCK_TYPE_OS_0
					| {BLOCK_TYPE_W{last_v}} & term_block_type
					| {BLOCK_TYPE_W{idle_v}} & BLOCK_TYPE_CTRL;

// terminate block type
assign block_keep_lite = { keep_next_i, keep_i };
assign block_keep = { BLOCK_W{~fsm_end_delay_q}} & block_keep_lite;
assign keep_full  = &block_keep_lite;
assign { term_mask_lite_overflow, term_mask_lite } = block_keep + {{FULL_KEEP_W-1{1'b0}}, 1'b1};
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
logic [XGMII_DATA_W-BLOCK_TYPE_W-1:0] data_ctrl;
assign data_ctrl = idle_v ? {8{CTRL_IDLE}} : data_i[XGMII_DATA_W-1:BLOCK_TYPE_W];
// output data
assign data_o = { data_ctrl , block_type_v ? block_type : data_i[BLOCK_TYPE_W-1:0] };
// sync header data or control
// data 2'b01
// cntr 2'b10
assign head_v_o = part_zero;
assign sync_head_o   = { ctrl_v , ~ctrl_v };

// FSM
assign part_zero = part_i == 'd0; 

assign last_v = ( ~keep_full & term_i ) | fsm_end_delay_q;
assign ctrl_v = ( start_i | last_v | idle_v_i ) & part_zero;
assign idle_v = idle_v_i & ~fsm_end_delay_q;

assign fsm_idle_next = ( last_v & ~keep_full ) | fsm_end_delay_q 
					 | fsm_idle_q & ~( start_i & ~idle_v_i );
assign fsm_data_next = ( start_i & ~idle_v_i ) &  | fsm_data_q & last_v; 

// last packet was received but there is no space to insert block type to
// signal this is the terminate control data. We will sent terminate packet
// in next block
assign fsm_end_delay_next = fsm_data_q & term_i & keep_full;

assign fsm_en = part_zero & ( ~idle_v_i | fsm_end_delay_q );

always @(posedge clk) begin
	if ( ~nreset ) begin
		fsm_idle_q  <= 1'b1;
		fsm_data_q  <= 1'b0;
		fsm_end_delay_q <= 1'b0;
	end else if ( fsm_en ) begin
		fsm_idle_q  <= fsm_idle_next;
		fsm_data_q  <= fsm_data_next;
		fsm_end_delay_q <= fsm_end_delay_next;
	end
end

`ifdef FORMAL 

logic data_v_f;
assert data_v_f = ~(idle_v_i | err_i );
initial begin
	// assume reset
	a_nreset : assume( ~nreset );
end

always_comb begin
	// xcheck
	sva_xcheck_ctrl_i : assert( ~$isunknown({idle_v_i, start_i, term_i, err_i }));
	sva_xcheck_keep_i : assert ( ~data_v_f | data_v_f & ~$isunknown( keep_i )); 
	genvar f;
	generate 
		for( f=0; f < XGMII_KEEP_W; f++) begin
			assert( ~(data_v_f&keep_i[f]) | data_v_f & keep_i[f] & ~$isunknown(data_i[f*8+7:f*8]));
		end
	endgenerate
	if ( BLOCK_W != XGMII_DATA_W ) begin
	sva_xcheck_part_i : assert( ~data_v_f | data_v_f & ~$isunknown( part_i ));
	sva_xcheck_keep_next_i : assert( ~data_v_f | data_v_f & ~$isunknown( keep_next_i ));
	end
	// fsm
	sva_fsm_onehote : assert( $onehot( { fsm_idle_q, fsm_data_q, fsm_end_delay_q });
end
`endif
endmodule
