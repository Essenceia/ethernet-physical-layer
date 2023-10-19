/* 10G PCS loopback data used in fpga test */
module pcs_10g_loopback #(
	localparam IS_10G = 1,
	localparam DATA_W = 64
)(
	/* parallel clk */
	input rx_par_clk,
	input tx_par_clk,
	/* logic negative reset */
	input nreset,

	/* gx transiver rx */	
	input              rx_locked_i,
	input [DATA_W-1:0] rx_par_data_i,

	/* gx transiver tx */
	output [DATA_W-1:0] tx_par_data_o	
);

localparam LANE0_CNT_N = !IS_10G ? 1 : 2;
localparam KEEP_W = DATA_W/8;

/* PCS RX */
logic                   rx_ctrl;
logic                   rx_idle;
logic                   rx_term;
logic                   rx_err;
logic [LANE0_CNT_N-1:0] rx_start;
logic [DATA_W-1:0]      rx_data;
logic [KEEP_W-1:0]      rx_keep;

/* verilator lint_off UNUSEDSIGNAL */
logic                   rx_signal_ok;
logic                   rx_valid;
/* verilator lint_on UNUSEDSIGNAL */

 pcs_rx #(
	.IS_10G(IS_10G)
)m_pcs_rx(
.nreset          (nreset),
.clk             (rx_par_clk),
.serdes_lock_v_i (rx_locked_i),
.serdes_data_i   (rx_par_data_i),
.signal_v_o      (rx_signal_ok), 
.valid_o         (rx_valid),
.ctrl_v_o        (rx_ctrl),
.idle_v_o        (rx_idle),
.start_v_o       (rx_start),
.term_v_o        (rx_term),
.err_v_o         (rx_err),
/* verilator lint_off PINCONNECTEMPTY*/
.ord_v_o         (),
/* verilator lint_on PINCONNECTEMPTY*/
.data_o          (rx_data), 
.keep_o          (rx_keep)
);

/* RCS TX */
reg                   tx_nreset;
reg                   tx_ctrl;
reg                   tx_idle;
reg                   tx_term;
reg                   tx_err;
reg [LANE0_CNT_N-1:0] tx_start;
reg [DATA_W-1:0]      tx_data;
reg [KEEP_W-1:0]      tx_keep;

/* verilator lint_off UNUSEDSIGNAL */
logic                 tx_ready;
/* verilator lint_on UNUSEDSIGNAL */

pcs_tx#(
.IS_10G(IS_10G),
.DATA_W(DATA_W)
)m_pcs_tx(
.clk        (tx_par_clk),
.nreset     (tx_nreset),

.ctrl_v_i   (tx_ctrl),
.idle_v_i   (tx_idle),
.start_v_i  (tx_start),
.err_v_i    (tx_err),
.term_v_i   (tx_term),
.keep_i     (tx_keep),
.data_i     (tx_data),

/* verilator lint_off PINCONNECTEMPTY*/
.marker_v_o (),
/* verilator lint_on PINCONNECTEMPTY*/
.ready_o    (tx_ready),

.serdes_data_o(tx_par_data_o)
);

/* RX -> TX loopback 
 * flop nreset */
reg   tx_nreset_next;

always @(posedge tx_par_clk) begin
	if (~nreset) begin
		tx_nreset_next <= 1'b0;
		tx_nreset      <= 1'b0;
	end else begin
		tx_nreset_next <= nreset;
		tx_nreset      <= tx_nreset_next; 
	end
end 
 
/* Flop rx data before sending to tx */
always @(posedge tx_par_clk) begin
	tx_ctrl  <= rx_ctrl;
	tx_idle  <= rx_idle;
	tx_term  <= rx_term;
	tx_err   <= rx_err;	
	tx_start <= rx_start;
	tx_data  <= rx_data;
	tx_keep  <= rx_keep;
end

 
endmodule	
