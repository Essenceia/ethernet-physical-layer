/* fake reset module
 * Used to force reset signal for FPGA testbenches */
module fake_reset#(
	/* trigger reset when we detect and overflow on counter  */
	parameter CNT_W = 30
)(
	input clk,
	input fpga_reset_i,

	output fake_reset_o
);
logic    of_cnt_add;
logic [CNT_W-1:0] cnt_add;
logic [CNT_W-1:0] cnt_next; 
reg   [CNT_W-1:0] cnt_q;

assign { of_cnt_add, cnt_add } = cnt_q + {{CNT_W-1{1'b0}}, 1'b1};  

always @(posedge clk) begin
	if (fpga_reset_i) begin
		cnt_q <= {CNT_W{1'b0}};
	end else begin
		cnt_q <= cnt_next;
	end
end
assign fake_reset_o = of_cnt_add; 
endmodule 
