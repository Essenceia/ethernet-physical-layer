module top #(
	localparam IS_10G = 1,
	localparam HEAD_W = 2,
	localparam DATA_W = 64,
	localparam BLOCK_W = HEAD_W+DATA_W
)
(
    input  wire        OSC_50m,     // 50MHz
    input  wire        FPGA_RSTn,   //3.0V async reset in from BMC/RESET button
 
	/* transivers quad 1D 
 	* ch4 : SFP1
 	* ch5 : SFP2 */
    output wire SFP1_TXD,
    output wire SFP1_TXD_N,
    input  wire SFP1_RXD,
    input  wire SFP1_RXD_N,
 	/* 644,5312 MHz */
    input  wire GXB1D_644M,
    input  wire GXB1D_644M_N,
	/* 125 MHz */
    input  wire GXB1D_125M,
    input  wire GXB1D_125M_N
);
localparam LANE0_CNT_N = !IS_10G ? 1 : 2;
localparam KEEP_W = DATA_W/8;

/* differential input buffers */
logic gx_644M_clk;
ALT_INBUF_DIFF m_inbuf_644M_clk (
    .i (GXB1D_644M),
    .ibar (GXB1D_644M_N),
    .o(gx_644M_clk)
); 

logic gx_125M_clk;
ALT_INBUF_DIFF m_inbuf_125M_clk (
    .i (GXB1D_125M),
    .ibar (GXB1D_125M_N),
    .o(gx_125M_clk)
); 

logic sfp1_rxd;
ALT_INBUF_DIFF m_inbuf_sfp1_rx (
    .i (SFP1_RXD),
    .ibar (SFP1_RXD_N),
    .o(sfp1_rxd)
); 

logic spf1_txd;
ALT_OUTBUF_DIFF m_outbuf_sfp1_txd(
	.i(sfp1_txd),
	.o(SFP1_TXD),
	.obar(SFP1_TXD_N)
);

/* clk network
 * generate master clock at 161.MHz */
logic slow_clk;     // 50Mhz integer clock
logic gx_rx_par_clk;// parallel clk
logic gx_tx_ser_clk;// from core -> transiver fPLL

assign slow_clk = OSC_50m;

reg   io_nreset;
/*
// iopll
logic ref_clk;      // ioPLL 644.5312 -> 161,13 MHz 
logic iopll_locked;

iopll m_iopll_refclk (
  .refclk   (gx_644M_clk),   //   input,  width = 1,  refclk.clk
  .locked   (iopll_locked),   //  output,  width = 1,  locked.export
  .rst      (io_nreset),      //   input,  width = 1,   reset.reset
  .outclk_0 (ref_clk)  //  output,  width = 1, outclk0.clk
);

// phase aligner
logic pa_fpll_locked;
logic pa_fpll_cal_busy;
logic rst_pll_powerdown;
logic logic_clk;    // fPLL phase aligned -> 161.13 

phase_align_fpll m_phase_align(
	.pll_cal_busy  (pa_fpll_cal_busy),
	.pll_locked    (pa_fpll_locked),
	.pll_powerdown (rst_pll_powerdown),
	.pll_refclk0   (gx_644M_clk),
	.pll_refclk1   (gx_rx_par_clk),
	.outclk0       (logic_clk),
	.outclk1       ()
);
*/
/* tx gx fpll */
logic gx_tx_fpll_reset;
logic gx_tx_fpll_locked;
logic gx_tx_fpll_powerdown;
logic gx_tx_fpll_cal_busy;



phyfpll m_sfp1_tx_fpll (
	//.pll_refclk0   (logic_clk),   
	.pll_refclk0   (gx_644M_clk),   
	.pll_powerdown (rst_pll_powerdown),
	.pll_locked    (gx_tx_fpll_locked),
	.tx_serial_clk (gx_tx_ser_clk),
	.pll_cal_busy  (gx_tx_fpll_cal_busy)
);


/* reset from IO, go through 2ff sync before use */
logic io_nreset_raw;
reg   io_nreset_meta_q;

