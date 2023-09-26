/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

/* 64b66b descrambler used for the rx path.
*
* data(x) = sdata(x) ^ sdata_lsr(38) ^ sdata_lsr(57) */
module _64b66b_rx #(
	// descrabler input data
	parameter LEN = 264
)(
	input nreset,
	input clk,

	input            valid_i,
	input  [LEN-1:0] scram_i,
	output [LEN-1:0] data_o
);
localparam I0 = 38;
localparam I1 = 57;
localparam S_W = I1+1;
// save last bit of previously inputed scrambled data 
reg   [S_W-1:0] s_q;
logic [S_W-1:0] s_next;

// unscrable
genvar i;
generate
	for (  i = 0; i < LEN; i++ ) begin : xor_loop
		if ( i <= I0 ) begin : gen_i_le_I0
			assign data_o[i] = scram_i[i] ^ (s_q[I0-i] ^ s_q[I1-i]);	
		end else if ( i <= I1 ) begin : gen_i_le_I1
			assign data_o[i] = scram_i[i] ^ (scram_i[i-(I0+1)] ^ s_q[I1-i]);	
		end else begin : gen_i_default
			assign data_o[i] = scram_i[i] ^ (scram_i[i-(I0+1)] ^ scram_i[i-(I1+1)]);	
		end
	end

	for( i=0; i < S_W; i++) begin : gen_s_next_loop	
		// flop input data to be used next cycle
		if ( i < LEN ) begin : gen_i_lt_len
			// input data is larger than internal state, rewite all bits
			assign s_next[i] = scram_i[LEN-1-i];
		end else begin : gen_i_ge_len
			// input data is smaller than internal state, shift
			// state and rewrite only lower order bits
			assign s_next[i] = s_q[i-LEN];
		end
	end

endgenerate

always @(posedge clk) begin
	if ( ~nreset ) begin
		// scrambler's initial start is set to all 1's
		s_q <= {S_W{1'b1}};
	end else if(valid_i) begin
		s_q <= s_next;
	end
end

endmodule

