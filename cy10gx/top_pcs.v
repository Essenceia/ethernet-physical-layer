/* Cyclone 10 GX PCS wrapper */
module top_pcs #(
	parameter IS_10G = 1,
	localparam LANE_N = IS_10G ? 1 : 4,
	localparam DATA_W = 64
)(
	input  clk_50m,
	input  clk_644m, 
	input  [LANE_N-1:0] gx_rx_par_clk,
	input  [LANE_N-1:0] gx_tx_par_clk,
	output [LANE_N-1:0] gx_tx_ser_clk,

	input io_nreset_i,

	/* GX transiver
 	 * reset signals */
	output [LANE_N-1:0] gx_tx_analogreset_o,
	output [LANE_N-1:0] gx_tx_digitalreset_o,
	input  [LANE_N-1:0] gx_tx_cal_busy_i,

 	output [LANE_N-1:0] gx_rx_analogreset_o,
	output [LANE_N-1:0] gx_rx_digitalreset_o,
	input  [LANE_N-1:0] gx_rx_cal_busy_i,
	input  [LANE_N-1:0] gx_rx_is_lockedtodata_i,

	/* GX traniver : parallel data to/from SerDes */
	input  [LANE_N*DATA_W-1:0] gx_rx_par_data_i,
	output [LANE_N*DATA_W-1:0] gx_tx_par_data_o
);
localparam LANE0_CNT_N = !IS_10G ? 1 : 2;
localparam KEEP_W = DATA_W/8;

logic pcs_clk;
logic tx_ser_clk;

/* atxpll for tx transiver serial clk : per pcs to help reduce jitter */
logic rst_pll_powerdown;
logic rst_tx_cal_busy;
logic pll_locked;

logic trans_pll_locked;
logic trans_pll_cal_busy;

// TODO : fix clk
generate
if (IS_10G) begin: gen_is_10g

assign pcs_clk = gx_rx_par_clk[0];

assign rst_tx_cal_busy = trans_pll_cal_busy | gx_tx_cal_busy_i; 
assign pll_locked = trans_pll_locked;
end else begin: gen_not_10g

logic core_rst_pll_powerdown;
logic core_pll_locked;
logic core_pll_cal_busy;

pcs_core_fpll m_pcs_clk_fpll(
		.pll_powerdown (rst_pll_powerdown), // pll_powerdown.pll_powerdown
		.pll_refclk0   (clk_644m),               //   pll_refclk0.clk
		.outclk0       (pcs_clk),       // tx_serial_clk.clk
		.pll_locked    (core_pll_locked),       //    pll_locked.pll_locked
		.pll_cal_busy  (core_pll_cal_busy)    //  pll_cal_busy.pll_cal_busy
);
/* hijake cal busy : add requirement to wait for common pcs core clk */
assign rst_tx_cal_busy = trans_pll_cal_busy | |gx_tx_cal_busy_i | core_pll_cal_busy; 
assign pll_locked = core_pll_locked & trans_pll_locked;

end
endgenerate

atxpll m_trans_tx_atxpll(
		.pll_powerdown(rst_pll_powerdown), // pll_powerdown.pll_powerdown
		.pll_refclk0  (clk_644m),               //   pll_refclk0.clk
		.tx_serial_clk(tx_ser_clk),       // tx_serial_clk.clk
		.pll_locked   (trans_pll_locked),       //    pll_locked.pll_locked
		.pll_cal_busy (trans_pll_cal_busy)    //  pll_cal_busy.pll_cal_busy
);
assign gx_tx_ser_clk = {LANE_N{tx_ser_clk}};

/* GX reset controller */
logic gx_rx_ready;
logic gx_tx_ready;
logic rst_tx_analogreset;
logic rst_tx_digitalreset;
logic rst_rx_analogreset;
logic rst_rx_digitalreset;
logic rst_rx_cal_busy;
logic rst_rx_is_lockedtodata;

assign rst_rx_is_lockedtodata = &gx_rx_is_lockedtodata_i;
assign rst_rx_cal_busy = |gx_rx_cal_busy_i;

