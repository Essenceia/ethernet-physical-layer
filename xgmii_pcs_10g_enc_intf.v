/* interface between the 64b data wide xgmii interface and the pcs */
module xgmii_pcs_10g_enc_intf #(
	parameter XGMII_DATA_W = 64,
	parameter XGMII_KEEP_W = $clog2(XGMII_DATA_W),
	parameter XGMII_CTRL_W = 8,
	parameter BLOCK_W = 64,
	parameter HEAD_W  = 2 // sync header
)(
	input clk,
	input nreset,

	input [XGMII_DATA_W-1:0] xgmii_txd_i,
	input [XGMII_CTRL_W-1:0] xgmii_txc_i,

	output ctrl_v_o,
	output idle_v_o,
	output start_v_o,
	output term_v_o,
	output err_v_o,

	output [XGMII_KEEP_W-1:0] keep_o // data keep

);
localparam [XGMII_CTRL_W-1:0] 
	XGMII_CTRL_IDLE  = 8'h07,	
	XGMII_CTRL_START = 8'hfb,	
	XGMII_CTRL_TERM  = 8'hfd,
	XGMII_CTRL_ERR   = 8'hfe;
		
// translate xgmii control byte into individual signals
assign ctrl_v_o = |xgmii_txc_i;

// EOF
// eof can be on any xgmii lane, but is the first control position
// get the first ctrl bit
logic [XGMII_CTRL_W-1:0] lsb_ctrl_mask;
logic                    lsb_ctrl_mask_overflow;
logic [XGMII_CTRL_W-1:0] lsb_ctrl;
logic                    term_v_lite;
assign {lsb_ctrl_mask_overflow, lsb_ctrl_mask} = ~xgmii_txc_i + {XGMII_CTRL_W-1{1'b0} , 1'b1};
always_comb begin
	for( int i=0; i < XGMII_CTRL_W; i++) begin
		if( lsb_ctrl_mask[i] ) lsb_ctrl = xgmii_txd_i[i*8+7:i*8];
	end
end
assign term_v_lite = lsb_ctrl == XGMII_CTRL_TERM;

// data mask for end of block
logic [XGMII_KEEP_W-1:0] term_keep;
assign term_keep = ~xgmii_txc_i;

// SOF
// sof only present on lane 0 
logic has_data;
logic [XGMII_CTRL_W-1:0]  msb_lane0_ctrl;
logic start_v_lite;
assign has_data = ~xgmii_txc_i[XGMII_CTRL_W-1];
assign msb_lane0_ctrl =  {XGMII_DATA_W{ xgmii_txc_i[4]}} & xgmii_txd_i[4*8+7:4*8] 
					  |  {XGMII_DATA_W{  xgmii_txc_i[0] & ~xgmii_txc_i[4] }} & xgmii_txd_i[7:0]; 
assign start_v_lite = msb_lane0_ctrl == XGMII_CTRL_START;

// ERR
// TODO : Check the rules on error lane placement ?
logic err_v_lite;
assign err_v_lite = lsb_ctrl == XGMII_CTRL_ERR;
 
// IDLE
logic idle_v_lite;
assign idle_v_lite = lsb_ctrl == XGMII_CTRL_IDLE;

// Validity signals
assign start_v_o = start_v_lite & has_data;
assign term_v_o  = term_v_lite & ~has_data;
assign idle_v_o  = idle_v_lite & ~has_data;
assign err_v_o   = err_v_lite & ~has_data; 

`ifdef FORMAL
logic data_v_f;
assign data_v_f = start_v_o | term_v_o;
always_comb begin
	// xcheck
	sva_xcheck_xgmii_ctr : assert( ~$isunknown(xgmii_txc_i));
	sva_xcheck_xgmii_keep : assert(~data_v_f | data_v_f & ~$isunknown(keep_o));
end
`endif
endmodule
