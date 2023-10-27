
module top #(
	localparam CH_N = 5,
	localparam HEAD_W = 2,
	localparam DATA_W = 64,
	localparam BLOCK_W = HEAD_W+DATA_W
)
(
    input  wire        OSC_50m,     // 50MHz
    input  wire        FPGA_RSTn,   //3.0V async reset in from BMC/RESET button
 
	/* transivers quad 1D 
 	* ch[3:0] : QSFP1 
 	* ch4 : SFP1 */ 
	input wire  [CH_N-1:0] GXB1D_RXD,
	input wire  [CH_N-1:0] GXB1D_RXD_N,
	output wire [CH_N-1:0] GXB1D_TXD,
	output wire [CH_N-1:0] GXB1D_TXD_N,

 	/* 644,5312 MHz */
    input  wire GXB1D_644M,
    input  wire GXB1D_644M_N,
	/* 125 MHz */
    input  wire GXB1D_125M,
    input  wire GXB1D_125M_N
);

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

logic [CH_N-1:0] gx_rx_ser_data;
logic [CH_N-1:0] gx_tx_ser_data;

genvar l;
generate
for(l=0; l<CH_N; l++) begin: gen_buf_diff_ch
ALT_INBUF_DIFF m_inbuf_diff_rx (
    .i    (GXB1D_RXD[l]),
    .ibar (GXB1D_RXD_N[l]),
    .o    (gx_rx_ser_data[l])
); 

ALT_OUTBUF_DIFF m_outbuf_diff_txd(
	.i   (gx_tx_ser_data[l]),
	.o   (GXB1D_TXD)[l],
	.obar(GXB1D_TXD_N[l])
);
end
endgenerate

/* clk network
 * generate master clock at 161.MHz */
logic slow_clk;     // 50Mhz integer clock
logic gx_rx_par_clk;// parallel clk
logic gx_tx_par_clk;// parallel clk
logic gx_tx_ser_clk;// from core -> transiver fPLL

assign slow_clk = OSC_50m;

reg   io_nreset;
//logic gx_tx_pll_reset;
//logic gx_tx_pll_locked;
//logic gx_tx_pll_powerdown;
//logic gx_tx_pll_cal_busy;
//
//atxpll m_sfp1_tx_atxpll(
//		.pll_powerdown(rst_pll_powerdown), // pll_powerdown.pll_powerdown
//		.pll_refclk0(gx_644M_clk),               //   pll_refclk0.clk
//		.tx_serial_clk(gx_tx_ser_clk),       // tx_serial_clk.clk
//		.pll_locked(pll_locked),       //    pll_locked.pll_locked
//		.pll_cal_busy(gx_tx_pll_cal_busy)    //  pll_cal_busy.pll_cal_busy
//);
	
/* reset from IO, go through 2ff sync before use */
logic io_nreset_raw;
reg   io_nreset_meta_q;

assign io_nreset_raw = FPGA_RSTn;
always @(posedge slow_clk) begin
	io_nreset_meta_q <= io_nreset_raw;
	io_nreset <= io_nreset_meta_q;
end

/* GX reset controller */
//logic gx_rx_is_lockedtodata;
//
//logic gx_tx_analogreset;  
//logic gx_tx_digitalreset;   
//logic gx_rx_analogreset;       
//logic gx_rx_digitalreset;        
//logic gx_rx_cal_busy;
//
//logic rst_tx_cal_busy;
//logic gx_tx_cal_busy;       
//assign rst_tx_cal_busy = gx_tx_pll_cal_busy | gx_tx_cal_busy; 
//
//logic gx_rx_ready;
//logic gx_tx_ready;
//
//phy_rst m_phy_rst (
//        .clock               (slow_clk),              //   input,  width = 1,               clock.clk
//        .reset               (~io_nreset),            //   input,  width = 1,               reset.reset
//        .pll_powerdown0      (rst_pll_powerdown),     //  output,  width = 1,      pll_powerdown0.pll_powerdown
//        .tx_analogreset0     (gx_tx_analogreset),     //  output,  width = 1,     tx_analogreset0.tx_analogreset
//        .tx_digitalreset0    (gx_tx_digitalreset),    //  output,  width = 1,    tx_digitalreset0.tx_digitalreset
//        .tx_ready0           (gx_tx_ready),           //  output,  width = 1,           tx_ready0.tx_ready
//        .pll_locked0         (pll_locked),        //   input,  width = 1,         pll_locked0.pll_locked
//        .pll_select          (1'b0),          //   input,  width = 1,          pll_select.pll_select
//        .tx_cal_busy0        (rst_tx_cal_busy),        //   input,  width = 1,        tx_cal_busy0.tx_cal_busy
//
//        .rx_analogreset0     (gx_rx_analogreset),     //  output,  width = 1,     rx_analogreset0.rx_analogreset
//        .rx_digitalreset0    (gx_rx_digitalreset),    //  output,  width = 1,    rx_digitalreset0.rx_digitalreset
//        .rx_ready0           (gx_rx_ready),           //  output,  width = 1,           rx_ready0.rx_ready
//        .rx_is_lockedtodata0 (gx_rx_is_lockedtodata), //   input,  width = 1, rx_is_lockedtodata0.rx_is_lockedtodata
//        .rx_cal_busy0        (gx_rx_cal_busy)         //   input,  width = 1,        rx_cal_busy0.rx_cal_busy
//);
///* 2ff cdc for reset */
//logic  gx_sfp1_nreset;
//assign gx_sfp1_nreset = ~( gx_rx_ready[SFP1_CH] & gx_tx_ready[SFP1_CH] );

