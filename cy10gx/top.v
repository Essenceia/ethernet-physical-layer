/* TOP module for cyclone 10 gx fpga 
 * PCS loopback */
module top #(
	localparam SFP1_CH = 4,
	localparam QSFP1_CH_LSB = 0,
	localparam QSFP1_CH_MSB = 3,
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
	.o   (GXB1D_TXD[l]),
	.obar(GXB1D_TXD_N[l])
);
end
endgenerate

/* clk network
 * generate master clock at 161.MHz */
logic gx_rx_par_clk;// parallel clk
logic gx_tx_par_clk;// parallel clk
logic gx_tx_ser_clk;// from core -> transiver fPLL

/* reset from IO, using asynchronous reset synchronizer circuit */
reg   io_meta_nreset_q;
reg   io_master_nreset_q;
logic io_master_nreset;

always @(posedge OSC_50m or negedge FPGA_RSTn) begin
	if (~FPGA_RSTn)begin
		io_meta_nreset_q   <= 1'b0;
		io_master_nreset_q <= 1'b0;
	end else begin
		io_meta_nreset_q   <= 1'b1;
		io_master_nreset_q <= io_meta_nreset_q;
	end
end
assign io_master_nreset = io_master_nreset_q;

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

.io_nreset_i(io_master_nreset),

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

logic [QCH_N-1:0] gx_rx_qsfp1_par_clk;
logic [QCH_N-1:0] gx_tx_qsfp1_par_clk;
logic [QCH_N-1:0] gx_tx_qsfp1_ser_clk;

logic [QCH_N-1:0] gx_tx_qsfp1_analogreset;
logic [QCH_N-1:0] gx_tx_qsfp1_digitalreset;
logic [QCH_N-1:0] gx_tx_qsfp1_cal_busy;
logic [QCH_N-1:0] gx_rx_qsfp1_analogreset;
logic [QCH_N-1:0] gx_rx_qsfp1_digitalreset;
logic [QCH_N-1:0] gx_rx_qsfp1_cal_busy;
logic [QCH_N-1:0] gx_rx_qsfp1_is_lockedtodata;

logic [QCH_N-1:0]        gx_rx_qsfp1_is_lockedtoref;
logic [QCH_N-1:0]        gx_rx_qsfp1_set_locktodata;   
logic [QCH_N-1:0]        gx_rx_qsfp1_set_locktoref;      
logic [QCH_N*DATA_W-1:0] gx_rx_qsfp1_par_data;
logic [QCH_N*DATA_W-1:0] gx_tx_qsfp1_par_data;

qsfp_trans m_qsfp1_trans (
	.tx_analogreset          (gx_tx_qsfp1_analogreset),          //   input,   width = 1,          tx_analogreset.tx_analogreset
	.tx_digitalreset         (gx_tx_qsfp1_digitalreset),         //   input,   width = 1,         tx_digitalreset.tx_digitalreset
	.rx_analogreset          (gx_rx_qsfp1_analogreset),          //   input,   width = 1,          rx_analogreset.rx_analogreset
	.rx_digitalreset         (gx_rx_qsfp1_digitalreset),         //   input,   width = 1,         rx_digitalreset.rx_digitalreset
	.tx_cal_busy             (gx_tx_qsfp1_cal_busy),             //  output,   width = 1,             tx_cal_busy.tx_cal_busy
	.rx_cal_busy             (gx_rx_qsfp1_cal_busy),             //  output,   width = 1,             rx_cal_busy.rx_cal_busy
	.tx_serial_clk0          (gx_tx_qsfp1_ser_clk),          //   input,   width = 1,          tx_serial_clk0.clk
	.rx_cdr_refclk0          (gx_644M_clk), // not using cdc fifo TODO : remove
	.tx_serial_data          (gx_tx_ser_data[QSFP1_CH_MSB:QSFP1_CH_LSB]),          //  output,   width = 1,          tx_serial_data.tx_serial_data
	.rx_serial_data          (gx_rx_ser_data[QSFP1_CH_MSB:QSFP1_CH_LSB]),        //   input,   width = 1,          rx_serial_data.rx_serial_data
	.rx_set_locktodata       (),       //   input,   width = 1,       rx_set_locktodata.rx_set_locktodata
	.rx_set_locktoref        (),        //   input,   width = 1,        rx_set_locktoref.rx_set_locktoref
	.rx_is_lockedtoref       (gx_rx_qsfp1_is_lockedtoref),       //  output,   width = 1,       rx_is_lockedtoref.rx_is_lockedtoref
	.rx_is_lockedtodata      (gx_rx_qsfp1_is_lockedtodata),      //  output,   width = 1,      rx_is_lockedtodata.rx_is_lockedtodata
	.tx_clkout               (gx_tx_qsfp1_par_clk),               //  output,   width = 1,               tx_clkout.clk
	.rx_clkout               (gx_rx_qsfp1_par_clk),               //  output,   width = 1,               rx_clkout.clk
	.tx_parallel_data        (gx_tx_qsfp1_par_data),        //   input,  width = 64,        tx_parallel_data.tx_parallel_data
	.unused_tx_parallel_data (), //   input,  width = 64, unused_tx_parallel_data.unused_tx_parallel_data
	.rx_parallel_data        (gx_rx_qsfp1_par_data),      //  output,  width = 64,        rx_parallel_data.rx_parallel_data
	.unused_rx_parallel_data ()  //  output,  width = 64, unused_rx_parallel_data.unused_rx_parallel_data
);
top_pcs #(
	.IS_10G(1'b0))
m_qsfp1_pcs(
.clk_50m      (OSC_50m),
.clk_644m     (gx_644M_clk),
.gx_rx_par_clk(gx_rx_qsfp1_par_clk),
.gx_tx_par_clk(gx_tx_qsfp1_par_clk),
.gx_tx_ser_clk(gx_tx_qsfp1_ser_clk),
.io_nreset_i  (io_master_nreset),
.gx_tx_analogreset_o    (gx_tx_qsfp1_analogreset),
.gx_tx_digitalreset_o   (gx_tx_qsfp1_digitalreset),
.gx_tx_cal_busy_i       (gx_tx_qsfp1_cal_busy),
.gx_rx_analogreset_o    (gx_rx_qsfp1_analogreset),
.gx_rx_digitalreset_o   (gx_rx_qsfp1_digitalreset),
.gx_rx_cal_busy_i       (gx_rx_qsfp1_cal_busy),
.gx_rx_is_lockedtodata_i(gx_rx_qsfp1_is_lockedtodata),
.gx_rx_par_data_i       (gx_rx_qsfp1_par_data),
.gx_tx_par_data_o       (gx_tx_qsfp1_par_data)
);


endmodule
