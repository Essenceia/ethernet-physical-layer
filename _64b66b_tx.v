/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

/* 64b/66b scrable, used for transmission path */
module _64b66b_tx #(
	parameter LEN    = 32 // size of each block in bits
)
(
	input clk,
	input nreset,

	input            valid_i,
	input  [LEN-1:0] data_i,
	output [LEN-1:0] scram_o
);
localparam I0 = 38;
localparam I1 = 57;
localparam S_W = I1+1;
// S_58 to S_0, previously scrambled data
reg   [S_W-1:0] s_q;
logic [S_W-1:0] s_next;
// scramble

/* linter sees this as a circular combinational
* logic, there will be a dependancy on sub-indexed on the
* scramble result, but this graph is a tree */
/* verilator lint_off UNOPTFLAT */
logic [LEN-1:0] res;

genvar i;
generate
	for (  i = 0; i < LEN; i++ ) begin : xor_loop
		if ( i <= I0 ) begin : gen_i_le_I0
			assign res[i] = data_i[i] ^ ( s_q[I0-i] ^ s_q[I1-i] ); 
		end else if ( i <= I1 ) begin  : gen_i_le_I1
			assign res[i] = data_i[i] ^ ( res[i-(I0+1)] ^ s_q[I1-i] ); 
		end else begin : gen_i_gt_I1
			assign res[i] = data_i[i] ^
							 ( res[i-(I0+1)] 
							^  res[i-(I1+1)]); 
		end
	end
/* verilator lint_off UNOPTFLAT */

// flop previously scrambled data
for( i = 0; i < S_W; i++ ) begin : s_next_loop
	if ( LEN < S_W ) begin : gen_len_lt_s_w
		if( i < LEN ) begin: gen_i_lt_len
			assign s_next[i] = res[LEN-1-i];
		end else begin: gen_i_ge_len
			assign s_next[i] = s_q[i-LEN];
		end
	end else begin: gen_len_ge_s_w
		// LEN >= S_W
		assign s_next[i] = res[LEN-1-i];
	end
end
endgenerate

always @(posedge clk) begin
	if ( ~nreset ) begin
		// scrambler's initial start is set to all 1's
		s_q <= {S_W{1'b1}};
	end else if (valid_i) begin
		s_q <= s_next;
	end
end

// output
assign scram_o = res;
endmodule

