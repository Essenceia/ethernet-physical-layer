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

localparam DATA_W = 64;
localparam KEEP_W = DATA_W/8;
	
localparam PMA_DATA_W = 16; 
localparam PMA_CNT_N  = (LANE_N*DATA_W)/PMA_DATA_W;

localparam DEBUG_ID_W = 64;

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

initial begin
	$dumpfile("build/wave.vcd");
	$dumpvars(0, pcs_tb);
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
		for( int i = 0; i < LANE_N; i++ ) begin
		  // next block driver
				$tb(ready_o, i,
					ctrl_v_i[i], idle_v_i[i], start_v_i[i],
					term_v_i[i], keep_lane[i],
					err_v_i[i] , data_lane[i],
					data_debug_id_lane[i]);	
					// expected result
				$tb_exp(i, tb_pma_lane[i], pma_debug_id_lane[i]);
		end
		#10
		$display("loop %d", t);
	end
	$tb_end();
	
	$display("Sucess");	
	$finish;
end

// check : experiemtnation, don't know if this would work
//assert( pma_o == tb_pma);

genvar x;
generate 
	for( x=0 ; x < LANE_N ; x++ ) begin
		assign data_i[x*DATA_W+DATA_W-1:x*DATA_W] = data_lane[x];
		assign keep_i[x*KEEP_W+KEEP_W-1:x*KEEP_W] = keep_lane[x];
		assign tb_pma[x*DATA_W+DATA_W-1:x*DATA_W] = tb_pma_lane[x];

		assign data_debug_id[x*DEBUG_ID_W+DEBUG_ID_W-1:x*DEBUG_ID_W] = data_debug_id_lane[x];
		assign pma_debug_id[x*DEBUG_ID_W+DEBUG_ID_W-1:x*DEBUG_ID_W]  = pma_debug_id_lane[x];
	end
endgenerate

// uut
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

endmodule
