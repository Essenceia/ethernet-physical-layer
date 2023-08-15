/* Per lane deskew module.
* Buffers blocks to realign all lanes on the slowest.
* In order to save on buffer space we are discarding 
* the alignement marker at this stage.
 */
module deskew_lane_rx #(
	parameter BLOCK_W = 66,
	/* max dynamic skew */
	parameter MAX_SKEW_BIT_N = 1856,
	parameter MAX_SKEW_BLOCK_N = ( MAX_SKEW_BIT_N - BLOCK_W -1 )/BLOCK_W,
	parameter SKEW_CNT_W = $clog2(MAX_SKEW_BLOCK_N)
)(
	input clk,
	input nreset,

	input am_slip_v_i, // alignement marker block slip
	// lane alignement marker valid	
	//input am_v_i, 
	// have seen all the alignement markers 
	input am_full_lock_v_i,
	input [BLOCK_W-1:0] data_i,

	// has alignement marker stored
	//output am_v_o,

	// deskewed lane data
	output [BLOCK_W-1:0] data_o 
);

// keep track of skew 
reg   [SKEW_CNT_W-1:0] skew_q;
logic [SKEW_CNT_W-1:0] skew_next;  
logic [SKEW_CNT_W-1:0] skew_add;  
logic                  skew_add_overflow;  
logic skew_rst;
logic skew_en;

assign skew_rst = am_slip_v_i;

assign { skew_add_overflow, skew_add } = skew_q + { {SKEW_CNT_W-1{1'b0}}, 1'b1};
assign skew_next = skew_rst ? {SKEW_CNT_W{1'b0}} : skew_q;
assign skew_en = ~am_full_lock_v_i;
always @(posedge clk) begin
	if ( skew_en ) begin
		skew_q <= skew_next;
	end
end

// shift buffer
reg   [BLOCK_W-1:0] buff_q[MAX_SKEW_BLOCK_N-1:0];
logic [BLOCK_W-1:0] buff_next[MAX_SKEW_BLOCK_N-1:0]; 
assign buff_next[0] = data_i;
genvar i;
generate
	for(i=1; i < MAX_SKEW_BLOCK_N; i++ ) begin
		assign buff_next[i] = buff_q[i-1];
	end

	for(i=0; i < MAX_SKEW_BLOCK_N; i++) begin	
		always @(posedge clk) begin
			buff_q[i] <= buff_next[i];
		end
	end
endgenerate

// skew is used as read pointer
logic [BLOCK_W-1:0] buff_rd;
always_comb begin
	for(int j=0; j<MAX_SKEW_BLOCK_N; j++) begin
		if( skew_q == j ) buff_rd = buff_q[j];
	end
end
// output
assign data_o = buff_rd;
endmodule