phy_rst m_phy_rst (
        .clock               (clk_50m),              //   input,  width = 1,               clock.clk
        .reset               (~io_nreset_i),            //   input,  width = 1,               reset.reset
        .pll_powerdown0      (rst_pll_powerdown),     //  output,  width = 1,      pll_powerdown0.pll_powerdown
        .tx_analogreset0     (rst_tx_analogreset),     //  output,  width = 1,     tx_analogreset0.tx_analogreset
        .tx_digitalreset0    (rst_tx_digitalreset),    //  output,  width = 1,    tx_digitalreset0.tx_digitalreset
        .tx_ready0           (gx_tx_ready),           //  output,  width = 1,           tx_ready0.tx_ready
        .pll_locked0         (pll_locked),        //   input,  width = 1,         pll_locked0.pll_locked
        .pll_select          (1'b0),          //   input,  width = 1,          pll_select.pll_select
        .tx_cal_busy0        (rst_tx_cal_busy),        //   input,  width = 1,        tx_cal_busy0.tx_cal_busy

        .rx_analogreset0     (rst_rx_analogreset),     //  output,  width = 1,     rx_analogreset0.rx_analogreset
        .rx_digitalreset0    (rst_rx_digitalreset),    //  output,  width = 1,    rx_digitalreset0.rx_digitalreset
        .rx_ready0           (gx_rx_ready),           //  output,  width = 1,           rx_ready0.rx_ready
        .rx_is_lockedtodata0 (rst_rx_is_lockedtodata), //   input,  width = 1, rx_is_lockedtodata0.rx_is_lockedtodata
        .rx_cal_busy0        (rst_rx_cal_busy)         //   input,  width = 1,        rx_cal_busy0.rx_cal_busy
);
assign gx_tx_analogreset_o = {LANE_N{rst_tx_analogreset}};
assign gx_tx_digitalreset_o = {LANE_N{rst_tx_digitalreset}};
assign gx_rx_analogreset_o = {LANE_N{rst_rx_analogreset}};
assign gx_rx_digitalreset_o = {LANE_N{rst_rx_digitalreset}};

/* PCS logic nreset, set to reset(high) while both
 * rx and tx are not ready */
logic  gx_nreset;
assign gx_nreset = gx_rx_ready & gx_tx_ready;

/* 2ff cdc for reset */
reg   gx_nreset_q;
reg   nreset_next;
reg   nreset;

always @(posedge clk_50m) begin
	gx_nreset_q <= gx_nreset;
end

always @(posedge pcs_clk) begin
	nreset_next <= gx_nreset_q;
	nreset      <= nreset_next;
end

/* reset controller */

/* PCS RX */
logic                          pcs_rx_signal_ok;
logic [LANE_N-1:0]             pcs_rx_valid;
logic [LANE_N-1:0]             pcs_rx_ctrl;
logic [LANE_N-1:0]             pcs_rx_idle;
logic [LANE_N-1:0]             pcs_rx_term;
logic [LANE_N-1:0]             pcs_rx_err;
logic [LANE_N*LANE0_CNT_N-1:0] pcs_rx_start;
logic [LANE_N*DATA_W-1:0]      pcs_rx_data;
logic [LANE_N*KEEP_W-1:0]      pcs_rx_keep;

pcs_rx #(
	.IS_10G(IS_10G),
	.IS_TB(0),
	.DATA_W(DATA_W))
m_pcs_rx(
.pcs_clk         (pcs_clk),
.rx_par_clk      (gx_rx_par_clk),
.nreset          (nreset),
.serdes_lock_v_i ({LANE_N{1'b1}}),// always ready otherwise reset
.serdes_data_i   (gx_rx_par_data_i),
.signal_v_o      (pcs_rx_signal_ok), 
.valid_o         (pcs_rx_valid),
.ctrl_v_o        (pcs_rx_ctrl),
.idle_v_o        (pcs_rx_idle),
.start_v_o       (pcs_rx_start),
.term_v_o        (pcs_rx_term),
.err_v_o         (pcs_rx_err),
.ord_v_o         (),
.data_o          (pcs_rx_data), 
.keep_o          (pcs_rx_keep)
);

/* RCS TX */

// tx input
logic                          pcs_tx_nreset;
logic [LANE_N-1:0]             pcs_tx_ctrl;
logic [LANE_N-1:0]             pcs_tx_idle;
logic [LANE_N-1:0]             pcs_tx_term;
logic [LANE_N-1:0]             pcs_tx_err;
logic [LANE_N*LANE0_CNT_N-1:0] pcs_tx_start;
logic [LANE_N*DATA_W-1:0]      pcs_tx_data;
logic [LANE_N*KEEP_W-1:0]      pcs_tx_keep;

/* keep unusued signal for debug */
logic debug_pcs_tx_ready;

pcs_tx#(
	.IS_10G(IS_10G),
	.DATA_W(DATA_W),
	.IS_TB(0)
)m_pcs_tx(
.pcs_clk    (pcs_clk),
.tx_par_clk (gx_tx_par_clk),
.nreset     (pcs_tx_nreset),

.ctrl_v_i   (pcs_tx_ctrl),
.idle_v_i   (pcs_tx_idle),
.start_v_i  (pcs_tx_start),
.err_v_i    (pcs_tx_err),
.term_v_i   (pcs_tx_term),
.keep_i     (pcs_tx_keep),
.data_i     (pcs_tx_data),

.marker_v_o (),
.ready_o    (debug_pcs_tx_ready),

.serdes_data_o(gx_tx_par_data_o)
);

/* data loopback */
pcs_loopback #(
	.IS_10G(IS_10G),
	.LANE_N(LANE_N), 
	.LANE0_CNT_N(LANE0_CNT_N), 
	.DATA_W(DATA_W))
m_pcs_loopback(
.clk(pcs_clk),
.rx_clk(gx_rx_par_clk),
.tx_clk(gx_tx_par_clk),
.rx_nreset(nreset),
.tx_nreset(pcs_tx_nreset),

.pcs_rx_ctrl_i(pcs_rx_ctrl),
.pcs_rx_idle_i(pcs_rx_idle),
.pcs_rx_term_i(pcs_rx_term),
.pcs_rx_err_i(pcs_rx_err),
.pcs_rx_start_i(pcs_rx_start),
.pcs_rx_data_i(pcs_rx_data),
.pcs_rx_keep_i(pcs_rx_keep),

.pcs_tx_ctrl_o(pcs_tx_ctrl),
.pcs_tx_idle_o(pcs_tx_idle),
.pcs_tx_term_o(pcs_tx_term),
.pcs_tx_err_o(pcs_tx_err),
.pcs_tx_start_o(pcs_tx_start),
.pcs_tx_data_o(pcs_tx_data),
.pcs_tx_keep_o(pcs_tx_keep)
);

endmodule
