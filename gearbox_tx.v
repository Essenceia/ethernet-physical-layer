/* Generic circular buffer
* Expected parameters for data widths : 16,32, 64
* Tested parameters : 16, 64 */
module gearbox_tx #(
	parameter BLOCK_DATA_W = 64,
	parameter DATA_W = 64,
	parameter HEAD_W = 2,
	parameter SEQ_W  = $clog2(DATA_W/HEAD_W)
)(
	input clk,
	input nreset,

	input [SEQ_W-1:0]  seq_i, // sequence cnt
	input [HEAD_W-1:0] head_i, // sync header
	input [DATA_W-1:0] data_i,

	// gearbox output
	output              full_v_o, // backpressure, buffer is full, need a cycle to clear 
	output [DATA_W-1:0] data_o
);
localparam CNT_N   = BLOCK_DATA_W/DATA_W;
localparam CNT_W   = $clog2(CNT_N);
//localparam FIFO_W   = 2*(BLOCK_DATA_W+HEAD_W);
localparam FIFO_W  = DATA_W;
localparam SHIFT_N = DATA_W/HEAD_W;

// current fifo depth is derrived from the sequence number
logic [FIFO_W-1:0] fifo_next;
reg   [FIFO_W-1:0] fifo_q;
logic [FIFO_W-1:0] rd_data;
logic [FIFO_W-1:0] wr_data;
// input sync header is valid
logic head_v;

if ( DATA_W == BLOCK_DATA_W ) begin
	assign head_v = 1'b1;
end else begin
	assign head_v = ~|seq_i[CNT_W:0];
end

// shift data
localparam MASK_ARR_W = FIFO_W / HEAD_W;

logic [SHIFT_N-1:0] shift_sel;
logic [FIFO_W-1:0] wr_data_shifted_arr[SHIFT_N-1:0];
logic [FIFO_W-1:0] rd_data_shifted_arr[SHIFT_N-1:0];
logic [FIFO_W-1:0] wr_data_shifted;
logic [FIFO_W-1:0] rd_data_shifted;
logic [MASK_ARR_W-1:0] wr_mask_lite_shifted_arr[SHIFT_N-1:0];
logic [MASK_ARR_W-1:0] rd_fifo_mask_lite_shifted_arr[SHIFT_N-1:0];
logic [MASK_ARR_W-1:0] wr_mask_lite_shifted;
logic [MASK_ARR_W-1:0] rd_fifo_mask_lite_shifted;
logic [FIFO_W-1:0]     wr_mask; // full version of the mask
logic [FIFO_W-1:0]     rd_fifo_mask; // full version of the mask
genvar i;
generate
	for( i = 0; i < SHIFT_N; i++ ) begin
		// data
		assign wr_data_shifted_arr[i] = { {FIFO_W-HEAD_W-i{1'bx}} , data_i[DATA_W-1:DATA_W-HEAD_W-i] } ;
		assign rd_data_shifted_arr[i] = { data_i[DATA_W-1-i:0], {i{1'bx}}} ;
		// mask
		assign wr_mask_lite_shifted_arr[i] = { {MASK_ARR_W-i-1{1'b0}} ,head_v, {i{1'b1}} };
		assign rd_fifo_mask_lite_shifted_arr[i] = { {MASK_ARR_W-i{1'b0}} , {i{1'b1}} };
		// sel
		assign shift_sel[i] = ( seq_i == i );
	end 
endgenerate
always_comb begin
	for( int x=0; x < SHIFT_N; x++) begin
		if ( shift_sel[x] ) wr_data_shifted = wr_data_shifted_arr[x];
		if ( shift_sel[x] ) rd_data_shifted = rd_data_shifted_arr[x];
		if ( shift_sel[x] ) wr_mask_lite_shifted = wr_mask_lite_shifted_arr[x]; 
		if ( shift_sel[x] ) rd_fifo_mask_lite_shifted = rd_fifo_mask_lite_shifted_arr[x]; 
	end
end
// extend masks
generate
	for( i = 0; i < MASK_ARR_W; i++ ) begin
		assign wr_mask[i*HEAD_W+HEAD_W-1:i*HEAD_W] = {HEAD_W{wr_mask_lite_shifted[i] }};
		assign rd_fifo_mask[i*HEAD_W+HEAD_W-1:i*HEAD_W] = {HEAD_W{rd_fifo_mask_lite_shifted[i] }};
	end
endgenerate
// buf data
assign fifo_next = wr_mask & wr_data_shifted;
always @(posedge clk) begin
	fifo_q <= fifo_next;
end

// buffer is full
assign full_v_o = &seq_i;
assign data_o = rd_fifo_mask & fifo_q | ~rd_fifo_mask & rd_data_shifted;
endmodule