/* SFP1 PCS */
logic              gx_rx_sfp1_is_lockedtoref;
logic              gx_rx_sfp1_set_locktodata;   
logic              gx_rx_sfp1_set_locktoref;      
logic [DATA_W-1:0] gx_rx_sfp1_par_data;
logic [DATA_W-1:0] gx_tx_sfp1_par_data;

logic gx_tx_sfp1_analogreset;
logic gx_tx_sfp1_digitalreset;
logic gx_tx_sfp1_cal_busy;
logic gx_rx_sfp1_analogreset;
logic gx_rx_sfp1_digitalreset;
logic gx_rx_sfp1_cal_busy;
logic gx_rx_sfp1_is_lockedtodata;

 
trans m_sfp1_trans (
	.tx_analogreset          (gx_tx_sfp1_analogreset),          //   input,   width = 1,          tx_analogreset.tx_analogreset
	.tx_digitalreset         (gx_tx_sfp1_digitalreset),         //   input,   width = 1,         tx_digitalreset.tx_digitalreset
	.rx_analogreset          (gx_rx_sfp1_analogreset),          //   input,   width = 1,          rx_analogreset.rx_analogreset
	.rx_digitalreset         (gx_rx_sfp1_digitalreset),         //   input,   width = 1,         rx_digitalreset.rx_digitalreset
	.tx_cal_busy             (gx_tx_sfp1_cal_busy),             //  output,   width = 1,             tx_cal_busy.tx_cal_busy
	.rx_cal_busy             (gx_rx_sfp1_cal_busy),             //  output,   width = 1,             rx_cal_busy.rx_cal_busy
	.tx_serial_clk0          (gx_tx_sfp1_ser_clk),          //   input,   width = 1,          tx_serial_clk0.clk
	.rx_cdr_refclk0          (gx_644M_clk), // not using cdc fifo TODO : remove
	.tx_serial_data          (gx_tx_ser_data[SFP1_CH]),          //  output,   width = 1,          tx_serial_data.tx_serial_data
	.rx_serial_data          (gx_rx_ser_data[SFP1_CH]),        //   input,   width = 1,          rx_serial_data.rx_serial_data
	.rx_set_locktodata       (),       //   input,   width = 1,       rx_set_locktodata.rx_set_locktodata
	.rx_set_locktoref        (),        //   input,   width = 1,        rx_set_locktoref.rx_set_locktoref
	.rx_is_lockedtoref       (gx_rx_sfp1_is_lockedtoref),       //  output,   width = 1,       rx_is_lockedtoref.rx_is_lockedtoref
	.rx_is_lockedtodata      (gx_rx_sfp1_is_lockedtodata),      //  output,   width = 1,      rx_is_lockedtodata.rx_is_lockedtodata
	.tx_clkout               (gx_tx_sfp1_par_clk),               //  output,   width = 1,               tx_clkout.clk
	.rx_clkout               (gx_rx_sfp1_par_clk),               //  output,   width = 1,               rx_clkout.clk
	.tx_parallel_data        (gx_tx_sfp1_par_data),        //   input,  width = 64,        tx_parallel_data.tx_parallel_data
	.unused_tx_parallel_data (), //   input,  width = 64, unused_tx_parallel_data.unused_tx_parallel_data
	.rx_parallel_data        (gx_rx_sfp1_par_data),      //  output,  width = 64,        rx_parallel_data.rx_parallel_data
	.unused_rx_parallel_data ()  //  output,  width = 64, unused_rx_parallel_data.unused_rx_parallel_data
);

top_pcs #(
	.IS_10G(1'b1))
m_sfp1_pcs(
.clk_50m(OSC_50m),
.clk_644m(gx_644M_clk),
.gx_rx_par_clk(gx_rx_sfp1_par_clk),
.gx_tx_par_clk(gx_tx_sfp1_par_clk),
.gx_tx_ser_clk(gx_tx_sfp1_ser_clk),

.io_nreset_i(io_nreset),

.gx_tx_analogreset_o(gx_tx_sfp1_analogreset),
.gx_tx_digitalreset_o(gx_tx_sfp1_digitalreset),
.gx_tx_cal_busy_i(gx_tx_sfp1_cal_busy),

.gx_rx_analogreset_o(gx_rx_sfp1_analogreset),
.gx_rx_digitalreset_o(gx_rx_sfp1_digitalreset),
.gx_rx_cal_busy_i(gx_rx_sfp1_cal_busy),
.gx_rx_is_lockedtodata_i(gx_rx_sfp1_is_lockedtodata),

.gx_rx_par_data_i(gx_rx_sfp1_par_data),
.gx_tx_par_data_o(gx_tx_sfp1_par_data)
);

/* QSFP1 PCS 
 * 40GBASE-R has 4 lanes -> serdes channels */
localparam QCH_N = 4;

logic [QCH_N-1:0]        gx_rx_is_lockedtoref;
logic [QCH_N-1:0]        gx_rx_set_locktodata;   
logic [QCH_N-1:0]        gx_rx_set_locktoref;      
logic [QCH_N*DATA_W-1:0] gx_rx_par_data;
logic [QCH_N*DATA_W-1:0] gx_tx_par_data;

 endmodule
