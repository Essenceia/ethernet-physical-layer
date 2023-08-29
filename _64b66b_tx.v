/* 64b/66b scrable, used for transmission path */
module _64b66b_tx #(
	parameter LEN    = 32 // size of each block in bits
)
(
	input clk,
	input nreset,

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
		if ( i <= I0 ) begin
			assign res[i] = data_i[i] ^ ( s_q[I0-i] ^ s_q[I1-i] ); 
		end else if ( i <= I1 ) begin 
			assign res[i] = data_i[i] ^ ( res[i-(I0+1)] ^ s_q[I1-i] ); 
		end else begin
			assign res[i] = data_i[i] ^
							 ( res[i-(I0+1)] 
							^  res[i-(I1+1)]); 
		end
	end
/* verilator lint_off UNOPTFLAT */

// flop prviously scrambled data
for( i = 0; i < S_W; i++ ) begin
	if ( LEN < S_W ) begin
		if( i < LEN ) begin 
			assign s_next[i] = res[LEN-1-i];
		end else begin 
			assign s_next[i] = s_q[i-LEN];
		end
	end else begin
		// LEN >= S_W
		assign s_next[i] = res[LEN-1-i];
	end
end
endgenerate

always @(posedge clk) begin
	if ( ~nreset ) begin
		// scrambler's initial start is set to all 1's
		s_q <= {S_W{1'b1}};
	end else begin
		s_q <= s_next;
	end
end

// output
assign scram_o = res;
endmodule

