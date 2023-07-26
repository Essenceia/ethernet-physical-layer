/* PCS on the transmission path */
module pcs_10g_tx#(
	parameter XGMII_DATA_W = 32,
	parameter XGMII_KEEP_W = $clog2(XGMII_DATA_W),
	parameter BLOCK_W = 64,
	parameter CNT_N = BLOCK_W/XGMII_DATA_W,
	parameter CNT_W = $clog2( CNT_N ),
	parameter BLOCK_TYPE_W = 8,
	
	parameter PMA_DATA_W = 16, 
	parameter PMA_CNT_N  = XGMII_DATA_W/PMA_DATA_W
)(
	input clk,
	input nreset,

	// MAC
	input                    ctrl_v_i,
	input                    idle_v_i,
	input                    start_i,
	input                    term_i,
	input                    err_i,
	input [XGMII_DATA_W-1:0] data_i, // tx data
	input [XGMII_KEEP_W-1:0] keep_i,

	input [CNT_W-1:0]                  part_i,
	input [(CNT_N-1)*XGMII_KEEP_W-1:0] keep_next_i,

	output                           ready_o,	
	// PMA
	output [PMA_CNT_N*PMA_DATA_W-1:0] data_o
);
localparam HEAD_W = 2;
localparam SEQ_W  = $clog2(XGMII_DATA_W/HEAD_W+1);
// data
logic [XGMII_DATA_W-1:0] data_enc; // encoded
logic [XGMII_DATA_W-1:0] data_scram; // scrambled
// sync header
logic       sync_head_v;
logic [1:0] sync_head;
logic       gearbox_full;

// pcs fsm
logic             seq_rst;
logic [SEQ_W-1:0] seq_next;
logic [SEQ_W-1:0] seq_inc;
logic             seq_inc_overflow;
reg   [SEQ_W-1:0] seq_q;

assign seq_rst = gearbox_full;
assign { seq_inc_overflow, seq_inc } = seq_q + {{SEQ_W-1{1'b0}} , 1'b1};
assign seq_next = seq_rst ? {SEQ_W{1'b0}} : seq_inc;
always @(posedge clk) begin
	if ( ~nreset ) begin
		seq_q <= {SEQ_W{1'b0}};
	end else begin
		seq_q <= seq_next;
	end
end

// encode
pcs_10g_enc_lite #(.XGMII_DATA_W(XGMII_DATA_W))
m_pcs_enc(
	.clk(clk),
	.nreset(nreset),

	.ctrl_v_i(ctrl_v_i),
	.idle_v_i(idle_v_i),
	.start_i(start_i),
	.term_i(term_i),
	.err_i(err_i),
	.part_i(seq_q[CNT_W-1:0]),
	.data_i(data_i), // tx data
	.keep_i(keep_i),
	.keep_next_i(keep_next_i),
	.head_v_o(sync_head_v),
	.sync_head_o(sync_head), 
	.data_o(data_enc)	
);
// scramble
scrambler_64b66b_tx #(.LEN(XGMII_DATA_W))
m_64b66b_tx(
	.clk(clk),
	.nreset(nreset),
	.data_i(data_enc),
	.scram_o(data_scram)
);

// gearbox
gearbox_tx #( .DATA_W(XGMII_DATA_W))
m_gearbox_tx (
	.clk(clk),
	.nreset(nreset),
	.seq_i(seq_q),
	.head_i(sync_head),
	.data_i(data_scram),
	.full_v_o(gearbox_full),
	.data_o(data_o)
);
assign ready_o = ~gearbox_full;
endmodule
