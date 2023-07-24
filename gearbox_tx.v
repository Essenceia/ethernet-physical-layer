/* Generic circular buffer
* Expected parameters for data widths : 16,32, 64
* Tested parameters : 16, 64 */
module gearbox_tx #(
	parameter BLOCK_DATA_W = 64,
	parameter DATA_W = 64,
	parameter HEAD_W = 2,
	parameter SEQ_W  = $clog2(DATA_W)
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
localparam BUF_W   = 2*(BLOCK_DATA_W+HEAD_W);
localparam SHIFT_N = DATA_W/HEAD_W;

logic [BUF_W-1:0] buf_next;
reg   [BUF_W-1:0] buf_q;
logic [BUF_W-1:0] data_shifted;
// input sync header is valid
logic head_v;

if ( DATA_W == BLOCK_DATA_W ) begin
	assign head_v = 1'b1;
end else begin
	assign head_v = ~|seq_i[CNT_W:0];
end

// shift data
 
logic [BUF_W-1:0] mask_shifted_arr[SHIFT_N-1:0];
logic [BUF_W-1:0] data_shifted_arr[SHIFT_N-1:0];
genvar i;
generate
	for( i = 0; i < SHIFT_N; i++ ) begin
		assign data_shifted_arr[i] = { {DATA_W-(HEAD_W*i)-HEAD_W{1'bx}} , head_i, data_i, {i*HEAD_W{1'bx}}};
		assign mask_shifted_arr[i] = { {SHIFT_N-i-1{1'b0}}, head_v, {SHIFT_N{1'b1}} ,{i{1'b0}}};
	end 
endgenerate

endmodule