assign io_nreset_raw = FPGA_RSTn;
always @(posedge slow_clk) begin
	io_nreset_meta_q <= io_nreset_raw;
	io_nreset <= io_nreset_meta_q;
end

/* GX reset controller */
logic gx_rx_ready;
logic gx_tx_ready;
logic gx_nreset;
reg   nreset_next;
reg   nreset;

logic gx_rx_is_lockedtodata;

logic gx_tx_analogreset;  
logic gx_tx_digitalreset;   
logic gx_rx_analogreset;       
logic gx_rx_digitalreset;        
logic gx_rx_cal_busy;

 

phy_rst m_phy_rst (
        .clock               (slow_clk),              //   input,  width = 1,               clock.clk
        .reset               (~io_nreset),            //   input,  width = 1,               reset.reset
        .pll_powerdown0      (rst_pll_powerdown),     //  output,  width = 1,      pll_powerdown0.pll_powerdown
        .tx_analogreset0     (gx_tx_analogreset),     //  output,  width = 1,     tx_analogreset0.tx_analogreset
        .tx_digitalreset0    (gx_tx_digitalreset),    //  output,  width = 1,    tx_digitalreset0.tx_digitalreset
        .tx_ready0           (gx_tx_ready),           //  output,  width = 1,           tx_ready0.tx_ready
        .pll_locked0         (gx_tx_fpll_locked),        //   input,  width = 1,         pll_locked0.pll_locked
        .pll_select          (1'b0),          //   input,  width = 1,          pll_select.pll_select
        .tx_cal_busy0        (gx_tx_fpll_cal_busy),        //   input,  width = 1,        tx_cal_busy0.tx_cal_busy

        .rx_analogreset0     (gx_rx_analogreset),     //  output,  width = 1,     rx_analogreset0.rx_analogreset
        .rx_digitalreset0    (gx_rx_digitalreset),    //  output,  width = 1,    rx_digitalreset0.rx_digitalreset
        .rx_ready0           (gx_rx_ready),           //  output,  width = 1,           rx_ready0.rx_ready
        .rx_is_lockedtodata0 (gx_rx_is_lockedtodata), //   input,  width = 1, rx_is_lockedtodata0.rx_is_lockedtodata
        .rx_cal_busy0        (gx_rx_cal_busy)         //   input,  width = 1,        rx_cal_busy0.rx_cal_busy
);
/* 2ff cdc for reset */
assign gx_nreset = ~( gx_rx_ready & gx_tx_ready );

always @(posedge gx_rx_par_clk) begin
	nreset_next <= gx_nreset;
	nreset      <= nreset_next;
end


/* GX transiver */
/* SFP1 channel 4 */
/* RX */
logic gx_rx_is_lockedtoref;
logic gx_rx_set_locktodata;   
logic gx_rx_set_locktoref;      
logic [DATA_W-1:0] gx_rx_parallel_data;
   
/* TX */
logic [DATA_W-1:0] gx_tx_parallel_data;
 
logic gx_tx_cal_busy;       

trans m_sfp1 (
        .tx_analogreset          (gx_tx_analogreset),          //   input,   width = 1,          tx_analogreset.tx_analogreset
        .tx_digitalreset         (gx_tx_digitalreset),         //   input,   width = 1,         tx_digitalreset.tx_digitalreset
        .rx_analogreset          (gx_rx_analogreset),          //   input,   width = 1,          rx_analogreset.rx_analogreset
        .rx_digitalreset         (gx_rx_digitalreset),         //   input,   width = 1,         rx_digitalreset.rx_digitalreset
        .tx_cal_busy             (gx_tx_cal_busy),             //  output,   width = 1,             tx_cal_busy.tx_cal_busy
        .rx_cal_busy             (gx_rx_cal_busy),             //  output,   width = 1,             rx_cal_busy.rx_cal_busy
        .tx_serial_clk0          (gx_tx_ser_clk),          //   input,   width = 1,          tx_serial_clk0.clk
        .rx_cdr_refclk0          (gx_644M_clk), // not using cdc fifo TODO : remove
        .tx_serial_data          (sfp1_rxd),          //  output,   width = 1,          tx_serial_data.tx_serial_data
        .rx_serial_data          (sfp1_txd),          //   input,   width = 1,          rx_serial_data.rx_serial_data
        .rx_set_locktodata       (),       //   input,   width = 1,       rx_set_locktodata.rx_set_locktodata
        .rx_set_locktoref        (),        //   input,   width = 1,        rx_set_locktoref.rx_set_locktoref
        .rx_is_lockedtoref       (gx_rx_is_lockedtoref),       //  output,   width = 1,       rx_is_lockedtoref.rx_is_lockedtoref
        .rx_is_lockedtodata      (gx_rx_is_lockedtodata),      //  output,   width = 1,      rx_is_lockedtodata.rx_is_lockedtodata
        .tx_clkout               (),               //  output,   width = 1,               tx_clkout.clk
        .rx_clkout               (gx_rx_par_clk),               //  output,   width = 1,               rx_clkout.clk
        .tx_parallel_data        (gx_tx_parallel_data),        //   input,  width = 64,        tx_parallel_data.tx_parallel_data
        .unused_tx_parallel_data (), //   input,  width = 64, unused_tx_parallel_data.unused_tx_parallel_data
        .rx_parallel_data        (gx_rx_parallel_data),      //  output,  width = 64,        rx_parallel_data.rx_parallel_data
        .unused_rx_parallel_data ()  //  output,  width = 64, unused_rx_parallel_data.unused_rx_parallel_data
);

/* PCS RX */
logic pcs_rx_nreset;
logic pcs_rx_signal_ok;
logic pcs_rx_valid;
logic pcs_rx_ctrl;
logic pcs_rx_idle;
logic pcs_rx_term;
logic pcs_rx_err;
logic [LANE0_CNT_N-1:0] pcs_rx_start;
logic [DATA_W-1:0] pcs_rx_data;
logic [KEEP_W-1:0] pcs_rx_keep;

 pcs_rx #(
	.IS_10G(IS_10G)
)m_pcs_rx(
.nreset          (nreset),
.clk             (gx_rx_par_clk),
.serdes_lock_v_i (gx_rx_ready),
.serdes_data_i   (gx_rx_parallel_data),
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
reg pcs_tx_nreset;

reg pcs_tx_ctrl;
reg pcs_tx_idle;
reg pcs_tx_term;
reg pcs_tx_err;
reg [LANE0_CNT_N-1:0] pcs_tx_start;
reg [DATA_W-1:0]      pcs_tx_data;
reg [KEEP_W-1:0]      pcs_tx_keep;

logic pcs_tx_ready;

pcs_tx#(
.IS_10G(IS_10G)
)m_pcs_tx(
.clk        (gx_rx_par_clk),
.nreset     (pcs_tx_nreset),

.ctrl_v_i   (pcs_tx_ctrl),
.idle_v_i   (pcs_tx_idle),
.start_v_i  (pcs_tx_start),
.err_v_i    (pcs_tx_err),
.term_v_i   (pcs_tx_term),
.keep_i     (pcs_tx_keep),
.data_i     (pcs_tx_data),

.marker_v_o (),
.ready_o    (pcs_tx_ready),

.serdes_data_o(gx_tx_parallel_data)
);

/* RX -> TX loopback 
 * flop nreset */
reg   pcs_tx_nreset_next;

always @(posedge gx_rx_par_clk) begin
	pcs_tx_nreset_next <= nreset;
	pcs_tx_nreset      <= pcs_tx_nreset_next; 
end 
 
/* Flop rx data before sending to tx */
always @(posedge gx_rx_par_clk) begin
	pcs_tx_ctrl  <= pcs_rx_ctrl;
	pcs_tx_idle  <= pcs_rx_idle;
	pcs_tx_term  <= pcs_rx_term;
	pcs_tx_err   <= pcs_rx_err;	
	pcs_tx_start <= pcs_rx_start;
	pcs_tx_data  <= pcs_rx_data;
	pcs_tx_keep  <= pcs_rx_keep;
end

 
endmodule
