/* 64b/66b scrable, used for transmission path */
module scrambler_64b66b_tx #(
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
genvar i;
generate
	for (  i = 0; i < LEN; i++ ) begin : xor_loop
		if ( i <= I0 ) begin
			assign scram_o[i] = data_i[i] ^ ( s_q[I0-i] ^ s_q[I1-i] ); 
		end else if ( i <= I1 ) begin 
			assign scram_o[i] = data_i[i] ^ ( scram_o[i-(I0+1)] ^ s_q[I1-i] ); 
		end else begin
			assign scram_o[i] = data_i[i] ^
							 ( scram_o[i-(I0+1)] 
							^  scram_o[i-(I1+1)]); 
		end
	end

// flop prviously scrambled data
for( i = 0; i < S_W; i++ ) begin
	if ( LEN < S_W ) begin
		if( i < LEN ) begin 
			assign s_next[i] = scram_o[LEN-1-i];
		end else begin 
			assign s_next[i] = scram_q[LEN-1-i];
		end
	end else begin
		// LEN >= S_W
		assign s_next[i] = scram_o[LEN-1-i];
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

