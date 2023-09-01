/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

/* Create marker per lane, keep track of Bit Interleaved Parity value
*  when not creating market */
module am_lane_tx #(
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
logic [BIP_W-1:0] bip_pre;
logic [BIP_W-1:0] bip3;
logic [BIP_W-1:0] bip7;

assign bip_pre = marker_v ? {BIP_W{1'b0}} : bip_q;

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
assign bip_next[0] = bip_pre[0] ^ 
	data_o[2]  ^ data_o[10] ^ data_o[18] ^ 
	data_o[26] ^ data_o[34] ^ data_o[42] ^ 
	data_o[50] ^ data_o[58];

assign bip_next[1] = bip_pre[1] ^ 
	data_o[3]  ^ data_o[11] ^ data_o[19] ^ 
	data_o[27] ^ data_o[35] ^ data_o[43] ^ 
	data_o[51] ^ data_o[59];

assign bip_next[2] = bip_pre[2] ^ 
	data_o[4]  ^ data_o[12] ^ data_o[20] ^ 
	data_o[28] ^ data_o[36] ^ data_o[44] ^ 
	data_o[52] ^ data_o[60];
assign bip_next[3] = bip_pre[3] ^ data_o[0] ^ data_o[5 ] ^ data_o[13] ^ data_o[21] ^ data_o[29] ^ data_o[37] ^ data_o[45] ^ data_o[53] ^ data_o[61];
assign bip_next[4] = bip_pre[4] ^ data_o[1] ^ data_o[6 ] ^ data_o[14] ^ data_o[22] ^ data_o[30] ^ data_o[38] ^ data_o[46] ^ data_o[54] ^ data_o[62];
assign bip_next[5] = bip_pre[5] ^ data_o[7] ^ data_o[15] ^ data_o[23] ^ data_o[31] ^ data_o[39] ^ data_o[47] ^ data_o[55] ^ data_o[63];
assign bip_next[6] = bip_pre[6] ^ data_o[8] ^ data_o[16] ^ data_o[24] ^ data_o[32] ^ data_o[40] ^ data_o[48] ^ data_o[56] ^ data_o[64];
assign bip_next[7] = bip_pre[7] ^ data_o[9] ^ data_o[17] ^ data_o[25] ^ data_o[33] ^ data_o[41] ^ data_o[49] ^ data_o[57] ^ data_o[65];

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


