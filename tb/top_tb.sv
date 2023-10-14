module top_tb;

reg OSC_50m;
reg GXB1D_644M;  // 644.53125MHz REF
reg GXB1D_125M;  // 125 MHz REF


initial begin
	$dumpfile("wave/top_tb.vcd");
	$dumpvars(0, top_tb);

	
end

top(
.serdes_rx_clk,
.serdes_tx_clk_o,
.serdes_rx_lock_i,
.serdes_rx_data_i,
.serdes_tx_clk,
.serdes_tx_data_o
);
endmodule
