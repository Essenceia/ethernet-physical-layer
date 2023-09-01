/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */

`ifndef TB_LOOP_CNT_N
`define TB_LOOP_CNT_N 40000
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
localparam BLOCK_W = DATA_W + HEAD_W;
localparam KEEP_W = DATA_W/8;
localparam LANE0_CNT_N = !IS_10G ? 1 : 2;	

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
// GEARBOX
logic [LANE_N*BLOCK_W-1:0] gb_data_o;
logic [LANE_N*BLOCK_W-1:0] tb_gb_data;
logic [LANE_N*BLOCK_W-1:0] tb_gb_data_diff;

// debug id
logic [LANE_N*DEBUG_ID_W-1:0] data_debug_id;
logic [LANE_N*DEBUG_ID_W-1:0] tb_data_debug_id;

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

/*verilator lint_off BLKSEQ */ 
always clk = #5 ~clk;
/*verilator lint_on BLKSEQ */ 

assign tb_gb_data_diff = tb_gb_data ^ gb_data_o;


/* Check TX data against tb produced expected output */
always @(posedge clk) begin
	if( nreset ) begin
		assert(tb_gb_data == gb_data_o);
		`ifdef VERILATOR
		if( tb_gb_data != gb_data_o)begin
			$display("ERROR : time %t pma data not matching, :\ngb_data_o    %x\ntb_gb_data_o %x\ndebug id %x\ndiff     %x\n",$time, gb_data_o, tb_gb_data, tb_data_debug_id, tb_gb_data_diff);		
		end
		`ifdef DEBUG 
		else begin
			$display("PASS : time %t pma output matching tb\n",$time);
		end
		`endif
		`endif
	end
end


/* Check RX output against TX input
* This is only checking once lock has been
* exstablished, this takes at least 2 alignement
* markers in 40GBASE.
* Doesn't account for skew delay : only works when
* there is no skew */
genvar x;
generate
for(x=0; x<LANE_N; x++) begin
	always @(posedge clk) begin
		if (nreset) begin
			if( valid_o[x] ) begin /* RX lock */
				/* lite decoder output check */
				assert(  ctrl_v_o[x] == ctrl_v_i[x] );

				assert( ~ctrl_v_o[x] | ( ctrl_v_o[x] & ( idle_v_o[x] == idle_v_i[x] ))); 
				assert( ~ctrl_v_o[x] | ( ctrl_v_o[x] 
					& ( start_v_o[x*LANE0_CNT_N+:LANE0_CNT_N] 
					 == start_v_i[x*LANE0_CNT_N+:LANE0_CNT_N] )));
 
				assert( ~ctrl_v_o[x] | ( ctrl_v_o[x] & ( err_v_o[x] == err_v_i[x] ))); 
				assert( ~ctrl_v_o[x] | ( ctrl_v_o[x] & ( term_v_o[x] == term_v_i[x] )));

				if ( ctrl_v_o[x] & term_v_o[x] ) begin 
					assert( keep_o[x*KEEP_W+:KEEP_W] 
						 == keep_i[x*KEEP_W+:KEEP_W] ); 
				end
				/* data match check */
				if( ~ctrl_v_o[x] ) begin
					assert( data_o[x*DATA_W+:DATA_W]
						 == data_i[x*DATA_W+:DATA_W] );
				end
			end // valid
		end // nreset
	end // allways
end // for
endgenerate

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
	$dumpfile("wave/pcs_tb.vcd");
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
			term_v_i, keep_i,
			err_v_i , data_i,
			data_debug_id);	
			// expected result
		$tb_exp( tb_gb_data, tb_data_debug_id);
		`endif
		tb_rx();
		#10
		$display("loop %d", t);
	end

	`ifndef VERILATOR
	$tb_end();
	`endif
	
	$display("Sucess");	
	$finish;
end

generate 
	for( x=0 ; x < LANE_N ; x++ ) begin
		// RX
		// hardwire tx gearbox input to serdes output, 
		// temporary steping stone
		assign serdes_data_i[x*DATA_W+DATA_W-1:x*DATA_W] = gb_data_o[x*BLOCK_W+BLOCK_W-1:x*BLOCK_W+HEAD_W];
		assign serdes_head_i[x*HEAD_W+HEAD_W-1:x*HEAD_W] = gb_data_o[x*BLOCK_W+HEAD_W-1:x*BLOCK_W];
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
	.data_o(gb_data_o)
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
