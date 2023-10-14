/* ---------------------------------- */
/* | Bitstream.technology   Verilog | */
/* | Bitscreamer-40G FPGA           | */
/* | Copyright Kenneth Vorseth 2023 | */
/* ---------------------------------- */
`default_nettype none

module fpga_top (
    //== CORE CONTROL FROM/TO BOARD ==============================================
    input  wire        OSC_50m,     //3.0V
    input  wire        FPGA_RSTn,   //3.0V async reset in from BMC/RESET button
    output wire        FPGA_ACT,    //1.8V fpga activity LED
    inout  wire        FAULTn,      //3.0V open-drain 'Z'/'0'
    //USER LEDs / SWITCH (1.8V)
    output wire [9:0]  USER_LED,
    input  wire        USER_SW,     //pull-up; dip switch (6th). '0'=ON, '1'=OFF
    //I2C POWER BUS (3.0V)
    inout  wire        PWR_SCL,     //open-drain 'Z'/'0'
    inout  wire        PWR_SDA,     //open-drain 'Z'/'0'
    //LOCALBUS ASYNC (3.0V)
    input  wire        LB_CSn,
    input  wire        LB_WRn,
    input  wire        LB_RDn,
    input  wire        LB_ALEn,
    inout  wire [7:0]  LB_AD,

    //== SOFT MICROPROCESSOR MEMORIES ============================================
    //HYPER-RAM 8MB (1.8V, 160Mhz DDR)
    output wire        HBUS_RSTn,
    output wire        HBUS_CK,      //LVDS differential (p/n)
    output wire        HBUS_CSn,
    inout  wire        HBUS_RWDS,
    inout  wire [7:0]  HBUS_D,
    //SRAM 256K x 16 (1.8V, 10nS)
    output wire        SRAM_CSn,
    output wire        SRAM_OEn,
    output wire        SRAM_WEn,
    output wire        SRAM_UBn,
    output wire        SRAM_LBn,
    output wire [17:0] SRAM_A,
    inout  wire [15:0] SRAM_D,
    
    //== SOFT MICROPROCESSOR PERIPHERALS =========================================
    //UART 115200 8N2 (3.0V)
    output wire        UART_TXD,    //open-drain 'Z'/'0'
    input  wire        UART_RXD,
    //QSPI NOR Flash (1.8V)
    output wire        QSPI_CLK,
    output wire        QSPI_CSn,
    inout  wire [3:0]  QSPI_D,
    //SPI SDCard (1.8V)
    output wire        SD_SCK,
    output wire        SD_CSn,
    output wire        SD_MOSI,
    input  wire        SD_MISO,
    //MGMT ETHERNET MII & SMI (1.8V)
    output wire        PHY_REF,     //pll 3B clkout, 50Mhz
    output wire        PHY_RSTn,
    input  wire        MII_TX_CLK,
    output wire        MII_TX_EN,
    output wire [3:0]  MII_TXD,
    input  wire        MII_RX_CLK,
    input  wire        MII_RX_ER,
    input  wire        MII_RX_DV,
    input  wire [3:0]  MII_RXD,
    input  wire        MII_CRS,
    input  wire        MII_COL,
    output wire        MII_OEn,     //tie '0'
    output wire        SMI_MDC,
    inout  wire        SMI_MDIO,    //open-drain 'Z'/'0'
    
    //== 10/40/100G (Q)SFP TRAFFIC PORTS =========================================
    //GIGABIT TRANSCEIVERS (QUAD 1D)
    output wire [5:0]  GXB1D_TXD,
    input  wire [5:0]  GXB1D_RXD,
    input  wire        GXB1D_644M,
    input  wire        GXB1D_125M,
    //GIGABIT TRANSCEIVERS (QUAD 1C)
    output wire [5:0]  GXB1C_TXD,
    input  wire [5:0]  GXB1C_RXD,
    input  wire        GXB1C_644M,  //TBD; only if cross-quad jitter is problematic
    //(Q)SFP PORT SIDEBAND SIGNALS (SFP=[2:1], QSFP=[4:3], QSFP28=[5])
    output wire [2:1]  PORT_RS0,    //pull-up; open-drain
    output wire [2:1]  PORT_RS1,    //pull-up; open-drain
    output wire [5:1]  PORT_TXDIS,  //pull-up; open-drain
    output wire [5:1]  PORT_RXLOS,  //pull-up; '1'=loss of signal
    input  wire [5:1]  PORT_PRSNTn, //pull-up; '0'=present
    output wire        PORT_RSTn,
    input  wire        PORT_INTn,
    //(Q)SFP PORT I2C INTERFACES (SFP0=I2C[1], SFP1=I2C[2], QSFPs share I2C[3] with module select)
    output wire [5:3]  PORT_MSELn,
    inout  wire [3:1]  PORT_SCL,
    inout  wire [3:1]  PORT_SDA,
     
    //== TEK P6960 LOGIC ANALYZER PORT ==
    output wire        LA_CLK,
    output wire        LA_QUAL,
    inout  wire [31:0] LA_DAT
);


/* Tri-State Buffers */
wire sfp0_sda_in, sfp1_sda_in;
wire sfp0_sda_oe, sfp1_sda_oe;
wire sfp0_scl_in, sfp1_scl_in;
wire sfp0_scl_oe, sfp1_scl_oe;
wire force_fault;
_buf_t sfp0_scl_buf_t (1'b0, ~sfp0_scl_oe, PORT_SCL[1]);
_buf_t sfp1_scl_buf_t (1'b0, ~sfp1_scl_oe, PORT_SCL[2]);
_buf_t sfp0_sda_buf_t (1'b0, ~sfp0_sda_oe, PORT_SDA[1]);
_buf_t sfp1_sda_buf_t (1'b0, ~sfp1_sda_oe, PORT_SDA[2]);
_buf_t fault_buf_t (1'b0, ~force_fault, FAULTn);

/* AvalonMM Signals */
wire sys_clk, sys_rst, aux_clk;
wire amm_port0_write, amm_port0_read, amm_port0_waitrequest;
wire amm_port1_write, amm_port1_read, amm_port1_waitrequest;
wire [31:0] amm_port0_readdata, amm_port0_writedata;
wire [31:0] amm_port1_readdata, amm_port1_writedata;
wire  [9:0] amm_port0_address,  amm_port1_address;

/* AXI4-lite Signals */
wire [11:0] axi_port0_awaddr,  axi_port1_awaddr;
wire        axi_port0_awvalid, axi_port1_awvalid;
wire        axi_port0_awready, axi_port1_awready;

wire [31:0] axi_port0_wdata,   axi_port1_wdata;
wire        axi_port0_wvalid,  axi_port1_wvalid;
wire        axi_port0_wready,  axi_port1_wready;
wire  [3:0] axi_port0_wstrb,   axi_port1_wstrb;

wire  [1:0] axi_port0_bresp,   axi_port1_bresp;
wire        axi_port0_bvalid,  axi_port1_bvalid;
wire        axi_port0_bready,  axi_port1_bready;

wire [11:0] axi_port0_araddr,  axi_port1_araddr;
wire        axi_port0_arvalid, axi_port1_arvalid;
wire        axi_port0_arready, axi_port1_arready;

wire        axi_port0_rvalid,  axi_port1_rvalid;
wire        axi_port0_rready,  axi_port1_rready;
wire  [1:0] axi_port0_rresp,   axi_port1_rresp;
wire [31:0] axi_port0_rdata,   axi_port1_rdata;

/* Platform Designer System - NIOS-V */
system system_inst (
    //[NIOS-V PLL Reference]
    .ref_50m_clk            (OSC_50m),
    .ext_rst_reset          (~FPGA_RSTn),
    .aux_clk_clk            (aux_clk),
    //[NIOS-V UART to DPMC]
    .uart_rxd               (UART_RXD),
    .uart_txd               (UART_TXD),
    .pio_export             ({force_fault, FPGA_ACT}),
    //[NIOS-V I2C to SFPs]
    .sfp0_i2c_sda_in        (PORT_SDA[1]),
    .sfp0_i2c_scl_in        (PORT_SCL[1]),
    .sfp0_i2c_sda_oe        (sfp0_sda_oe),
    .sfp0_i2c_scl_oe        (sfp0_scl_oe),
    .sfp1_i2c_sda_in        (PORT_SDA[2]),
    .sfp1_i2c_scl_in        (PORT_SCL[2]),
    .sfp1_i2c_sda_oe        (sfp1_sda_oe),
    .sfp1_i2c_scl_oe        (sfp1_scl_oe),
    //[NIOS-V AvalonMM Ports]
    .amm_clk_clk            (sys_clk),
    .amm_rst_reset          (sys_rst),
    .amm_port0_write        (amm_port0_write),
    .amm_port0_read         (amm_port0_read),
    .amm_port0_address      (amm_port0_address),
    .amm_port0_writedata    (amm_port0_writedata),
    .amm_port0_readdata     (amm_port0_readdata),
    .amm_port0_waitrequest  (amm_port0_waitrequest),
    .amm_port1_write        (amm_port1_write),
    .amm_port1_read         (amm_port1_read),
    .amm_port1_address      (amm_port1_address),
    .amm_port1_writedata    (amm_port1_writedata),
    .amm_port1_readdata     (amm_port1_readdata),
    .amm_port1_waitrequest  (amm_port1_waitrequest),
    //[NIOS-V AXI4-lite Ports]
    .axi_port0_awaddr       (axi_port0_awaddr),
    .axi_port0_awvalid      (axi_port0_awvalid),
    .axi_port0_awready      (axi_port0_awready),
    .axi_port0_wvalid       (axi_port0_wvalid),
    .axi_port0_wready       (axi_port0_wready),
    .axi_port0_wstrb        (axi_port0_wstrb),
    .axi_port0_wdata        (axi_port0_wdata),
    .axi_port0_bvalid       (axi_port0_bvalid),
    .axi_port0_bready       (axi_port0_bready),
    .axi_port0_bresp        (axi_port0_bresp),
    .axi_port0_araddr       (axi_port0_araddr),
    .axi_port0_arvalid      (axi_port0_arvalid),
    .axi_port0_arready      (axi_port0_arready),
    .axi_port0_rvalid       (axi_port0_rvalid),
    .axi_port0_rready       (axi_port0_rready),
    .axi_port0_rdata        (axi_port0_rdata),
    .axi_port0_rresp        (axi_port0_rresp),
    .axi_port1_awaddr       (axi_port1_awaddr),
    .axi_port1_awvalid      (axi_port1_awvalid),
    .axi_port1_awready      (axi_port1_awready),
    .axi_port1_wvalid       (axi_port1_wvalid),
    .axi_port1_wready       (axi_port1_wready),
    .axi_port1_wstrb        (axi_port1_wstrb),
    .axi_port1_wdata        (axi_port1_wdata),
    .axi_port1_bvalid       (axi_port1_bvalid),
    .axi_port1_bready       (axi_port1_bready),
    .axi_port1_bresp        (axi_port1_bresp),
    .axi_port1_araddr       (axi_port1_araddr),
    .axi_port1_arvalid      (axi_port1_arvalid),
    .axi_port1_arready      (axi_port1_arready),
    .axi_port1_rvalid       (axi_port1_rvalid),
    .axi_port1_rready       (axi_port1_rready),
    .axi_port1_rdata        (axi_port1_rdata),
    .axi_port1_rresp        (axi_port1_rresp)
);

/* Transceiver fPLLs (Bank 1D) */
//wire [1:0] fabric_clk_1d;   //[0]=10G ( 156.25 MHz),    [1]=1G (125 MHz)
wire [1:0] hssi_clk_1d;     //[0]=10G (5156.25000 MHz), [1]=1G (625 MHz)
wire [1:0] pll_locked_1d;
atx_pll_10g i_atx_10g_1d (
    .pll_refclk0     (GXB1C_644M),         //<< 644.53125MHz REF
    .pll_locked      (pll_locked_1d[0]),
    .pll_cal_busy    (),
    .pll_powerdown   (1'b0),
    .tx_serial_clk   (hssi_clk_1d[0])   //>>5156.25MHz TX CLK (10G)
);
atx_pll_1g i_atx_1g_1d (
    .pll_refclk0     (GXB1D_125M),         //<< 125MHz REF
    .pll_locked      (pll_locked_1d[1]),
    .pll_cal_busy    (),
    .pll_powerdown   (1'b0),
    .tx_serial_clk   (hssi_clk_1d[1])   //>>625MHz TX CLK (1G)
);
/*fpll_10g i_fpll_10g_1d (
    .pll_refclk0   (GXB1C_644M),           //<< 644.53125MHz REF
    .pll_powerdown (1'b0),
    .pll_locked    (),
    .pll_cal_busy  (),
    .outclk0       (fabric_clk_1d[0]),  //>> 156.25MHz
    .outclk1       ()                   //>> 214.xxMHz (For Phase Alignment)
);*/
/*
fpll_10g i_fpll_10g_1d (
    .pll_refclk0   (GXB1C_644M),           //<< 644.53125MHz REF
    .pll_powerdown (1'b0),
    .pll_locked    (),
    .pll_cal_busy  (),
    .outclk0       (fabric_clk_1d[0]),  //>> 156.25MHz
    .outclk1       ()                   //>> 58.59375MHz (For Phase Alignment)
);
fpll_10g i_fpll_1g_1d (
    .pll_refclk0   (GXB1D_125M),           //<< 125MHz REF
    .pll_powerdown (1'b0),
    .pll_locked    (),
    .pll_cal_busy  (),
    .outclk0       (fabric_clk_1d[1]),  //>> 125MHz
    .outclk1       ()                   //>> 214.xxMHz (For Phase Alignment)
);*/


/* Transceiver/Traffic Port 0 (SFP 0, Bank 1D) */
bitscreamer_port port0 (
    .sys_rst        (sys_rst),
    .sys_clk        (sys_clk),
    .aux_clk        (aux_clk),
    //[AvalonMM Slave Interface]
    .amm_address    (amm_port0_address),
    .amm_write      (amm_port0_write),
    .amm_writedata  (amm_port0_writedata),
    .amm_read       (amm_port0_read),
    .amm_readdata   (amm_port0_readdata),
    .amm_waitrequest(amm_port0_waitrequest),
    //[AXI4-lite Slave Interface]
    .axi_awaddr     (axi_port0_awaddr), .axi_awvalid(axi_port0_awvalid), .axi_awready(axi_port0_awready),
    .axi_wdata      (axi_port0_wdata),  .axi_wvalid (axi_port0_wvalid),  .axi_wready (axi_port0_wready), .axi_wstrb(axi_port0_wstrb),
    .axi_bresp      (axi_port0_bresp),  .axi_bvalid (axi_port0_bvalid),  .axi_bready (axi_port0_bready),
    .axi_araddr     (axi_port0_araddr), .axi_arvalid(axi_port0_arvalid), .axi_arready(axi_port0_arready),
    .axi_rdata      (axi_port0_rdata),  .axi_rvalid (axi_port0_rvalid),  .axi_rready (axi_port0_rready), .axi_rresp(axi_port0_rresp),
    //[Transceiver Bank fPLLs]
    .hssi_clk       (hssi_clk_1d[1:0]),
    .hssi_cdr       ({GXB1D_125M, GXB1C_644M}),
    .pll_locked     (pll_locked_1d[1:0]),
    //[Transceiver Lane]
    .xcvr_rx        (GXB1D_RXD[4]),
    .xcvr_tx        (GXB1D_TXD[4])
);

/* Transceiver/Traffic Port 1 (SFP 1, Bank 1D) */
bitscreamer_port port1 (
    .sys_rst        (sys_rst),
    .sys_clk        (sys_clk),
    .aux_clk        (aux_clk),
    //[AvalonMM Slave Interface]
    .amm_address    (amm_port1_address),
    .amm_write      (amm_port1_write),
    .amm_writedata  (amm_port1_writedata),
    .amm_read       (amm_port1_read),
    .amm_readdata   (amm_port1_readdata),
    .amm_waitrequest(amm_port1_waitrequest),
    //[AXI4-lite Slave Interface]
    .axi_awaddr     (axi_port1_awaddr), .axi_awvalid(axi_port1_awvalid), .axi_awready(axi_port1_awready),
    .axi_wdata      (axi_port1_wdata),  .axi_wvalid (axi_port1_wvalid),  .axi_wready (axi_port1_wready), .axi_wstrb(axi_port1_wstrb),
    .axi_bresp      (axi_port1_bresp),  .axi_bvalid (axi_port1_bvalid),  .axi_bready (axi_port1_bready),
    .axi_araddr     (axi_port1_araddr), .axi_arvalid(axi_port1_arvalid), .axi_arready(axi_port1_arready),
    .axi_rdata      (axi_port1_rdata),  .axi_rvalid (axi_port1_rvalid),  .axi_rready (axi_port1_rready), .axi_rresp(axi_port1_rresp),
    //[Transceiver Bank fPLLs]
    .hssi_clk       (hssi_clk_1d[1:0]),
    .hssi_cdr       ({GXB1D_125M, GXB1C_644M}),
    .pll_locked     (pll_locked_1d[1:0]),
    //[Transceiver Lane]
    .xcvr_rx        (GXB1D_RXD[5]),
    .xcvr_tx        (GXB1D_TXD[5])
);

endmodule
