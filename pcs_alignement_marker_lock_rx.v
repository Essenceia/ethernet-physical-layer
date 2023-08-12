module pcs_alignement_marker_lock_rx #(
	parameter BLOCK_W = 66
)(
	input clk,
	input nreset,

	input               valid_i,
	input [BLOCK_W-1:0] block_i,

	output              slip_v_o,
	output              lock_v_o,
	output [LANE_N-1:0] lane_o	
);
localparam GAP_N = 16383;
localparam GAP_W = $clog2(GAP_N);
localparam CNT_N = 2;
localparam CNT_W = $clog2(CNT_N);
localparam NV_CNT_N = 4; 
localparam NV_CNT_W = $clog2(NV_CNT_N);

// counters
logic [CNT_W-1:0] cnt_next;
reg   [CNT_W-1:0] cnt_q;
logic [NV_CNT_W-1:0] nv_cnt_next;
reg   [NV_CNT_W-1:0] nv_cnt_q;
logic cnt_rst_v;

assign cnt_rst_v = invalid_q; 

assign cnt_next    = cnt_rst_v ? {CNT_W{1'b0}}    : cnt_add;
assign nv_cnt_next = cnt_rst_v ? {NV_CNT_W{1'b0}} : cnt_add;


always @(posedge clk) begin
	cnt_q <= cnt_next;
	nv_cnt_q <= nv_cnt_next;
end
// current lane
reg   [LANE_W-1:0] lane_q;
logic [LANE_W-1:0] lane_next;
logic [LANE_W-1:0] lane_match;
always @(posedge clk) begin
	lane_q <= lane_next;
end
// fsm
reg   sync_q;
logic sync_next;
reg   lock_q;
logic lock_next;
reg   invalid_q;
logic invalid_next;

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
assign lane_o   = lane_q;

`ifdef FORMAL
logic [2:0] f_fsm;
assign f_fsm = { invalid_q , sync_q , lock_q };

always @(posedge clk) begin
	if ( nreset ) begin
		sva_fsm_onehot(f_fsm);
	end
end
`endif
endmodule
