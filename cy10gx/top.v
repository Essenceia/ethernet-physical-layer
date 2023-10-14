module top #(
	localparam IS_10G = 1,
	localparam HEAD_W = 2,
	localparam DATA_W = 64,
	localparam BLOCK_W = HEAD_W+DATA_W
)
(

	/* transivers quad 1D 
 	* ch4 : SFP1
 	* ch5 : SFP2 */
    output wire [5:0]  GXB1D_TXD,
    input  wire [5:0]  GXB1D_RXD,
    input  wire        GXB1D_644M,
    input  wire        GXB1D_125M,
);
localparam LANE0_CNT_N = !IS_10G ? 1 : 2;
localparam KEEP_W = DATA_W/8;
/* Number of channels in GX transiver */
localparam GX_W = 6;

/* nreset
 * derrived from rx lock */
logic nlock;
reg   nlock_q;
logic nreset;

assign nlock = ~serdes_rx_lock_i;

/* clk network */
/* generate master clock at 161.MHz */
logic clk;

/* GX transiver */
localparam SFP1_CH = 4;
localparam SFP2_CH = 5;
/* RX */
logic [5:4] gx_rx_serial_data;
logic       gx_rx_cdr_refclk0;
logic       gx_rx_clkout;// parallel clk
logic [5:4] gx_rx_is_lockedtodata;
logic [5:4] gx_rx_is_lockedtoref;
logic [5:4] gx_rx_set_locktodata;   
logic [5:4] gx_rx_set_locktoref;      
logic [DATA_W-1:0] gx_rx_parallel_data[5:4];
   
logic gx_rx_analogreset;       
logic gx_rx_digitalreset;        
logic gx_tx_cal_busy;       

/* TX */
logic [5:4] gx_tx_serial_data;
logic       gx_tx_serial_clk0;// from core -> transiver fPLL
logic [DATA_W-1:0] gx_tx_parallel_data[5:4];

logic      gx_tx_analogreset;  
logic      gx_tx_digitalreset;     
logic      gx_rx_cal_busy;
          
/* binding input signals to gx */
assign gx_rx_cdr_refclk0 = 1'bx; /* TODO : output of GXBID644 -> IOPLL ration 1/4 -> 166.13MHz */
assign gx_rx_serial_data = GXB1D_RXD[5:4];
assign GXB1D_TXD[5:4] = gx_tx_serial_data;
/* SFP1 */
trans m_sfp1 (
        .tx_analogreset          (gx_tx_analogreset),          //   input,   width = 1,          tx_analogreset.tx_analogreset
        .tx_digitalreset         (gx_tx_digitalreset),         //   input,   width = 1,         tx_digitalreset.tx_digitalreset
        .rx_analogreset          (gx_rx_analogreset),          //   input,   width = 1,          rx_analogreset.rx_analogreset
        .rx_digitalreset         (gx_rx_digitalreset),         //   input,   width = 1,         rx_digitalreset.rx_digitalreset
        .tx_cal_busy             (gx_tx_cal_busy),             //  output,   width = 1,             tx_cal_busy.tx_cal_busy
        .rx_cal_busy             (gx_rx_cal_busy),             //  output,   width = 1,             rx_cal_busy.rx_cal_busy
        .tx_serial_clk0          (gx_tx_serial_clk0),          //   input,   width = 1,          tx_serial_clk0.clk
        .rx_cdr_refclk0          (gx_rx_cdr_refclk0),          //   input,   width = 1,          rx_cdr_refclk0.clk
        .tx_serial_data          (gx_tx_serial_data),          //  output,   width = 1,          tx_serial_data.tx_serial_data
        .rx_serial_data          (data_),          //   input,   width = 1,          rx_serial_data.rx_serial_data
        .rx_set_locktodata       (ktodata_),       //   input,   width = 1,       rx_set_locktodata.rx_set_locktodata
        .rx_set_locktoref        (ktoref_),        //   input,   width = 1,        rx_set_locktoref.rx_set_locktoref
        .rx_is_lockedtoref       (edtoref_),       //  output,   width = 1,       rx_is_lockedtoref.rx_is_lockedtoref
        .rx_is_lockedtodata      (edtodata_),      //  output,   width = 1,      rx_is_lockedtodata.rx_is_lockedtodata
        .tx_clkout               (),               //  output,   width = 1,               tx_clkout.clk
        .rx_clkout               (),               //  output,   width = 1,               rx_clkout.clk
        .tx_parallel_data        (l_data_),        //   input,  width = 64,        tx_parallel_data.tx_parallel_data
        .unused_tx_parallel_data (parallel_data_), //   input,  width = 64, unused_tx_parallel_data.unused_tx_parallel_data
        .rx_parallel_data        (l_data_),        //  output,  width = 64,        rx_parallel_data.rx_parallel_data
        .unused_rx_parallel_data (parallel_data_)  //  output,  width = 64, unused_rx_parallel_data.unused_rx_parallel_data
);

