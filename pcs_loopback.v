/* PCS loopback module
 * Used for FPGA testing purposes.
 * Seperated into it's own module for cleaner
 * timing constraints rule. */
module pcs_loopback#(
	parameter LANE0_CNT_N = 1,
	parameter DATA_W = 64,
	localparam KEEP_W = DATA_W/8
)(
	input rx_clk,
	input tx_clk,
	input rx_nreset,
	output logic tx_nreset,

	/* From RX PCS */
	input                   pcs_rx_ctrl_i,
	input                   pcs_rx_idle_i,
	input                   pcs_rx_term_i,
	input                   pcs_rx_err_i,
	input [LANE0_CNT_N-1:0] pcs_rx_start_i,
	input [DATA_W-1:0]      pcs_rx_data_i,
	input [KEEP_W-1:0]      pcs_rx_keep_i,

	/* To TX PCS */	
	output logic                   pcs_tx_ctrl_o,
	output logic                   pcs_tx_idle_o,
	output logic                   pcs_tx_term_o,
	output logic                   pcs_tx_err_o,
	output logic [LANE0_CNT_N-1:0] pcs_tx_start_o,
	output logic [DATA_W-1:0]      pcs_tx_data_o,
	output logic [KEEP_W-1:0]      pcs_tx_keep_o
);

/* RX -> TX loopback 
 * flop nreset for 2 cycle to have rx and tx gearbox 
 * idle cycles in sync  */
reg pcs_rx_nreset_q;
reg pcs_tx_nreset_next;

always @(posedge rx_clk) begin
	pcs_rx_nreset_q <= rx_nreset;
end 
always @(posedge tx_clk) begin
	pcs_tx_nreset_next <= pcs_rx_nreset_q; 	
	tx_nreset          <= pcs_tx_nreset_next; 	
end


/* Flop rx pcs output data */
reg                   pcs_rx_ctrl_q;
reg                   pcs_rx_idle_q;
reg                   pcs_rx_term_q;
reg                   pcs_rx_err_q;
reg [LANE0_CNT_N-1:0] pcs_rx_start_q;
reg [DATA_W-1:0]      pcs_rx_data_q;
reg [KEEP_W-1:0]      pcs_rx_keep_q;

always @(posedge rx_clk) begin
	pcs_rx_ctrl_q  <= pcs_rx_ctrl_i;
	pcs_rx_idle_q  <= pcs_rx_idle_i;
	pcs_rx_term_q  <= pcs_rx_term_i;
	pcs_rx_err_q   <= pcs_rx_err_i;	
	pcs_rx_start_q <= pcs_rx_start_i;
	pcs_rx_data_q  <= pcs_rx_data_i;
	pcs_rx_keep_q  <= pcs_rx_keep_i;
end
/* Empty cycle, both clks run at the
 * same frequencies but at different
 * phase */
always @(posedge tx_clk) begin
	pcs_tx_ctrl_o  <= pcs_rx_ctrl_q;
	pcs_tx_idle_o  <= pcs_rx_idle_q;
	pcs_tx_term_o  <= pcs_rx_term_q;
	pcs_tx_err_o   <= pcs_rx_err_q;	
	pcs_tx_start_o <= pcs_rx_start_q;
	pcs_tx_data_o  <= pcs_rx_data_q;
	pcs_tx_keep_o  <= pcs_rx_keep_q;
end

endmodule
