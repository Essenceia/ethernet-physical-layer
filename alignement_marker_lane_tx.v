/* Create marker per lane, keep track of Bit Interleaved Parity value
*  when not creating market 
*/
module alignement_marker_lane_tx #(
	parameter HEAD_W  = 2,
	parameter DATA_W  = 64,
	parameter BLOCK_W = HEAD_W + DATA_W,
	// fixed encoding for this lane
	parameter LANE_ENC = { {8{1'bx}},8'hb8, 8'h89,8'h6f,{8{1'bx}}, 8'h47, 8'h76, 8'h90 }
)(
	input nreset,
	input clk,

	input               marker_v,
	input [BLOCK_W-1:0] data_i,

	output [BLOCK_W-1:0] data_o
);
localparam BIP_W = 8;
localparam SYNC_HEAD_CTRL = 2'b10;

reg   [BIP_W-1:0] bip_q;
logic [BIP_W-1:0] bip_next;
logic [BIP_W-1:0] bip_res;
logic [BIP_W-1:0] bip3;
logic [BIP_W-1:0] bip7;

assign bip_next = marker_v ? {BIP_W{1'b0}} : bip_res;

always @(posedge clk) begin
	if ( ~nreset ) begin
		bip_q <= {BIP_W{1'b0}};
	end else begin
		bip_q <= bip_next;
	end 
end
/* calculate bip
BIP 3 bit number Assigned 66-bit word bits
0                2, 10, 18, 26, 34, 42, 50, 58
1                3, 11, 19, 27, 35, 43, 51, 59
2                4, 12, 20, 28, 36, 44, 52, 60
3                0, 5, 13, 21, 29, 37, 45, 53, 61
4                1, 6, 14, 22, 30, 38, 46, 54, 62
5                7, 15, 23, 31, 39, 47, 55, 63
6                8, 16, 24, 32, 40, 48, 56, 64
7                9, 17, 25, 33, 41, 49, 57, 65
*/
assign bip_res[0] = bip_q[0] ^ 
	data_i[2]  ^ data_i[10] ^ data_i[18] ^ 
	data_i[26] ^ data_i[34] ^ data_i[42] ^ 
	data_i[50] ^ data_i[58];

assign bip_res[1] = bip_q[1] ^ 
	data_i[3]  ^ data_i[11] ^ data_i[19] ^ 
	data_i[27] ^ data_i[35] ^ data_i[43] ^ 
	data_i[51] ^ data_i[59];

assign bip_res[2] = bip_q[2] ^ 
	data_i[4]  ^ data_i[12] ^ data_i[20] ^ 
	data_i[28] ^ data_i[36] ^ data_i[44] ^ 
	data_i[52] ^ data_i[60];
assign bip_res[3] = bip_q[3] ^ data_i[0] ^ data_i[5 ] ^ data_i[13] ^ data_i[21] ^ data_i[29] ^ data_i[37] ^ data_i[45] ^ data_i[53] ^ data_i[61];
assign bip_res[4] = bip_q[4] ^ data_i[1] ^ data_i[6 ] ^ data_i[14] ^ data_i[22] ^ data_i[30] ^ data_i[38] ^ data_i[46] ^ data_i[54] ^ data_i[62];
assign bip_res[5] = bip_q[5] ^ data_i[7] ^ data_i[15] ^ data_i[23] ^ data_i[31] ^ data_i[39] ^ data_i[47] ^ data_i[55] ^ data_i[63];
assign bip_res[6] = bip_q[6] ^ data_i[8] ^ data_i[16] ^ data_i[24] ^ data_i[32] ^ data_i[40] ^ data_i[48] ^ data_i[56] ^ data_i[64];
assign bip_res[7] = bip_q[7] ^ data_i[9] ^ data_i[17] ^ data_i[25] ^ data_i[33] ^ data_i[41] ^ data_i[49] ^ data_i[57] ^ data_i[65];

// bip calculation includes previous alignement marker and
// all data in the gap
assign bip3 = bip_q;
assign bip7 = ~bip3;

// create new marker
logic [DATA_W-1:0] marker_data;
logic [HEAD_W-1:0] market_head;

assign market_head = SYNC_HEAD_CTRL;
genvar i;
generate 
	for( i = 0; i < 8; i++ ) begin
		if ( i == 3 ) assign marker_data[i*8+7:i*8] = bip3;
		else if ( i == 7 ) assign marker_data[i*8+7:i*8] = bip7;
		else assign marker_data[i*8+7:i*8] = LANE_ENC[i*8+7:i*8];
	end
endgenerate 

// output 
assign data_o = marker_v ? { marker_data, market_head } : data_i;
endmodule


