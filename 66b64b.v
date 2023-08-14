/* 64b66b descrambler used for the rx path.
*
* data(x) = sdata(x) ^ sdata_lsr(38) ^ sdata_lsr(57)
 */
module descrambler_64b66b_rx #(
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
		if ( i <= I0 ) begin
			assign data_o[i] = scram_i[i] ^ (s_q[I0-i] ^ s_q[I1-i]);	
		end else if ( i <= I1 ) begin
			assign data_o[i] = scram_i[i] ^ (scram_i[i-I0] ^ s_q[I1-i]);	
		end else begin
			assign data_o[i] = scram_i[i] ^ (scram_i[i-I0] ^ scram_i[i-I1]);	
		end
	end

	for( i=0; i < S_W; i++) begin	
	// flop input data to be used next cycle
	if ( i < LEN ) begin
		// input data is larger than internal state, rewite all bits
		assign s_next[i] = scram_i[LEN-1-i];
	end else begin
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
