/* XGMII and XLGMII decoder interface, used on rx*/

module xgmii_dec_intf_rx #(
	parameter IS_40G = 1, // are comunicating with XLGMII 
	parameter XGMII_DATA_W = 64,	
	parameter XGMII_CTRL_W = XGMII_DATA_W/8,	
	parameter LANE0_CNT_N  = IS_40G ? 1 : 2,
	parameter DATA_W = 64,
	parameter KEEP_W = DATA_W/8,
	parameter HEAD_W = 2,
	parameter CTRL_W = 8

)(
 	// output of decoder
 	input                    ctrl_v_i,
	input                    idle_v_i,
	input [LANE0_CNT_N-1:0]  start_v_i,
	input                    term_v_i,
	input                    err_v_i,
	input                    ord_v_i,
	input [DATA_W-1:0]       data_i, // x(l)gmii data
	input [KEEP_W-1:0]       keep_i, 
	
	output [XGMII_DATA_W-1:0] xgmii_txd_o,
	output [XGMII_CTRL_W-1:0] xgmii_txc_o
);

localparam [CTRL_W-1:0] 
	XGMII_CTRL_IDLE  = 8'h07,	
	XGMII_CTRL_START = 8'hfb,	
	XGMII_CTRL_TERM  = 8'hfd,
	XGMII_CTRL_ERR   = 8'hfe;

// re-translate term to onehot, we undo modifs done in the
// dec as our primary use case don't target the x(l)gmii 
logic [XGMII_CTRL_W-1:0] term_onehot;
assign term_onehot = {XGMII_CTRL_W{term_v_i}} 
                   & (( keep_i - 'd1 ) ^ keep_i );
// xgmii control codes
logic [CTRL_W-1:0] ctrl_code;

assign ctrl_code = {CTRL_W{idle_v_i}}   & XGMII_CTRL_IDLE
				 | {CTRL_W{|start_v_i}} & XGMII_CTRL_START 
				 | {CTRL_W{term_v_i}}   & XGMII_CTRL_TERM  
				 | {CTRL_W{err_v_i}}    & XGMII_CTRL_ERR;


logic [XGMII_CTRL_W-1:0] ctrl_lane_v;

assign ctrl_lane_v[0] = idle_v_i | start_v_i[0] | err_v_i | term_onehot[0];

genvar i;
generate
	for(i=1; i< XGMII_CTRL_W; i++) begin
		if ( !IS_40G && i == 3 ) begin
			assign ctrl_lane_v[i] = start_v_i[1] | term_onehot[i];
		end	else begin
			assign ctrl_lane_v[i] = term_onehot[i];
		end	
	end
	for(i=0; i< XGMII_CTRL_W; i++) begin
		assign xgmii_txd_o[i*CTRL_W+CTRL_W-1:i*CTRL_W] = ctrl_lane_v[i] ? ctrl_code : data_i[i*CTRL_W+CTRL_W-1:i*CTRL_W];	
	end
endgenerate

assign xgmii_txc_o = ctrl_lane_v;  

// overwrite 
endmodule