/* GX reset controller */
phy_rst u0 (
        .clock               (_connected_to_clock_),               //   input,  width = 1,               clock.clk
        .reset               (_connected_to_reset_),               //   input,  width = 1,               reset.reset
        .pll_powerdown0      (_connected_to_pll_powerdown0_),      //  output,  width = 1,      pll_powerdown0.pll_powerdown
        .tx_analogreset0     (_connected_to_tx_analogreset0_),     //  output,  width = 1,     tx_analogreset0.tx_analogreset
        .tx_digitalreset0    (_connected_to_tx_digitalreset0_),    //  output,  width = 1,    tx_digitalreset0.tx_digitalreset
        .tx_ready0           (_connected_to_tx_ready0_),           //  output,  width = 1,           tx_ready0.tx_ready
        .pll_locked0         (_connected_to_pll_locked0_),         //   input,  width = 1,         pll_locked0.pll_locked
        .pll_select          (_connected_to_pll_select_),          //   input,  width = 1,          pll_select.pll_select
        .tx_cal_busy0        (_connected_to_tx_cal_busy0_),        //   input,  width = 1,        tx_cal_busy0.tx_cal_busy
        .rx_analogreset0     (_connected_to_rx_analogreset0_),     //  output,  width = 1,     rx_analogreset0.rx_analogreset
        .rx_digitalreset0    (_connected_to_rx_digitalreset0_),    //  output,  width = 1,    rx_digitalreset0.rx_digitalreset
        .rx_ready0           (_connected_to_rx_ready0_),           //  output,  width = 1,           rx_ready0.rx_ready
        .rx_is_lockedtodata0 (_connected_to_rx_is_lockedtodata0_), //   input,  width = 1, rx_is_lockedtodata0.rx_is_lockedtodata
        .rx_cal_busy0        (_connected_to_rx_cal_busy0_)         //   input,  width = 1,        rx_cal_busy0.rx_cal_busy
);

/* PCS RX */
logic rx_signal_ok;
logic rx_valid;
logic rx_ctrl;
logic rx_idle;
logic rx_term;
logic rx_err;
logic [LANE0_CNT_N-1:0] rx_start;
logic [DATA_W-1:0] rx_data;
logic [KEEP_W-1:0] rx_keep;

 pcs_rx #(
	.IS_10G(IS_10G)
)m_pcs_rx(
.nreset(nreset),
.clk(serdes_rx_clk),
.serdes_lock_v_i(serdes_rx_lock_i),
.serdes_data_i(serdes_rx_data_i),
.signal_v_o(rx_signal_ok), 
.valid_o(rx_valid),
.ctrl_v_o(rx_ctrl),
.idle_v_o(rx_idle),
.start_v_o(rx_start),
.term_v_o(rx_term),
.err_v_o(rx_err),
.ord_v_o(),
.data_o(rx_data), 
.keep_o(rx_keep)
);

/* RCS TX */
logic tx_clk;

reg tx_ctrl;
reg tx_idle;
reg tx_term;
reg tx_err;
reg [LANE0_CNT_N-1:0] tx_start;
reg [DATA_W-1:0]      tx_data;
reg [KEEP_W-1:0]      tx_keep;

logic tx_ready;

pcs_tx#(
.IS_10G(IS_10G)
)m_pcs_tx(
.clk(tx_clk),
.nreset(nreset),

.ctrl_v_i(tx_ctrl),
.idle_v_i(tx_idle),
.start_v_i(tx_start),
.err_v_i(tx_err),
.term_v_i(tx_term),
.keep_i(tx_keep),
.data_i(tx_data),

.marker_v_o(),
.ready_o(tx_ready),

.serdes_data_o(serdes_tx_data_o)
);

/* RX -> TX loopback 
 *
 * Flop rx data before sending to tx */
always @(posedge clk) begin
	if ( rx_valid) begin
		tx_ctrl <= rx_ctrl;
		tx_idle <= rx_idle;
		tx_term <= rx_term;
		tx_err  <= rx_err;	
		tx_start <= rx_start;
		tx_data  <= rx_data;
		tx_keep  <= rx_keep;
	end
end

 
endmodule
