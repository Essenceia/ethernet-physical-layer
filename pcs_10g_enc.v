/* 10g pcs enc wrapper for xgmii 64b data interface  */
module pcs_10g_enc #(
	parameter XGMII_DATA_W = 64,
	parameter XGMII_KEEP_W = $clog2(XGMII_DATA_W),
	parameter XGMII_CTRL_W = 8,
	parameter BLOCK_W = 64,
	parameter HEAD_W  = 2 // sync header
)(
	input clk,
	input nreset,

	input [XGMII_DATA_W-1:0] xgmii_txd_i,
	input [XGMII_KEEP_W-1:0] xgmii_txk_i,
	input [XGMII_CTRL_W-1:0] xgmii_txc_i,

	output                   head_v_o,
	output [HEAD_W-1:0]      sync_head_o,
	output [BLOCK_W-1:0]     data_o
);
localparam [XGMII_CTRL_W-1:0] 
	XGMII_CTRL_DATA  = 8'h00,	
	XGMII_CTRL_IDLE  = 8'h07,	
	XGMII_CTRL_START = 8'hfb,	
	XGMII_CTRL_TERM  = 8'hfd,
	XGMII_CTRL_ERR   = 8'hfe;
		
// translate xgmii control byte into individual signals
logic idle_v;
logic start_v;
logic last_v;
logic err_v;
always @( xgmii_txc_i )begin
		case  ( xgmii_txc_i )
			XGMII_CTRL_DATA  : { idle_v, start_v, last_v, err_v } = 4'b0000;
			XGMII_CTRL_IDLE  : { idle_v, start_v, last_v, err_v } = 4'b1000;
			XGMII_CTRL_START : { idle_v, start_v, last_v, err_v } = 4'b0100;
			XGMII_CTRL_TERM  : { idle_v, start_v, last_v, err_v } = 4'b0010;
			XGMII_CTRL_ERR   : { idle_v, start_v, last_v, err_v } = 4'b0001;
		default : { idle_v, start_v, last_v, err_v } = 4'b0001; // send error
	endcase
end

pcs_10g_enc_lite #(.XGMII_DATA_W(XGMII_DATA_W))
m_pcs_10g_enc_lite(
.clk(clk),
.nreset(nreset),

.idle_v_i(idle_v),
.start_i(start_v),
.last_i(last_v),
.err_i(err_v),

.data_i(xgmii_txd_i),
.keep_i(xgmii_txk_i),

.head_v_o(head_v_o),
.sync_head_o(sync_head_o), 
.data_o(data_o)	
);


endmodule
