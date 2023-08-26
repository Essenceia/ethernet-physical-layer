`ifndef TB_LOOP_CNT_N
`define TB_LOOP_CNT_N 300
`endif
module pcs_tb;

`define _40GBASE

`ifdef _40GBASE
localparam IS_10G = 0;
localparam LANE_N = 4;
`else
localparam IS_10G = 1;
localparam LANE_N = 1;
`endif

localparam HEAD_W = 2;
localparam DATA_W = 64;
localparam KEEP_W = DATA_W/8;
localparam BLOCK_W = HEAD_W+DATA_W;
localparam LANE0_CNT_N = !IS_10G ? 1 : 2;	

localparam PMA_DATA_W = 16; 
localparam PMA_CNT_N  = (LANE_N*DATA_W)/PMA_DATA_W;

localparam MAX_SKEW_BIT_N = 1856;

localparam DEBUG_ID_W = 64;

// TX
// MAC
logic [LANE_N-1:0] ctrl_v_i;
logic [LANE_N-1:0] idle_v_i;
logic [LANE_N-1:0] start_v_i;
logic [LANE_N-1:0] term_v_i;
logic [LANE_N-1:0] err_v_i;
logic [LANE_N*DATA_W-1:0] data_i; // tx data
logic [LANE_N*KEEP_W-1:0] keep_i;
logic              ready_o;	
// PMA
logic [PMA_CNT_N*PMA_DATA_W-1:0] pma_o;
logic [PMA_CNT_N*PMA_DATA_W-1:0] tb_pma;
logic [PMA_CNT_N*PMA_DATA_W-1:0] tb_pma_diff;

// debug id
logic [LANE_N*DEBUG_ID_W-1:0] data_debug_id;
logic [LANE_N*DEBUG_ID_W-1:0] pma_debug_id;

// lane
logic [KEEP_W-1:0] keep_lane[LANE_N-1:0];
logic [DATA_W-1:0] data_lane[LANE_N-1:0];
logic [DATA_W-1:0] tb_pma_lane[LANE_N-1:0];
logic [DEBUG_ID_W-1:0] data_debug_id_lane[LANE_N-1:0];
logic [DEBUG_ID_W-1:0] pma_debug_id_lane[LANE_N-1:0];

// RX
// transiver
logic [LANE_N-1:0]        serdes_v_i;
logic [LANE_N*DATA_W-1:0] serdes_data_i;
logic [LANE_N*HEAD_W-1:0] serdes_head_i;
logic [LANE_N-1:0]        gearbox_slip_o;
// MAC
logic [LANE_N-1:0]              valid_o;
logic [LANE_N-1:0]              ctrl_v_o;
logic [LANE_N-1:0]              idle_v_o;
logic [LANE_N*LANE0_CNT_N-1:0]  start_v_o;
logic [LANE_N-1:0]              term_v_o;
logic [LANE_N-1:0]              err_v_o;
logic [LANE_N-1:0]              ord_v_o;
logic [LANE_N*DATA_W-1:0]       data_o; 
logic [LANE_N*KEEP_W-1:0]       keep_o;


reg   clk = 1'b0;
logic nreset;
logic tb_nreset;

always clk = #5 ~clk;

assign tb_pma_diff = tb_pma ^ pma_o;

always @(posedge clk) begin
	if( ~nreset ) begin
		assert(tb_pma == pma_o);
	end
end

task tb_rx();
	// Temporary rx
	serdes_v_i = '1;
endtask

// fake gearbox 64 -> 66
task fake_gearbox_rx();
	// TODO
endtask

initial begin
	`ifndef VERILATOR
	$dumpfile("build/wave.vcd");
	$dumpvars(0, pcs_tb);
	`endif
	nreset = 1'b0;
	tb_nreset = 1'b0;
	#10
	tb_nreset = 1'b1;
	ctrl_v_i  = {LANE_N{1'b1}};
	idle_v_i  = {LANE_N{1'b1}};
	start_v_i  = {LANE_N{1'b0}};
	term_v_i  = {LANE_N{1'b0}};
	err_v_i  = {LANE_N{1'b0}};	
	#6
	nreset = 1'b1;

	for(int t=0; t < `TB_LOOP_CNT_N; t++) begin
		`ifndef VERILATOR
		// next block driver
		$tb(ready_o,
			ctrl_v_i, idle_v_i, start_v_i,
			term_v_i, keep_lane,
			err_v_i , data_i,
			data_debug_id);	
			// expected result
		$tb_exp(i, tb_pma, pma_debug_id);
		`endif
		tb_rx();
		#10
		$display("loop %d", t);
	end
	$tb_end();
	
	$display("Sucess");	
	$finish;
end

genvar x;
generate 
	for( x=0 ; x < LANE_N ; x++ ) begin
		// TX 
		//assign data_i[x*DATA_W+DATA_W-1:x*DATA_W] = data_lane[x];
		//assassign keep_i[x*KEEP_W+KEEP_W-1:x*KEEP_W] = keep_lane[x];
		//assassign tb_pma[x*DATA_W+DATA_W-1:x*DATA_W] = tb_pma_lane[x];

		assign data_debug_id[x*DEBUG_ID_W+DEBUG_ID_W-1:x*DEBUG_ID_W] = data_debug_id_lane[x];
		assign pma_debug_id[x*DEBUG_ID_W+DEBUG_ID_W-1:x*DEBUG_ID_W]  = pma_debug_id_lane[x];

		// RX
		// hardwire tx gearbox input to serdes output, 
		// temporary steping stone
		assign serdes_data_i[x*DATA_W+DATA_W-1:x*DATA_W] = m_pcs_tx.gb_data[x];
		assign serdes_head_i[x*HEAD_W+HEAD_W-1:x*HEAD_W] = m_pcs_tx.gb_head[x];
	end
endgenerate


// PCS TX

pcs_tx #( .IS_10G(IS_10G), .LANE_N(LANE_N), .DATA_W(DATA_W), .KEEP_W(KEEP_W))
m_pcs_tx(
	.clk(clk),
	.nreset(nreset),
	.ctrl_v_i(ctrl_v_i),
	.idle_v_i(idle_v_i),
	.start_v_i(start_v_i),
	.term_v_i(term_v_i),
	.err_v_i(err_v_i),
	.data_i(data_i),
	.keep_i(keep_i),
	.ready_o(ready_o),	
	.data_o(pma_o)
);

// PCS RX

pcs_rx #(
	.IS_10G(IS_10G),
	.HEAD_W(HEAD_W),
	.DATA_W(DATA_W),
	.KEEP_W(KEEP_W),
	.LANE_N(LANE_N),
	.BLOCK_W(BLOCK_W),
	.LANE0_CNT_N(LANE0_CNT_N),
	.MAX_SKEW_BIT_N(MAX_SKEW_BIT_N))
m_pcs_rx(
	.clk(clk),
	.nreset(nreset),
    .serdes_v_i(serdes_v_i),
    .serdes_data_i(serdes_data_i),
    .serdes_head_i(serdes_head_i),
    .gearbox_slip_o(gearbox_slip_o),
	.valid_o(valid_o),
	.ctrl_v_o(ctrl_v_o),
	.idle_v_o(idle_v_o),
	.start_v_o(start_v_o),
	.term_v_o(term_v_o),
	.err_v_o(err_v_o),
	.ord_v_o(ord_v_o),
	.data_o(data_o), 
	.keep_o(keep_o)
);
endmodule
