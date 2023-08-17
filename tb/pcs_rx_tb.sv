/* PCS rx top level test bench */
module pcs_rx_tb;
localparam IS_40G = 1;
localparam HEAD_W = 2;
localparam DATA_W = 64;
localparam KEEP_W = DATA_W/8;
localparam LANE_N = 4;
localparam BLOCK_W = HEAD_W+DATA_W;
localparam LANE0_CNT_N = IS_40G ? 1 : 2;
localparam MAX_SKEW_BIT_N = 1856;
logic clk;
logic nreset;

// transiver
logic  [LANE_N-1:0]        serdes_v_i;
logic  [LANE_N*DATA_W-1:0] serdes_data_i;
logic  [LANE_N*HEAD_W-1:0] serdes_head_i;
logic [LANE_N-1:0]        gearbox_slip_o;

// lite MAC interface
// need to add wrapper to interface with x(l)gmii
logic [LANE_N-1:0]              valid_o;
logic [LANE_N-1:0]              ctrl_v_o;
logic [LANE_N-1:0]              idle_v_o;
logic [LANE_N*LANE0_CNT_N-1:0]  start_v_o;
logic [LANE_N-1:0]              term_v_o;
logic [LANE_N-1:0]              err_v_o;
logic [LANE_N-1:0]              ord_v_o;
logic [LANE_N*DATA_W-1:0]       data_o; 
logic [LANE_N*KEEP_W-1:0]       keep_o;

endmodule
